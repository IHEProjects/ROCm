INSTALLATION INSTRUCTIONS
-------------------------

1. Run the installation script named install.sh as root user

   ./install.sh

   Follow the prompts to select and install the components.

2. After the components are installed, adjust settings of PATH and
   LD_LIBRARY_PATH variables as described below:

   $AMDSDK_ROOT - Folder where AMD's Open64 SDK is installed.

   $DOCROOT     - Folder where supplied documentation (pdf's) is installed.
                      Actual path is $AMDSDK_ROOT/pdf

   $OPEN64_TC   - Folder where Open64 compiler toolchain is installed
                      To use the compiler, set path variable as follows,
                      If you are using bash shell environment,
                      export  PATH=$AMDSDK_ROOT/x86_open64-4.2.4/bin:$PATH

   $CODEANALYST - Folder where Code Analyst Profiler tool is installed
                      If you are using bash shell environment,
                      export  PATH=$AMDSDK_ROOT/codeanalyst/bin:$PATH

   $ACML        - Folder where AMD Core Math Library is installed.
                      This release provides static and dynamic versions
                      of the library. 
                      $AMDSDK_ROOT/acml/open64_64/lib
                      $AMDSDK_ROOT/acml/open64_64/include
                      $AMDSDK_ROOT/acml/open64_64_mp/lib
                      $AMDSDK_ROOT/acml/open64_64_mp/include
                      To use these libraries, please make appropriate 
                      changes in your build (Makefile) enviornment.
                      Examples are provided in following directories,
                       - $AMDSDK_ROOT/acml/open64_64/examples
                       - $AMDSDK_ROOT/acml/open64_64_mp/examples


   $ACML_GPU    - Folder where AMD Core Math Library with GPU support is 
                  installed.
                      This release provides static and dynamic versions
                      of the library. 
                      $AMDSDK_ROOT/acml_gpu/gfortran64/lib
                      $AMDSDK_ROOT/acml_gpu/gfortran64/include
                      To use these libraries, please make appropriate 
                      changes in your build (Makefile) environment.
                      Examples are provided in
                      - $AMDSDK_ROOT/acml_gpu/gfortran64/examples

   $AMD_LIBM    - Folder where AMD optimized Math Library is installed.
                      This release provides static and dynamic versions
                      of the library. 
                      $AMDSDK_ROOT/amdlibm-2-1-lin64/lib/dynamic
                      $AMDSDK_ROOT/amdlibm-2-1-lin64/lib/static
                      $AMDSDK_ROOT/amdlibm-2-1-lin64/include
                      To use these libraries, please make appropriate 
                      changes in your build (Makefile) environment.
                      If you use dynamic version of the library please set,
                      LD_LIBRARY_PATH=$AMDSDK_ROOT/amdlibm-2-1-lin64/lib/dynamic

