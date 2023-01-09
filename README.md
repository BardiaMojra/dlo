# DLO Dataset Paper - Master

## TOP

- [Paper on Overleaf](https://www.overleaf.com/project/63b719f4df73f6372419b627)
- [This master repo](https://github.com/BardiaMojra/dlo.git)

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

- [ ] Write paper
- Read:
- UR5
  - IP: 192.168.1.147
  - [ ] [urdfpy - URDF parser in Python](https://urdfpy.readthedocs.io/en/latest/)
  - [ ] program and record
  - [ ] pick and placement
  - [ ] [UR5 bullet sim](https://github.com/josepdaniel/ur5-bullet)
- [ ] Setup work cell:
  - [x] Order parts
  - [ ] Black cloth
- [ ] Gripper
- [ ] AprilTags
  - [ ] [Making Apriltags](https://berndpfrommer.github.io/tagslam_web/making_tags/#:~:text=Use%20an%20inkjet%20printer%20to,on%20the%20foam%20board%2C%20done.)
  - [ ] [6D pose est. with Apriltags](https://april.eecs.umich.edu/software/apriltag)

## ToDo - Maicol

- Update DLO mount design
- Print new design
- Setup CAD/Drawing
- DLO mount drawing

## Links

### UR5e Docs

- [UR5e script manual](https://s3-eu-west-1.amazonaws.com/ur-support-site/163530/scriptmanual_5.12.pdf)

### Important Links

- [Realsense docs](https://dev.intelrealsense.com/docs)
- [RealSense Tools](https://github.com/IntelRealSense/librealsense/tree/master/tools)
- [Intel Realsense (v2.5) Repo](https://github.com/IntelRealSense/librealsense)
- [Cobot control via python sockets](https://axisnj.com/controlling-a-universal-robots-cobot-using-python/)

### Other Links

- [depth post-processing for intel rs d400 series](https://dev.intelrealsense.com/docs/depth-post-processing)

### Software Environment and Dependencies

- Ubuntu 20.04
- [LibRealSense v2.50.0](https://github.com/IntelRealSense/librealsense)
- Python

## Setup

### Hardware

- D455 - overhead depth camera
- L515 - gripper depth camera (maybe)
- UR5e
- DLOs
- DLO Mount

### Installation

```bash
pip install urdfpy
pip install pyrealsense2
```

## Test Goals

- Clamped end low, DLO on table and flat, change gripper pose, no
  twist on DLO:\@ omega shape, s shape, u shape, circle shape, ellipse shape,
  spiral.
- Clamped end low, DLO on table and 3D, with a twist: same shapes.
- Clamped end low, DLO angles at 30 degrees and 3D, without a twist.
- Clamped end low, DLO angles at 45 degrees and 3D, without a twist.
- Clamped end low, DLO angles at 60 degrees and 3D, without a twist.
- Clamped end low, DLO angles at 75 degrees and 3D, without a twist.
- Clamped end low, DLO angles at 90 degrees and 3D, without a twist.
- Clamped end low, DLO angles at 30 degrees and 3D, with a twist.
- Clamped end low, DLO angles at 45 degrees and 3D, with a twist.
- Clamped end low, DLO angles at 60 degrees and 3D, with a twist.
- Clamped end low, DLO angles at 75 degrees and 3D, with a twist.
- Clamped end low, DLO angles at 90 degrees and 3D, with a twist.

## DLOs and Cables

- Thick hose
- AWG 10 red and black and CAT-6 bundle
- CSA LL90485 Water resistant with three AWG 16 conductors
- Yellow Southwire E51583(UL) AWG 14 wire

## Archive

### Will not use ROS

- [ROS2 Foxy Fitzroy](https://docs.ros.org/en/foxy/Installation/Ubuntu-Install-Debians.html)
- [ROS2-legacy wrapper](https://github.com/IntelRealSense/realsense-ros/tree/ros2-legacy)
