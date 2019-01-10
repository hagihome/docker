# Install Nvidia Docker 2

## prerequisites
- kernel version > 3.10
```text
>uname -a
Linux Ubuntu18 4.15.0-43-generic #46-Ubuntu SMP Thu Dec 6 14:45:28 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
```
- docker >= 1.12
```text
>docker version
Client:
 Version:           18.09.0
 API version:       1.39
 Go version:        go1.10.4
 Git commit:        4d60db4
 Built:             Wed Nov  7 00:49:01 2018
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          18.09.0
  API version:      1.39 (minimum version 1.12)
  Go version:       go1.10.4
  Git commit:       4d60db4
  Built:            Wed Nov  7 00:16:44 2018
  OS/Arch:          linux/amd64
  Experimental:     false
```
- NVIDIA GPU with architecture > Fermi(2.1)
- NVIDIA driver ~= 361.93 ( untested on older versions)
```text
>nvidia-smi | grep "Driver Version"
| NVIDIA-SMI 410.79       Driver Version: 410.79       CUDA Version: 10.0     |
```

## Installing version 2.0
If you installed nvidia-docker 1.0, you must remove it.
1. install the repository for your distribution
```text
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
```
1. install the nvidia-docker2 package and reload the Docker daemon configuration:
```text
sudo apt install nvidia-docker2
sudo pkill -SIGHUP dockerd
```

## Basic usage
docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi

## How do I get nvidia docker images
You check [nvidia/cuda on dockerhub](https://hub.docker.com/r/nvidia/cuda/).
For example, you want to use CUDA 10.0 and CUDNN7 with the compiler toolchain, the debugging tools, the headers and the static libraries, you write following text in Dockerfile.
```text
FROM nvidia/cuda:10.0-cudnn7-devel
```
Maybe its format is "From nvidia/cuda:&lt;using version&gt;".

## build keras environment
check Dockerfile and requirements.txt
do docker command:
```text
docker build -t keras_on_cuda10_cudnn7 .
```
run the container
```text
mkdir -p ~/work/localhost/keras
docker container run -it --rm --runtime=nvidia -v ~/work/localhost/keras:/keras -w /keras keras_on_cuda9_cudnn7
```
