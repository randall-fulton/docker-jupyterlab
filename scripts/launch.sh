#!/bin/bash

START_DIR=$(pwd)

cd /jupyter-init.d/
if [ -f requirements.txt ]; then
    pip3 install -r requirements.txt
fi
cd $START_DIR

su -m $DOCKER_USER -c "jupyter lab --allow-root --ip=* --port=8888 --no-browser --notebook-dir=/notebooks"
