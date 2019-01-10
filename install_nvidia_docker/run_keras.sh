#!/bin/bash
WORKDIR=`pwd`/work
docker container run -it --rm --runtime=nvidia \
	-v $WORKDIR:/work -w /work keras_on_cuda9_cudnn7
