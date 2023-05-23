# ROS2: Creating a workspace

## [ROS2: Creating a workspace](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.html)

```bash
#1. source ros env
source /opt/ros/humble/setup.bash

# 2. create workspace dir

mkdir -p ~/dlo_ws/src
cd ~/dlo_ws/src

#3. clone a sample repo
#   in /dlo_ws/src/, clone package source code
git clone https://github.com/ros/ros_tutorials.git -b humble-devel

# 4. resolve rependencies
cd ..
rosdep install -i --from-path src --rosdistro humble -y

# 5. build package
colcon build
#Other useful arguments for colcon build:
# --packages-up-to builds the package you want, plus all its dependencies, but not the whole workspace (saves time)
# --symlink-install saves you from having to rebuild every time you tweak python scripts
#--event-handlers console_direct+ shows console output while building (can otherwise be found in the log directory)

# 6. source the overlay
echo "open a new terminal"

source /opt/ros/humble/setup.bash
cd ~/dlo_ws
. install/local_setup.bash

# 6.1 run package
ros2 run turtlesim turtlesim_node
```
