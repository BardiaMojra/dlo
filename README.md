# DLO Dataset Paper - Master

## Tasks Assignments

- Paper structure and sections (Bardia, due Mon. 1/9)
- Data collection (Bardia & Chris, Wed. 1/11):
  - Test procedures: after background research --> discuss and revise
  - Learning from demonstration API, pick and place
  - Record UR5 movement commands
  - DLO configuration estimation via AprilTags
  - DLO free end pose estimation via AprilTags
- DLO mount update design and print (Maicol, Mon. 1/9)

## ToDo - Bardia

- Read:
  - [ ] [urdfpy - URDF parser in Python](https://urdfpy.readthedocs.io/en/latest/)
  - [ ] [Making Apriltags](https://berndpfrommer.github.io/tagslam_web/making_tags/#:~:text=Use%20an%20inkjet%20printer%20to,on%20the%20foam%20board%2C%20done.)
  - [ ] [6D pose est. with Apriltags](https://april.eecs.umich.edu/software/apriltag)
- [ ] UR5 tutorials
  - [ ] Ethernet access
  - [ ] program and record
  - [ ] pick and placement
- [ ] Setup work cell:
  - [ ] Update DLO mount
  - [ ] Print DLO mount
  - [ ] Order parts
  - [ ] Black cloth
  - [ ] AprilTags
- [ ] Write paper

## Important Links

- [Realsense docs](https://dev.intelrealsense.com/docs)
- [RealSense Tools](https://github.com/IntelRealSense/librealsense/tree/master/tools)

## Other Links

- [depth post-processing for intel rs d400 series](https://dev.intelrealsense.com/docs/depth-post-processing)

## Setup

### Hardware

- D455 - overhead depth camera
- L515 - gripper depth camera
- UR5e
- DLO

### Software Environment and Dependencies

- Ubuntu 20.04
- [LibRealSense v2.50.0](https://github.com/IntelRealSense/librealsense)
-

## Code and Dev

- [Intel Realsense (v2.5) Repo](https://github.com/IntelRealSense/librealsense)
-

## Test Goals

- Clamped end low, DLO on table and flat, change gripper pose, no
  twist on DLO:\@ omega shape, s shape, u shape, circle shape, ellipse shape,
  spiral.
- Clamped end low, DLO on table and 3D, with a twist: same shapes.
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

### Will not use ROS

- [ROS2 Foxy Fitzroy](https://docs.ros.org/en/foxy/Installation/Ubuntu-Install-Debians.html)
- [ROS2-legacy wrapper](https://github.com/IntelRealSense/realsense-ros/tree/ros2-legacy)
