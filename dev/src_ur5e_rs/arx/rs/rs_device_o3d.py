
import logging, yaml
from datetime import datetime

import numpy as np
import pyrealsense2 as rs
import cv2
from nbug import *
from pdb import set_trace as st
import os.path as op
from config import configuration as cfg_cls


class rsDevice:
  ''' realsense depth camera device class
    @brief this class/mod handles realsense camera config, init, and API.
    @link https://intelrealsense.github.io/librealsense/python_docs/_generated/pyrealsense2.html
  '''
  def __init__(self, *args, **kwargs):
    #todo load from cfg
    self.todir = None
    self.pc_file = None
    self.rgb_file = None
    self.dm_file = None
    self.pc_dir = None
    self.rgb_dir = None
    self.dm_dir = None
    self.bag_file = None
    # internal
    self.freq = 30 # Hz
    self.rscam_id = 0 #
    self.wait_for_fr_en = True
    self.live_align_fr_en = True
    # self.sav_bagfile = True

  def load_cfg(self, cfg):
    self.todir = cfg.todir
    self.pc_file = cfg.pc_file
    self.rgb_file = cfg.rgb_file
    self.dm_file = cfg.dm_file
    self.pc_dir = cfg.pc_dir
    self.rgb_dir = cfg.rgb_dir
    self.dm_dir = cfg.dm_dir
    self.bag_file = cfg.bag_file

    return # load_cfg()

  def shw_rs_devices(self):
    st()
    # o3d.io.RealSenseSensor.list_devices() # list devices
    connect_device = []
    for d in rs.context().devices:
      if d.get_info(rs.camera_info.name).lower() != 'platform camera':
        serial = d.get_info(rs.camera_info.serial_number)
        product_line = d.get_info(rs.camera_info.product_line)
        device_info = (serial, product_line) # (serial_number, product_line)
        connect_device.append( device_info )
        # @link https://intelrealsense.github.io/librealsense/doxygen/rs__sensor_8h.html#aa607d93c1bac40af3ec1c9b0345f59af
        logging.info(f"product line: {product_line}, serial number: {serial}")
    st()
    return connect_device

  def init_rscam_cfg(self, *args, **kwargs):


    self.rs_cfg = o3d.t.io.RealSenseSensorConfig(*args, **kwargs)
    if not os.path.exists(self.rs_cfg_file):
      with open(self.rs_cfg_file, 'w') as f:
        yaml.dump(self.rs_cfg, f)
    return self.rs_cfg

  def load_rscam_cfg(self, fname):
    self.rs_cfg_file = fname
    if not os.path.exists(fname):
      with open(fname, 'w') as f:
        self.rs_cfg = yaml.load(f, Loader="UnsafeLoader")
    else:
      logging.error("file already exists, f{fname}.")
    return self.rs_cfg

  def init_recorder(self):
    self.shw_rs_devices() # list devices
    st()
    self.rscam = o3d.t.io.RealSenseSensor()
    print(self.rscam.get_metadata())
    self.rs_cfg = self.init_rscam_cfg()
    self.rscam.init_sensor(self.rs_cfg, 0, self.bag_file)
    return # init()

  def recorder_start(self):
    self.rscam.start_capture(True) # true: start recording with capture
    return

  def recorder_stop(self):
    self.rscam.stop_capture()
    return



  def get_frames(self):
    return self.rscam.capture_frame(self.wait_for_fr_en, self.live_align_fr_en)  # wait for frames and align them

  def process_bag(self):
    if os.path.splitext(self.bag_file)[1] != ".bag":
      logging.error(f"bag file not of correct file format: {self.bag_file}")
      exit()
    try:
      pipe = rs.pipeline()
      config = rs.config()
      rs.config.enable_device_from_file(config, self.bag_file)

      # Configure the pipeline to stream the depth stream
      # Change this parameters according to the recorded bag file resolution
      config.enable_stream(rs.stream.depth, rs.format.z16, 30)

      # Start streaming from file
      pipeline.start(config)

      # Create opencv window to render image in
      cv2.namedWindow("Depth Stream", cv2.WINDOW_AUTOSIZE)

      # Create colorizer object
      colorizer = rs.colorizer()

      # Streaming loop
      while True:
          # Get frameset of depth
          frames = pipeline.wait_for_frames()

          # Get depth frame
          depth_frame = frames.get_depth_frame()

          # Colorize depth frame to jet colormap
          depth_color_frame = colorizer.colorize(depth_frame)

          # Convert depth_frame to numpy array to render image in opencv
          depth_color_image = np.asanyarray(depth_color_frame.get_data())

          # Render image in opencv window
          cv2.imshow("Depth Stream", depth_color_image)
          key = cv2.waitKey(1)
          # if pressed escape exit program
          if key == 27:
              cv2.destroyAllWindows()
              break

  finally:
      pass

    i = 0 # frame cntr
    fr_0 = self.init_bagRdr()

    while not self.bagRdr.is_eof():
      # process im_rgbd.depth and im_rgbd.color
      im_rgbd = self.bagRdr.next_frame()

      self.sav_frames(frames)
      o3d.io.write_image(f"color{fid:05d}.jpg", rgbd_frame.color.to_legacy())
      o3d.io.write_image(f"depth{fid:05d}.png", rgbd_frame.depth.to_legacy())
      print("Frame: {}, time: {}s".format(fid, rscam.get_timestamp() * 1e-6))
      st()

  rscam.bagRdr.close()



  def init_bagRdr(self):
    self.bagRdr = o3d.t.io.RSbagReader()
    self.bagRdr.open(self.bag_file)
    im_rgbd = self.bagRdr.next_frame()



    return im_rgbd

  def sav_frames(self, idx, frames, prt_time=True):
    t0 = datetime.now() # time tag
    rgb_fname = osp.join(self.rgb_dir, f"rgb_{idx:05d}.jpg")
    d_fname = osp.join(self.d_dir, f"d_{idx:05d}.png")
    o3d.io.write_image(rgb_fname, frames.color.to_legacy())
    o3d.io.write_image(d_fname, frames.depth.to_legacy())
    dt = datetime.now() - t0
    logging.info("idx: {:07d}, ttag: {:07d}s, ttw: {:07d}".format(idx, self.rscam.get_timestamp() * 1e-6, dt))

    st()

    return


def main():

  cfg = cfg_cls("rsDevice cfg")
  cfg.init()

  rscam = rsDevice()
  rscam.load_cfg(cfg) # config

  rscam.init_recorder()
  st()
  rscam.recorder_start()
  keep_running = True
  try:
    while keep_running:

      ''' get new state and frame '''
      #todo ---------------------------->> frame
      frames = rscam.get_frames() # saves to file


      #vis_render2D(frames)

      #prt_state(idx, state, idx_wp) # print state to terminal
      #shw_dframe(idx, dframe, idx_wp) # open interactive point cloud window

      ''' log state and frame '''
      #dset.log_st(idx, idx_wp, state)
      #dset.log_fr(idx, idx_wp, frames) #todo add fr dlogger


      #robot.check_waypoint(opt_st, rob_st) #todo add robot waypoint handler
  except KeyboardInterrupt:
    logging.info("keyboard interrupt recieved.")
    keep_running = False

  rscam.recorder_stop()
  logging.info("end of data collection.")

  st()
  logging.info('<<----- end of main ----->>')
  logging.info('<<----- post-processing ----->>')

  rscam.process_log()

  return # end of main


if __name__ == "__main__":
  main()
  print('---------   End   ---------')
