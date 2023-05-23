#!/bin/bash

# config
_cv_version="3.4.9"
_project_name='dlo' # used as sub-root directory folder

printf '\n\n\n\n ---->>> setting up opencv-%s source files...\n\n' ${_cv_version}
# setup

## dependencies
sudo apt update
sudo apt-get install build-essential -y # compiler
sudo apt-get install cmake -y
sudo apt-get install git -y
sudo apt-get install libgtk2.0-dev  -y
sudo apt-get install pkg-config  -y
sudo apt-get install libavcodec-dev -y
sudo apt-get install libavformat-dev  -y
sudo apt-get install libswscale-dev -y  # required dependencies
sudo apt-get install python-dev -y
sudo apt-get install python-numpy -y
sudo apt-get install libtbb2 -y
sudo apt-get install libtbb-dev -y
sudo apt-get install libjpeg-dev -y
sudo apt-get install libpng-dev -y
sudo apt-get install libtiff-dev -y
sudo apt-get install libjasper-dev  -y
sudo apt-get install libdc1394-22-dev -y # optional dependencies


sudo rm -rfv opencv-${_cv_version}
mkdir opencv-${_cv_version} && sudo chown ${USER:=$(/usr/bin/id -run)}:$USER opencv-${_cv_version}
cd opencv-$_cv_version

## setup submodules
git submodule add --force https://github.com/opencv/opencv.git opencv
cd opencv && git fetch
git checkout ${_cv_version}
cd ..
git submodule add --force https://github.com/opencv/opencv_contrib.git opencv_contrib
cd opencv_contrib && git fetch
git checkout ${_cv_version}
cd .. && tree -L 2

echo -e '\n\n\n ---->>> opencv setup finished, now configure and build via opencv_build.sh...\n\n'

# EOF
