FROM ubuntu:18.04

RUN apt-get update &&\
    apt-get install -y software-properties-common &&\
    add-apt-repository ppa:deadsnakes/ppa &&\
    apt-get update &&\
    apt-get install -y python3.7 python3-pip &&\
    apt-get install -y build-essential libssl-dev libffi-dev python3.7-dev &&\
    apt-get install -y python3.7-venv

