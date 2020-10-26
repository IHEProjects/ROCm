FROM ubuntu:18.04

RUN apt-get update &&\
    apt-get install -y software-properties-common &&\
    add-apt-repository ppa:deadsnakes/ppa &&\
    apt-get update &&\
    apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev wget libbz2-dev &&\
    apt-get install -y python3 python3-pip python3-dev &&\
    apt-get install -y python3-venv &&\
    ln -s /usr/bin/python3 /usr/bin/python

RUN apt-get install -y curl git &&\
    git config --global color.ui false &&\
    git config --global user.email "quanpan302@hotmail.com" &&\
    git config --global user.name "quanpan302"

RUN mkdir -p ~/bin/ &&\
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo &&\
    chmod a+x ~/bin/repo &&\
    mkdir -p ~/ROCm/ &&\
    cd ~/ROCm/ &&\
    ~/bin/repo init -u https://github.com/RadeonOpenCompute/ROCm.git -b roc-3.8.x &&\
    ~/bin/repo sync
    