include ../Makefile.defs

TESTNAME     = hip_device_compile
TESTSRC_MAIN = hip_device_compile.cpp
TESTSRC_AUX  =
TESTSRC_ALL  = $(TESTSRC_MAIN) $(TESTSRC_AUX)
ifeq (sm_,$(findstring sm_,$(AOMP_GPU)))
CFLAGS = -x cuda -I/usr/local/cuda/include --offload-arch=${AOMP_GPU} -std=c++11
LINK_FLAGS =  -L$(CUDA)/targets/$(UNAMEP)-linux/lib -lcudart -Wl,-rpath,/usr/local/cuda/targets/x86_64-linux/lib
else
CFLAGS = -x hip --offload-arch=${AOMP_GPU} -std=c++11 -lamdhip64
endif
OMP_FLAGS    =

ifeq ($(EPSDB),1)
OMP_BIN      = /opt/rocm/bin/hipcc
else
CLANG        = clang++
OMP_BIN      = $(AOMP)/bin/$(CLANG)
endif
CC           = $(OMP_BIN) $(VERBOSE)

#-ccc-print-phases
#"-\#\#\#"

include ../Makefile.rules
