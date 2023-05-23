#!/bin/bash

# if [ "$EUID" -ne 0 ]
#   then echo "Please run as root..."
#   exit
# fi

function pause(){
  echo " " && echo " "
  read -s -n 1 -p "press any key to continue..."
  echo " " && echo " "
}

help()
{
  echo "usage: ./rs_parsebag.sh [bag file] [file tag]"
  echo "e.g.: ./rs_parsebag.sh 00001.bag t001"
  echo "file tag: e.g. t001"
  echo "-i <ros-bag-file>	ROS-bag filename"
  echo "-p <png-path>	convert to PNG, set output path to png-path"
  echo "-v <csv-path>	convert to CSV, set output path to csv-path, supported formats: depth, color, imu, pose"
  echo "-r <raw-path>	convert to RAW, set output path to raw-path"
  echo "-l <ply-path>	convert to PLY, set output path to ply-path"
  echo "-b <bin-path>	convert to BIN (depth matrix), set output path to bin-path"
  echo "-T	convert to text (frame dump) output to standard out"
  echo "-d	convert depth frames only"
  echo "-c	convert color frames only"
}

echo " " && echo " "
echo "--->> parsing rs bag file: $1"
echo "--->> tag: $2"
echo " " && echo " "
# pause

# mkdir png csv raw ply bin
mkdir $(eval echo "$2")
mkdir -p "./$(eval echo "$2")/png"
mkdir -p "./$(eval echo "$2")/raw"
mkdir -p "./$(eval echo "$2")/ply"

echo " " && echo " "
echo "--->> parse images (.png) to: ./${2}/png/${2}_" && echo " " && echo " "
rs-convert -i $1 -p "./$(eval echo "$2")/png/${2}_"

# rs-convert -i $1 -v csv/${2}_ # seg faults


echo " " && echo " "
echo "--->> parse raw data (.raw) to: ./${2}/raw/${2}_" && echo " " && echo " "
rs-convert -i $1 -r "./${2}/raw/${2}_"


echo " " && echo " "
echo "--->> parse point clouds (.ply) to: ./${2}/ply/${2}_" && echo " " && echo " "
rs-convert -i $1 -l "./${2}/ply/${2}_"

echo " \-->>> $2 is done."


# echo " " && echo " "
# echo "--->> parse ply binary..." && echo " " && echo " "
# rs-convert -i $1 -b bin/${2}_
