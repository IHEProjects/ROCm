FROM ubuntu:18.04

RUN apt-get update &&\
    apt-get install -y software-properties-common &&\
    add-apt-repository ppa:deadsnakes/ppa &&\
    apt-get install -y python3.7 python3-pip
