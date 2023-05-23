DOCKER_VOLUMES = \
    --volume="${PWD}/tb3_autonomy":"/overlay_ws/src/tb3_autonomy":rw \
    --volume="${PWD}/tb3_worlds":"/overlay_ws/src/tb3_worlds":rw \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw"
DOCKER_ENV_VARS = \
    --env="NVIDIA_DRIVER_CAPABILITIES=all" \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1"
DOCKER_ARGS = ${DOCKER_VOLUMES} ${DOCKER_ENV_VARS}

# Build the core image


.PHONY: build-core
build-core:
	# @docker build -f ./docker/dockerfile_nvidia_ros -t nvidia_ros .
	@bash build_nvnoetic.sh

# Build the base image
.PHONY: build-base
build-base:
	# @docker build -f ./docker/dockerfile_tb3_base -t turtlebot3_base .
	@bash build_tb3base.sh

# Build the overlay image (depends on base image build)
.PHONY: build
build: build-base
	# @docker build -f ./docker/dockerfile_tb3_overlay -t turtlebot3_overlay .
	@bash build_tb3autonomy.sh


# Start a terminal inside the Docker container
.PHONY: term
term:
    @docker run -it --net=host --gpus all \
        ${DOCKER_ARGS} turtlebot3_overlay bash

# Start basic simulation included with TurtleBot3 packages
.PHONY: sim
sim:
    @docker run -it --net=host --gpus all \
        ${DOCKER_ARGS} turtlebot3_overlay \
        roslaunch turtlebot3_gazebo turtlebot3_world.launch
