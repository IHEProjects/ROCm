FROM ubuntu:18.04


# 0 Install requirements
# ======================

# 0.1 Essentials
# --------------

RUN apt-get update &&\
    apt-get install -y software-properties-common &&\
    add-apt-repository ppa:deadsnakes/ppa &&\
    apt-get update &&\
    apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev wget libbz2-dev &&\
    apt-get install -y python3 python3-pip python3-dev &&\
    apt-get install -y python3-venv &&\
    ln -s /usr/bin/python3 /usr/bin/python

# 0.2 Git
# -------

RUN apt-get install -y curl git &&\
    git config --global color.ui false &&\
    git config --global user.email "quanpan302@hotmail.com" &&\
    git config --global user.name "quanpan302"


# 1 Required Distribution Packages
# ================================
# Debian or Ubuntu Packages
# &
# Additional packages used by rocgdb

RUN apt-get install -y cmake g++-5 g++ pkg-config libpci-dev libnuma-dev libelf-dev libffi-dev git python libopenmpi-dev gawk mesa-common-dev &&\
    apt-get install -y texinfo libbison-dev bison flex libbabeltrace-dev python-pip libncurses5-dev liblzma-dev

RUN python -m pip install CppHeaderParser argparse


# 2 Verify KFD Driver
# ===================

RUN wget -qO - http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key | apt-key add - &&\
    echo 'deb [arch=amd64] http://repo.radeon.com/rocm/apt/debian/ xenial main' | tee /etc/apt/sources.list.d/rocm.list &&\
    apt-get update &&\
    apt-get install -y rock-dkms


# 3 Create the Unix Video Group
# =============================

RUN echo 'SUBSYSTEM=="kfd", KERNEL=="kfd", TAG+="uaccess", GROUP="video"' | tee /etc/udev/rules.d/70-kfd.rules
# RUN usermod -a -G video $USER


# 4 Clone and Build AOMP
# ======================

# 4.1 Download source code
# ------------------------

# RUN mkdir -p ~/bin/ &&\
#     curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo &&\
#     chmod a+x ~/bin/repo &&\
#     mkdir -p ~/ROCm/

# 4.1a Download ROCm source code
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# >ls $HOME/ROCm
# >HIP                   ROCclr                hipCUB             rocSPARSE
# >HIP-Examples          ROCdbgapi             hipSPARSE          rocThrust
# >HIPIFY                ROCgdb                hipfort            rocm-cmake
# >MIOpen                ROCm-CompilerSupport  llvm_amd-stg-open  rocm_bandwidth_test
# >MIOpenGEMM            ROCm-Device-Libs      rccl               rocm_smi_lib
# >MIVisionX             ROCm-OpenCL-Runtime   rocALUTION         rocminfo
# >RCP                   ROCmValidationSuite   rocBLAS            rocprofiler
# >ROC-smi               aomp                  rocFFT             rocr_debug_agent
# >ROCK-Kernel-Driver    atmi                  rocPRIM            roctracer
# >ROCR-Runtime          clang-ocl             rocRAND
# >ROCT-Thunk-Interface  hipBLAS               rocSOLVER
# >
# >ls $HOME/ROCm/aomp
# amd-llvm-project  flang           rocm-compilersupport  rocr-runtime
# aomp              hip-on-vdi      rocm-device-libs      roct-thunk-interface
# aomp-extras       opencl-on-vdi   rocminfo              vdi

# RUN cd ~/ROCm/ &&\
#     ~/bin/repo init -u https://github.com/RadeonOpenCompute/ROCm.git -b roc-3.8.x &&\
#     ~/bin/repo sync

# 4.1b Download AOMP source code
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

RUN mkdir -p ~/git/aomp11 &&\
    cd ~/git/aomp11 &&\
    git clone https://github.com/rocm-developer-tools/aomp &&\
    cd ~/git/aomp11/aomp/bin

# 4.1b-1 For the Development Branch
# '''''''''''''''''''''''''''''''''
# >Branch 'amd-stg-openmp' set up to track remote branch 'amd-stg-openmp' from 'origin'.
# >Switched to a new branch 'amd-stg-openmp'

# RUN cd ~/git/aomp11/aomp &&\
#     git checkout amd-stg-openmp &&\ 
#     git pull

# 4.1b-2 For the Release Branch
# '''''''''''''''''''''''''''''
# >Note: checking out 'rel_11.7-1'.
# >
# >You are in 'detached HEAD' state. You can look around, make experimental
# >changes and commit them, and you can discard any commits you make in this
# >state without impacting any branches by performing another checkout.
# >
# >If you want to create a new branch to retain commits you create, you may
# >do so (now or later) by using -b with the checkout command again. Example:
# >
# >  git checkout -b <new-branch-name>
# >
# >HEAD is now at 77a673a Update sha keys for comgr, device-libs, rocminfo

# RUN cd ~/git/aomp11/aomp &&\
#     git checkout rel_11.7-1 &&\ 
#     git pull &&\
#     export AOMP_CHECK_GIT_BRANCH=0

# 4.1b-3 Clone AOMP
# '''''''''''''''''
# >ls $HOME/git/aomp11
# >ROCdbgapi         aomp-extras    rocm-compilersupport  rocr-runtime
# >ROCgdb            flang          rocm-device-libs      roct-thunk-interface
# >amd-llvm-project  hip-on-vdi     rocminfo              roctracer
# >aomp              opencl-on-vdi  rocprofiler           vdi

RUN cd ~/git/aomp11/aomp/bin &&\
    ./clone_aomp.sh


# 4.2 Build
# ---------

# 4.2a Build from ROCm source code
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# RUN cd ~/ROCm/aomp

# 4.2b Build from AOMP source code
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

RUN cd ~/git/aomp11/aomp/bin &&\
    ./build_aomp.sh
