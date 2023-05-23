
'''
@author Bardia Mojra
@date 02/16/2023
@brief object oriented handle for pyrealsense 2 mod.
@link https://intelrealsense.github.io/librealsense/python_docs/_generated/pyrealsense2.html
'''

from ctypes import alignment
import logging
import numpy as np
import pyrealsense2 as rs
import cv2
import os.path as osp

# from config import configuration as cfg_cls

# nbug
from pdb import set_trace as st
from nbug import *

#todo: config
BAG_DIR = "../out/001_basic_x_2023-03-05_12-13-15/frames/"
FREQUENCY = 30 # Hz


global pipe
global rs_cfg
global pwrap
global pprof
global aprof
global playback
global depth_sensor
global depth_prof
global align
global pc
global decimate
global colorizer
global depth_intrinsics
class rsParser:
  ''' realsense parser class
    @brief this class/mod handles realsense camera config, init, and API.
    @link https://intelrealsense.github.io/librealsense/python_docs/_generated/pyrealsense2.html
  '''
  # class static vars
  def __init__(self, bag_dir, *args, **kwargs):
    # gen cfg
    self.bag_dir = bag_dir
    self.todir = bag_dir #"../out/"
    self.freq = FREQUENCY # Hz
    self.prev_tstamp = 0.0
    self.nFrs = 32
    # feat_en
    self.del_bagfile_en = True
    # internal vars
    self.bag_file = "None"
    self.img_dir = None
    self.dep_dir = None
    self.ply_dir = None
    self.dcm_dir = None
    self.w = None
    self.h = None
    # init
    self.init_cfg()

  def load_cfg(self, cfg):
    self.todir = cfg.rs_dir
    self.freq = cfg.rs_freq
    self.init_cfg()
    return # load_cfg()

  def init_cfg(self):
    self.bag_file = osp.join(self.bag_dir, "rsDevice.bag")
    if not os.path.isfile(self.bag_file):
      logging.error("bag_file is None.")
      print("bag_file is None.")
      exit()
    # dirs
    self.img_dir = osp.join(self.todir, "image/")
    self.dep_dir = osp.join(self.todir, "depth/")
    self.ply_dir = osp.join(self.todir, "pointcloud/")
    self.dcm_dir = osp.join(self.todir, "depth_color_map/")
    self.init_dir(self.img_dir)
    self.init_dir(self.dep_dir)
    self.init_dir(self.ply_dir)
    self.init_dir(self.dcm_dir)
    logging.info(f"img_dir: {self.img_dir}")
    logging.info(f"dep_dir: {self.dep_dir}")
    logging.info(f"ply_dir: {self.ply_dir}")
    logging.info(f"dcm_dir: {self.dcm_dir}")
    return # init_cfg()




  def init_parser(self):
    global aprof, pipe, rs_cfg, pwrap, pprof, pc, colorizer, align, playback
    # align = rs.align(rs.stream.color)
    print("reset start")
    ctx = rs.context()
    devices = ctx.query_devices()
    for dev in devices:
      dev.hardware_reset()
    print("reset done")
    pipe = rs.pipeline()
    rs_cfg = rs.config()
    # pprof = rs_cfg.resolve(rs_cfg)
    rs.config.enable_device_from_file(rs_cfg, self.bag_file)
    rs_cfg.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, self.freq)
    rs_cfg.enable_stream(rs.stream.color, 640, 480, rs.format.rgb8, self.freq)
    logging.info(f"parse from file: {self.bag_file}.")
    # pwrap = rs.pipeline_wrapper(pipe)
    # pprof = rs_cfg.resolve(pwrap)
    aprof = pipe.start(rs_cfg)
    playback = aprof.get_device().as_playback()
    playback.set_real_time(False)
    ptime = playback.get_duration().seconds
    print(f"playback duration: {ptime} seconds")
    # intr = aprof.get_stream(rs.stream.color).as_video_stream_profile().get_intrinsics()
    pc = rs.pointcloud()
    colorizer = rs.colorizer()
    logging.info(f"parser initialized.")
    return

  def init_dir(self, subdir):
    if not os.path.exists(subdir):
      os.makedirs(subdir)
      logging.info(f"dir {subdir} is created!")
    return subdir

  def cleanup(self):
    if self.del_bagfile_en and os.path.exists(self.bag_file): # type: ignore
      os.remove(self.bag_file)  # type: ignore
    return

  def get_frames(self, idx):
    global pipe, align, points, pc, playback, prev_tstamp
    frs = frames_cls(idx=idx)
    # frame_type = 1
    # frames = pipe.try_wait_for_frames()
    # playback.pause()
    frame_present, frames = pipe.try_wait_for_frames()
    if not frame_present:
      print("Error: not all frames are extracted")
      return None
    frs.fidx = frames.get_frame_number()
    frs.tstamp = frames.get_timestamp()
    if frs.tstamp < self.prev_tstamp: return None
    else: self.prev_tstamp = frs.tstamp
    depth_frame = frames.get_depth_frame()
    color_frame = frames.get_color_frame()
    frs.depth = np.asanyarray(depth_frame.data)
    frs.rgb = np.asanyarray(color_frame.data)
    frs.dcmap = cv2.applyColorMap(cv2.convertScaleAbs(frs.depth, alpha=0.03), cv2.COLORMAP_JET)
    tag = f"{frs.idx:06d}_{frs.tstamp}s_"
    self.sav_frames(tag, frs)
    points = pc.calculate(depth_frame)
    fname = self.ply_dir+tag+"pc.ply" # type: ignore
    points.export_to_ply(fname, color_frame)
    # playback.resume()

    return frs # get_frames()

  def start_streams(self):
    global pipe, rs_cfg, aprof
    aprof = pipe.start(rs_cfg)
    logging.info("start streams.")
    return

  def stop_streams(self):
    global pipe
    pipe.stop()
    logging.info("end streams.")
    return

  def init_vis2D(self):
    cv2.namedWindow('Color & Depth Streams', cv2.WINDOW_AUTOSIZE)
    #cv2.namedWindow("Depth Color Map Stream", cv2.WINDOW_AUTOSIZE)
    # cv2.resizeWindow(state.WIN_NAME, w, h)
    # cv2.setMouseCallback(state.WIN_NAME, mouse_cb)
    return

  def vis_render2D(self, frs):
    #dcmbgr = cv2.cvtColor(frs.dcmap, cv2.COLOR_RGB2BGR)
    #cv2.imshow("Depth Color Map Stream", dcmbgr)
    img = cv2.cvtColor(frs.rgb, cv2.COLOR_RGB2BGR)
    dcmbgr = cv2.cvtColor(frs.dcmap, cv2.COLOR_RGB2BGR)
    if dcmbgr.shape != img.shape:
      nimg = cv2.resize(img, dsize=(dcmbgr.shape[1], dcmbgr.shape[0]), interpolation=cv2.INTER_AREA)
      images = np.hstack((nimg, dcmbgr))
    else:
      images = np.hstack((img, dcmbgr))
    #cv2.namedWindow('Color & Depth Streams', cv2.WINDOW_AUTOSIZE)
    cv2.imshow('Color & Depth Streams', images)
    return

  def sav_frames(self, tag, frs):
    # tag = f"{frs.idx:06d}_{frs.tstamp}s_"
    self.sav_img(frs.idx, self.dep_dir+tag+"depth.png", frs.depth, RGB2BGR=False)
    self.sav_img(frs.idx, self.img_dir+tag+"rgb.png", frs.rgb, RGB2BGR=True)
    self.sav_img(frs.idx, self.dcm_dir+tag+"dcmap.png", frs.dcmap)
    return

  def sav_img(self, idx, fname, img, RGB2BGR=False):
    if img is not None:
      if RGB2BGR:
        img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)
      cv2.imwrite(fname, img)
    else:
      logging.error(f"[{idx:05d}] no img for {fname}.")
    return # sav_img()
  #------------------------------------------------------------------- rsParser

class frames_cls:
  ''' state-frame class '''
  def __init__(self, *args, **kwargs):
    self.idx = 0
    self.fidx = 0
    self.tstamp = 0.0
    self.rgb = None
    self.depth = None
    self.dcmap = None
    #self.bgr = None
    self.pc_verts = None
    self.pc_tex = None
    self.w = None
    self.h = None
    self.fx = None
    self.fy = None
    self.ppx = None
    self.ppy = None
  # rsframes_cls()

def get_num_frames(filename):
  cfg = rs.config()
  cfg.enable_device_from_file(filename)
  # setup pipeline for the bag file
  pipe = rs.pipeline()
  # start streaming from file
  profile = pipe.start(cfg)
  # setup colorizer for depthmap
  colorizer = rs.colorizer()

  # setup playback
  playback = profile.get_device().as_playback()
  playback.set_real_time(False)
  # get the duration of the video
  t = playback.get_duration()
  # compute the number of frames (30fps setting)
  frame_counts = t.seconds * FREQUENCY
  playback.pause()
  pipe.stop()
  return frame_counts

def main(): #todo --------------------- rsParser main()
  logging.basicConfig(filename="rsParser.log", filemode='w', level=logging.DEBUG, format='[log]-->> %(message)s') #, datefmt='%m/%d/%Y %I:%M:%S %p')
  logging.info(f"bagfile_dir: {BAG_DIR}")
  parser = rsParser(bag_dir=BAG_DIR)
  parser.init_parser() # starts streams
  # parser.init_vis2D()

  keep_running = True
  idx = 0 # data sample counter
  parser.nFrs = get_num_frames(parser.bag_file)
  # while keep_running or idx > parser.nFrs:
  for f in range(parser.nFrs):
    frames = parser.get_frames(idx)
    if frames is None:
      logging.warning(f"idx:{idx} - Null frame returned.")
      # keep_running = False
    else:
      logging.warning(f"idx:{idx} - valid frame returned.")
      print(f"idx:{idx} - valid frame returned.")
      # parser.vis_render2D(frames)
      idx += 1
  parser.stop_streams()
  parser.cleanup()
  return # process_bag()

if __name__ == "__main__":
  main()
  print('---------   End   ---------')
