#!/bin/bash

WORKDIR=`pwd`/sample

if [ ! -d $WORKDIR ]; then
  mkdir -p $WORKDIR
fi

xhost +si:localuser:$(whoami)

docker container run -it --rm -e USER_ID=$UID -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:ro -v $WORKDIR:/work -w /work ubuntu-modelsim

