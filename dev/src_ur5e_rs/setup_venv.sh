# !/bin/bash

ENV="venv"

# sudo apt install python3.9
# sudo apt install python3.9-venv
python3 -m venv ${ENV}
source ${ENV}/bin/activate

#python3 -m pip install -r requirements.txt
pip install numpy
pip install matplotlib
pip install pandas
pip install opencv-python
pip install pyrealsense2
# pip install pyyaml
# pip install pyglet==1.5.27
pip install open3d  # ==0.9.0

sudo chown -R ${USER}:${USER} ${ENV}
