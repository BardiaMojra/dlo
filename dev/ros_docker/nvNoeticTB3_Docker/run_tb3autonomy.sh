#!/bin/bash
# Sample script to run a command in a Docker container
#
# Usage Example:
# ./run_docker.sh turtlebot3_behavior:base "ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py"

# Define Docker volumes and environment variables

DOCKER_DEVICES="
--gpus all --device=/dev/dri:/dev/dri
"

DOCKER_VOLUMES="
--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
--volume="${PWD}/tb3_autonomy":"/overlay_ws/src/tb3_autonomy":rw \
--volume="${PWD}/tb3_worlds":"/overlay_ws/src/tb3_worlds":rw \

"
DOCKER_ENV_VARS="
--env="NVIDIA_DRIVER_CAPABILITIES=all" \
--env="DISPLAY" \
--env="QT_X11_NO_MITSHM=1" \
--env="TERM=xterm-256color" \
"
DOCKER_ARGS=${DOCKER_DEVICES}" "${DOCKER_VOLUMES}" "${DOCKER_ENV_VARS}

xhost + # Add default user to xhost

# Run the command
docker run -it --net=host --ipc=host $DOCKER_ARGS tb3base bash
#  "roslaunch gazebo_ros empty_world.launch" # $1 bash -c "$2"
