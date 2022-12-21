# Task Manager

## ToDo

- Setup ROS2 for L515 data processing
- Read from reading list
- Setup work cell
- Order parts
- Write paper

## Project Setup

- Ubuntu 20.04
- [ROS2 Foxy Fitzroy](https://docs.ros.org/en/foxy/Installation/Ubuntu-Install-Debians.html)
- [LibRealSense v2.50.0](https://github.com/IntelRealSense/librealsense)
- [ROS2-legacy wrapper](https://github.com/IntelRealSense/realsense-ros/tree/ros2-legacy)

## Reading List

[x] L515 datasheet
[x] L515 User Guide
[] Realsense docs [link](https://dev.intelrealsense.com/docs)
[] ROS2 docs
[] Realsense docs

## Test Goals

- Clamped end low, DLO on table and flat, change gripper pose, no
  twist on DLO:\@ omega shape, s shape, u shape, circle shape, ellipse shape,
  spiral.
- Clamped end low, DLO on table and 3D, with twist: same shapes.
- Clamped end low, DLO angles at 30 degrees and 3D, without twist.
- Clamped end low, DLO angles at 45 degrees and 3D, without wist.
- Clamped end low, DLO angles at 60 degrees and 3D, without twist.
- Clamped end low, DLO angles at 75 degrees and 3D, without twist.
- Clamped end low, DLO angles at 90 degrees and 3D, without twist.
- Clamped end low, DLO angles at 30 degrees and 3D, with twist.
- Clamped end low, DLO angles at 45 degrees and 3D, with twist.
- Clamped end low, DLO angles at 60 degrees and 3D, with twist.
- Clamped end low, DLO angles at 75 degrees and 3D, with twist.
- Clamped end low, DLO angles at 90 degrees and 3D, with twist.

## DLOs and Cables

- Thick hose
- AWG 10 red and black and CAT-6 bundle
- CSA LL90485 Water resistant with three AWG 16 conductors
- Yellow Southwire E51583(UL) AWG 14 wire
