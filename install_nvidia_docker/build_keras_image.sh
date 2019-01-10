#!/bin/bash

if [ -e requirements.txt ]; then
	rm -f requirements.tt
fi
touch requirements.txt
echo Pillow >> requirements.txt
echo numpy >> requirements.txt
echo tensorflow-gpu >> requirements.txt
echo pydot >> requirements.txt
echo keras >> requirements.txt

docker build -t keras_on_cuda10_cudnn7 .

