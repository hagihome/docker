#!/bin/bash

xhost +si:localuser:$(whoami)
docker container run -it --rm \
	-e USER_ID=$UID -e DISPLAY \
	--device $(lsusb -d 0403:6010 | perl -pe 's!Bus\s(\d{3})\sDevice\s(\d{3}).*!/dev/bus/usb/\1/\2!') \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	-v ~/work/localhost/vivado:/work \
	-w /work ubuntu-vivado

