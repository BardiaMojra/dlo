# ROS2 Creating a Workspace (Nvidia ROS2 )

## Tutorial

- Tutorial: [Robotic Sea Bass ROS+Docker TurtleBot3 Sim](https://roboticseabass.com/2021/04/21/docker-and-ros/).
- Code: [sea-bass: turtlebot3_behavior_demos](https://github.com/sea-bass/turtlebot3_behavior_demos).

## Other Links

- [Install Docker](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script)
- Build Nvidia-based image for visualization
- Install Nvidia container support dependencies: [Nvidia on Docker](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

## Robotic Sea Bass ROS+Docker

Create an Nvidia-based docker for graphics

Dockerfile:

```dockerfile
FROM nvidia/cudagl:11.1.1-base-ubuntu20.04
 # Minimal setup
RUN apt-get update \
 && apt-get install -y locales lsb-release
ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg-reconfigure locales
 # Install ROS Noetic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update \
 && apt-get install -y --no-install-recommends ros-noetic-desktop-full
RUN apt-get install -y --no-install-recommends python3-rosdep
RUN rosdep init \
 && rosdep fix-permissions \
 && rosdep update
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
```

Build the Dockerfile:

```bash
docker build -t nvidia_ros .
```

Add default user to xhost:

```bash
xhost + local:docker
```

Run docker image:

```bash
docker run -it --net=host --gpus all --device=/dev/dri:/dev/dri \
    --env="NVIDIA_DRIVER_CAPABILITIES=all" \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --env="TERM=xterm-256color" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    nvidia_ros \
    bash
```

Run turtlebot tele-op simulation control by spawning three terminals:

```bash
# 1
bash run_tb3b.sh
# enter in docker terminal
roscore

# 2
bash run_tb3b.sh
# enter in docker terminal
roslaunch turtlebot3_gazebo turtlebot3_world.launch

# 3
bash run_tb3b.sh
# enter in docker terminal
roslaunch turtlebot3_teleop turtlebot3_teleop_key.launch

```
