# Building PyTorch for ROCm

## Install or update rocm-dev on the host system:

```
echo $(cat /sys/module/amdgpu/version)

sudo apt-get install rocm-dev
or
sudo apt-get update
sudo apt-get upgrade
```

## Obtain docker image:

```
sudo systemctl start docker.socket

docker pull rocm/pytorch

```

## Start a docker container:

```
sudo docker run -it --name=rocm-pytorch -v /mnt/Data/GPU-ROCm/AI/Data:/data --privileged --rm --device=/dev/kfd --device=/dev/dri --group-add video rocm/pytorch
```

## Install lsmod in docker container:

```
apt-get install kmod -y
```

## Check CPU, GPU, OpenCL info in docker container:

```
rocminfo

clinfo
```

## Confirm working installation in docker container:

```
PYTORCH_TEST_WITH_ROCM=1 python3.6 test/run_test.py –-verbose

>/src/external/hip-on-vdi/rocclr/hip_code_object.cpp:92: guarantee(false && "hipErrorNoBinaryForGpu: Coudn't find binary for current devices!")
Aborted (core dumped)
```

> No tests will fail if the compilation and installation is correct.


## Install torchvision in docker container:

```
pip install torchvision
```


## Clean docker cache on host system:

```
docker system prune -f
```

# Dockerfile

```
docker build --rm -f ./ci/ubuntu18.04.Dockerfile -t rocm:latest .
```
