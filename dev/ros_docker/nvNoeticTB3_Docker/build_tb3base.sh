
# Build the Dockerfile
docker build -f dockerfile_tb3base -t tb3base .

# Start a terminal
echo "run docker with:"
echo "bash run_tb3base.sh"
# echo "sudo bash run_tb3b_gazebo_empty_world.sh tb3_base 'roslaunch gazebo_ros empty_world.launch'"
