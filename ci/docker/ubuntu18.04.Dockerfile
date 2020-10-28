FROM ubuntu:18.04

# 0 Download ROCm source code
# 0.1 Essentials
RUN apt-get update &&\
    apt-get install -y software-properties-common &&\
    add-apt-repository ppa:deadsnakes/ppa &&\
    apt-get update &&\
    apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev wget libbz2-dev &&\
    apt-get install -y python3 python3-pip python3-dev &&\
    apt-get install -y python3-venv &&\
    ln -s /usr/bin/python3 /usr/bin/python

# 0.2 Git
RUN apt-get install -y curl git &&\
    git config --global color.ui false &&\
    git config --global user.email "quanpan302@hotmail.com" &&\
    git config --global user.name "quanpan302"

# 0.3 Download ROCm
RUN mkdir -p ~/bin/ &&\
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo &&\
    chmod a+x ~/bin/repo &&\
    mkdir -p ~/ROCm/ &&\
    cd ~/ROCm/ &&\
    ~/bin/repo init -u https://github.com/RadeonOpenCompute/ROCm.git -b roc-3.8.x &&\
    ~/bin/repo sync

# 1 Required Distribution Packages
# 1.1 Debian or Ubuntu Packages
# 1.2 Additional packages used by rocgdb
RUN apt-get install cmake g++-5 g++ pkg-config libpci-dev libnuma-dev libelf-dev libffi-dev git python libopenmpi-dev gawk mesa-common-dev &&\
    apt-get install texinfo libbison-dev bison flex libbabeltrace-dev python-pip libncurses5-dev liblzma-dev

RUN python -m pip install CppHeaderParser argparse

# 2 Verify KFD Driver
RUN wget -qO - http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key | sudo apt-key add - &&\
    echo 'deb [arch=amd64] http://repo.radeon.com/rocm/apt/debian/ xenial main' | sudo tee /etc/apt/sources.list.d/rocm.list &&\
    apt-get update &&\
    apt-get install rock-dkms


# 3 Create the Unix Video Group
RUN echo 'SUBSYSTEM=="kfd", KERNEL=="kfd", TAG+="uaccess", GROUP="video"' | sudo tee /etc/udev/rules.d/70-kfd.rules &&\
    usermod -a -G video $USER

# 4 Clone and Build AOMP
RUN cd $HOME &&\
    mkdir -p git/aomp11 &&\
    cd git/aomp11 &&\
    git clone https://github.com/rocm-developer-tools/aomp &&\
    cd $HOME/git/aomp11/aomp/bin

