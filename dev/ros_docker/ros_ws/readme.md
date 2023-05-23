# ROS2 Creating a Workspace

0. Following [Robotic Sea Bass ROS+Docker](https://roboticseabass.com/2021/04/21/docker-and-ros/) example
1. [Install Docker](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script)
2. Build Nvidia-based image for visualization
3. Install Nvidia container support dependencies: [Nvidia on Docker](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
4. Run docker image with CDI devices specified as following:
   `podman run --rm --device nvidia.com/gpu=all ubuntu nvidia-smi -L`

## Creating a ROS2 Docker Workspace

Create a Nvidia-based docker for graphics

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
xhost +
```

Run docker image:

```bash
docker run -it --net=host --gpus all --device=/dev/dri:/dev/dri \
    --env="NVIDIA_DRIVER_CAPABILITIES=all" \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    nvidia_ros \
    bash
```
