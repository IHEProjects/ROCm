#include<stdio.h>
#include<unistd.h>
#define __HIP_PLATFORM_HCC__
#include<hip/hip_runtime.h>
#define CHECKRES( _cmd )                                                \
    if ( hipres != hipSuccess ) {					\
	printf("ERROR - %s - %s:%d\n", #_cmd,  __FILE__, __LINE__);	\
	exit(EXIT_FAILURE);						\
    }									\


__global__ void bit_extract_kernel(uint32_t* C_d, const uint32_t* A_d, size_t N) {
    size_t offset = (hipBlockIdx_x * hipBlockDim_x + hipThreadIdx_x);
    size_t stride = hipBlockDim_x * hipGridDim_x;

    for (size_t i = offset; i < N; i += stride) {
#ifdef __HIP_PLATFORM_HCC__
        C_d[i] = __bitextract_u32(A_d[i], 8, 4);
#else /* defined __HIP_PLATFORM_NVCC__ or other path */
        C_d[i] = ((A_d[i] & 0xf00) >> 8);
#endif
    }
}

#define CHECK(cmd)                                                                                 \
    {                                                                                              \
        hipError_t error = cmd;                                                                    \
        if (error != hipSuccess) {                                                                 \
            fprintf(stderr, "error: '%s'(%d) at %s:%d\n", hipGetErrorString(error), error,         \
                    __FILE__, __LINE__);                                                           \
            exit(EXIT_FAILURE);                                                                    \
        }                                                                                          \
    }

void* wrapper(void * start) {
    uint32_t *A_d, *C_d;
    uint32_t *A_h, *C_h;
    size_t N = 1000000;
    size_t Nbytes = N * sizeof(uint32_t);

    int mytid = (long)start;

    int deviceId;
    CHECK(hipInit( 0 ));
    CHECK(hipGetDevice(&deviceId));
    hipDeviceProp_t props;
    CHECK(hipGetDeviceProperties(&props, deviceId));
    printf("info: running on device #%d %s\n", deviceId, props.name);


    printf("info: allocate host mem (%6.2f MB)\n", 2 * Nbytes / 1024.0 / 1024.0);
    A_h = (uint32_t*)malloc(Nbytes);
    CHECK(A_h == 0 ? hipErrorMemoryAllocation : hipSuccess);
    C_h = (uint32_t*)malloc(Nbytes);
    CHECK(C_h == 0 ? hipErrorMemoryAllocation : hipSuccess);

    for (size_t i = 0; i < N; i++) {
        A_h[i] = i;
    }

    printf("info: allocate device mem (%6.2f MB)\n", 2 * Nbytes / 1024.0 / 1024.0);
    CHECK(hipMalloc(&A_d, Nbytes));
    CHECK(hipMalloc(&C_d, Nbytes));

    printf("info: copy Host2Device\n");
    CHECK(hipMemcpy(A_d, A_h, Nbytes, hipMemcpyHostToDevice));

    printf("info: launch 'bit_extract_kernel' \n");
    const unsigned blocks = 512;
    const unsigned threadsPerBlock = 256;
    hipLaunchKernelGGL(bit_extract_kernel, dim3(blocks), dim3(threadsPerBlock), 0, 0, C_d, A_d, N);

    printf("info: copy Device2Host\n");
    CHECK(hipMemcpy(C_h, C_d, Nbytes, hipMemcpyDeviceToHost));

    printf("info: check result\n");
    for (size_t i = 0; i < N; i++) {
        unsigned Agold = ((A_h[i] & 0xf00) >> 8);
        if (C_h[i] != Agold) {
            fprintf(stderr, "mismatch detected.\n");
            printf("%zu: %08x =? %08x (Ain=%08x)\n", i, C_h[i], Agold, A_h[i]);
            CHECK(hipErrorUnknown);
        }
    }
    printf("PASSED %d!\n",mytid);
    printf("calling hipFree %d!\n",mytid);
    hipFree(A_d);
    hipFree(C_d);
    return NULL;
}

const char *device_image_filename="a.out-openmp-amdgcn-amd-amdhsa-";

#define N 100
int A[N];
int B[N];
int main(int argc, char *argv[])
{
    if (argc < 3) {
	printf("Usage: %s <kernel_name> <gpu>\n", argv[0]);
	return -1;
    }
    const char *kernel_name = argv[1];
    char ImageName[1000];
    strcpy(ImageName, device_image_filename);
    strcat(ImageName, argv[2]);
    printf("Image is %s\n", ImageName);
    hipError_t hipres;
    hipModule_t hipmod;
    hipDevice_t  cudev;
    hipFunction_t hipkern;
    int *argptr;
    int *dA = NULL;
    int *dB = NULL;
   #define KK 10
#ifdef USE_OMP
   // this will fail if enabled.
   #pragma omp parallel for schedule(static,1)
#endif
   for(long i=0; i<KK; ++i) {
     wrapper((void *) (i+1));
   }
   fprintf(stderr,"===Starting omp loads\n");
    for(int i=0; i<N; i++){
	A[i] =0;
	B[i] =i;
    }

      
    hipres = hipInit( 0 );
    CHECKRES(hipInit);

    hipres = hipDeviceGet( &cudev, 0 );
    CHECKRES(hipDeviceGet);

    hipres = hipModuleLoad( &hipmod, ImageName );
    CHECKRES(hipModuleLoad);
    hipres = hipModuleGetFunction( &hipkern, hipmod, kernel_name );
    CHECKRES(hipModuleGetFunction);

    hipres = hipMalloc((void**)&dA, N*sizeof(A[0]));
    CHECKRES(hipMalloc);
    hipres = hipMalloc((void**)&dB, N*sizeof(B[0]));
    CHECKRES(hipMalloc);

    hipres = hipMemcpyHtoD(dA, A, N*sizeof(A[0]));
    CHECKRES(hipMemcpyHtoD);
    hipres = hipMemcpyHtoD(dB, B, N*sizeof(B[0]));
    CHECKRES(hipMemcpyHtoD);


    void *args[] = { (void*)dA, (void*)dB };

    size_t size = sizeof(void*) * 2;
    void *config[] = {
        HIP_LAUNCH_PARAM_BUFFER_POINTER, &args[0],
        HIP_LAUNCH_PARAM_BUFFER_SIZE,    &size,
        HIP_LAUNCH_PARAM_END
    };
    hipres = hipModuleLaunchKernel( hipkern,
				    1,1,1, // grid dims
				    128,1,1, // block dims
				    0, // shared mem bytes
				    0, // stream
				    0, // unused
				    config);  // extra (kernel params)
    CHECKRES(hipModuleLaunchKernel);
    hipres = hipDeviceSynchronize();
    //sleep(10);
    fflush(stdout);

    hipres = hipMemcpyDtoH(A, dA, N*sizeof(A[0]));
    CHECKRES(hipMemcpyDtoH);
    hipres = hipMemcpyDtoH(B, dB, N*sizeof(B[0]));
    CHECKRES(hipMemcpyDtoH);
    hipres = hipDeviceSynchronize();
    CHECKRES(hipDeviceSynchronize);

    for(int i=0; i<N; i++){
	assert(A[i] == B[i]);
    }
    printf("PASSED\n");

    return 0;
}
