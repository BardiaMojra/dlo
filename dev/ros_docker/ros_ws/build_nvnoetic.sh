#!/bin/bash
# Build the Dockerfile
docker build -f dockerfile_nvnoetic -t nvnoetic .

# Start a terminal
echo "build turtlebot3 base overlay image with:"
echo 'sudo bash build_tb3_base.sh'
