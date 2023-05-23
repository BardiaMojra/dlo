#!/bin/bash

# run with
# sudo -u root -H -s bash venv_setup.sh

ENV="venv-o3d"

sudo apt install python3.10
sudo apt install python3.10-venv
python3 -m venv ${ENV}
source ${ENV}/bin/activate

#python3 -m pip install -r requirements.txt
pip install numpy
pip install matplotlib
pip install pandas
pip install opencv-contrib-python
pip install pyrealsense2
# pip install pyglet==1.5.27
pip install open3d

sudo chown -R ${USER}:${USER} ${ENV}
