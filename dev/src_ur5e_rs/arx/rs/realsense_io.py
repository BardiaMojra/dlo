"""Demonstrate RealSense camera discovery and frame capture"""

import open3d as o3d
import yaml

from nbug import *
from pdb import set_trace as st

rs_cfg_fname = "rs_cfg.yml"
odir = "./out/"
rgbd_log_fname = "rs_rgbd_streams.bag"

if __name__ == "__main__":

  o3d.t.io.RealSenseSensor.list_devices() #
  st()
  rscam = o3d.t.io.RealSenseSensor()
  rscam.start_capture()
  print(rscam.get_metadata())

  st()
  for fid in range(5):
    rgbd_frame = rscam.capture_frame()
    o3d.io.write_image(f"color{fid:05d}.jpg", rgbd_frame.color.to_legacy())
    o3d.io.write_image(f"depth{fid:05d}.png", rgbd_frame.depth.to_legacy())
    print("Frame: {}, time: {}s".format(fid, rscam.get_timestamp() * 1e-6))

    rscam.stop_capture()
