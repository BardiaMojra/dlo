
'''
@author Bardia Mojra
@date 02/16/2023
@brief object oriented handle for pyrealsense 2 mod.
@link https://intelrealsense.github.io/librealsense/python_docs/_generated/pyrealsense2.html
'''

import logging
import numpy as np
import pyrealsense2 as rs
import cv2
import open3d as o3d
import os.path as osp

from config import configuration as cfg_cls


# nbug
from pdb import set_trace as st
from nbug import *



global pipe
global rs_cfg
global pwrap
global pprof
global aprof
global device
global depth_sensor
global depth_prof
global align
global pc
global decimate
global colorizer
global depth_intrinsics


FREQUENCY = 30 # Hz
class rsDevice:
  ''' realsense depth camera device class
    @brief this class/mod handles realsense camera config, init, and API.
    @link https://intelrealsense.github.io/librealsense/python_docs/_generated/pyrealsense2.html
  '''
  # class static vars
  connect_devices = list()
  def __init__(self, *args, **kwargs):
    # gen cfg
    self.todir = "../out/"
    self.freq = FREQUENCY # Hz
    self.rscam_id = 0 #
    self.clipping_distance_in_meters = 1 #
    self.clipping_grey_color = 153 # set pxls further than clipping_distance to grey
    self.decimate_factor = 1
    # feat en
    self.gen_pc_en = True
    self.clip_depth_en = False
    self.align_frames_en = True
    self.shw_en = False
    # internal vars
    self.bag_file = None
    self.rs_cfg_file = None
    #
    self.img_dir = None
    self.dep_dir = None
    self.ply_dir = None
    self.dcm_dir = None

    self.device_product_line = None
    self.depth_scale = None
    self.clipping_distance = None
    self.w = None
    self.h = None
    # init
    #self.init_cfg()

  def init_cfg(self):
    self.bag_file = osp.join(self.todir,"rsDevice.bag")
    # self.rs_cfg_file = osp.join(self.todir,"rs_cfg.yml")
    # dirs
    self.img_dir = osp.join(self.todir, "image/")
    self.dep_dir = osp.join(self.todir, "depth/")
    self.ply_dir = osp.join(self.todir, "pointcloud/")
    self.dcm_dir = osp.join(self.todir, "depth_color_map/")
    self.init_dir(self.img_dir)
    self.init_dir(self.dep_dir)
    self.init_dir(self.ply_dir)
    self.init_dir(self.dcm_dir)
    return

  def init_dir(self, subdir):
    # subdir = osp.join(self.todir, tag)
    if not os.path.exists(subdir):
      os.makedirs(subdir)
      logging.info(f"dir {subdir} is created!")
    return subdir

  def load_cfg(self, cfg):
    self.todir = cfg.rs_dir
    self.freq = cfg.rs_freq
    self.init_cfg()
    return # load_cfg()

  def prt_rs_devices(self):
    for d in rs.context().devices:
      if d.get_info(rs.camera_info.name).lower() != 'platform camera':
        serial = d.get_info(rs.camera_info.serial_number)
        product_line = d.get_info(rs.camera_info.product_line)
        device_info = (serial, product_line) # (serial_number, product_line)
        rsDevice.connect_devices.append( device_info )
        # @link https://intelrealsense.github.io/librealsense/doxygen/rs__sensor_8h.html#aa607d93c1bac40af3ec1c9b0345f59af
        logging.info(f"product line: {product_line}, serial number: {serial}")
    return # prt_rs_devices()

  def init_device(self, record_bag_en=True): # config and enable streams
    global pipe, rs_cfg, pwrap, pprof, device, device_product_line
    pipe = rs.pipeline()
    rs_cfg = rs.config()
    pwrap = rs.pipeline_wrapper(pipe)
    pprof = rs_cfg.resolve(pwrap)
    device = pprof.get_device()
    self.device_product_line = str(device.get_info(rs.camera_info.product_line))
    found_rgb = False
    for s in device.sensors:
      if s.get_info(rs.camera_info.name) == 'RGB Camera':
        found_rgb = True
        break
    if not found_rgb:
      logging.error("The demo requires Depth camera with Color sensor")
      exit(0)
    rs_cfg.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, self.freq)
    if self.device_product_line == 'L500': # None rgb format used for cv
      rs_cfg.enable_stream(rs.stream.color, 960, 540, rs.format.rgb8, self.freq)
    else:
      rs_cfg.enable_stream(rs.stream.color, 640, 480, rs.format.rgb8, self.freq)
    if record_bag_en and self.bag_file:
      rs_cfg.enable_record_to_file(self.bag_file)
      logging.info(f"record to file: {self.bag_file}.")
    elif record_bag_en:
      logging.error(f"no bag_file assigned: {self.bag_file}.")
    return # init_device()

  # def sav_rs_cfg(self):
  #   if not os.path.exists(self.rs_cfg_file):
  #     with open(self.rs_cfg_file, 'w') as f:
  #       yaml.dump(self.rs_cfg, f)
  #   return # sav_rs_cfg()

  # def load_rs_cfg(self, fname):
  #   self.rs_cfg_file = fname
  #   if not os.path.exists(fname):
  #     with open(fname, 'r') as f:
  #       self.rs_cfg = yaml.load(f, Loader="UnsafeLoader")
  #   else:
  #     logging.error("file already exists, f{fname}.")
  #   return self.rs_cfg

  def init_recorder(self, rec_en=True): # config and enable streams
    self.prt_rs_devices() # list devices
    # self.prt_dev_info()
    self.init_device(record_bag_en=rec_en)
    self.start_streams()
    self.init_clip_depth()
    self.init_align_frames()
    self.init_pc()
    return # init_recorder()

  def start_streams(self):
    global pipe, rs_cfg, aprof
    aprof = pipe.start(rs_cfg)
    return

  def stop_streams(self):
    global pipe
    pipe.stop()
    # pipe.reset()
    return

  def init_clip_depth(self):
    global aprof, depth_sensor
    if self.clip_depth_en:
      depth_sensor = aprof.get_device().first_depth_sensor()  # Getting the depth sensor's depth scale (see rs-align example for explanation)
      self.depth_scale = depth_sensor.get_depth_scale()
      self.clipping_distance = self.clipping_distance_in_meters / self.depth_scale
      logging.info("clipping depth is enabled.")
      logging.info(f"Depth Scale is: {self.depth_scale}")
    else:
      logging.warning("clipping depth is diabled.")
    return

  def init_align_frames(self):
    global align, decimate
    if self.align_frames_en:
      logging.info("align frames is enabled.")
      decimate = rs.decimation_filter(8)
      decimate.set_option(rs.option.filter_magnitude, 2 ** self.decimate_factor)
      align_to = rs.stream.color
      align = rs.align(align_to)
    else:
      logging.warning("align frames is disabled.")
    return

  def init_pc(self):
    global depth_prof, aprof, pc, colorizer
    if self.gen_pc_en:
      logging.info("gen pointcloud is enabled.")
      # init depth prof
      depth_prof = rs.video_stream_profile(aprof.get_stream(rs.stream.depth))
      self.update_dprof()
      # init pc blocks
      pc = rs.pointcloud()
      colorizer = rs.colorizer()
    else:
      logging.warning("gen pointcloud is disabled.")
    return

  def update_dprof(self):
    global depth_intrinsics, depth_prof
    depth_intrinsics = depth_prof.get_intrinsics()
    self.w, self.h = depth_intrinsics.width, depth_intrinsics.height
    return

  # def get_o3d_phcam_intrs(self): # get color stream profile
  #   global aprof
  #   intr = aprof.get_stream(rs.stream.color).as_video_stream_profile().get_intrinsics()
  #   # intr_ls = [intr.width, intr.height, intr.fx, intr.fy, intr.ppx, intr.ppy]
  #   pinhole_camera_intrinsic = o3d.camera.PinholeCameraIntrinsic(intr.width, intr.height, intr.fx, intr.fy, intr.ppx, intr.ppy)
  #   return pinhole_camera_intrinsic

  def get_intr(self):
    global aprof
    frs = rsframes_cls(0)
    intr = aprof.get_stream(rs.stream.color).as_video_stream_profile().get_intrinsics()
    frs.w = intr.width
    frs.h = intr.height
    frs.fx = intr.fx
    frs.fy = intr.fy
    frs.ppx = intr.ppx
    frs.ppy = intr.ppy
    return frs # get_intr()

  def get_frames(self, idx, sav_frs_en=False):
    global pipe, align, decimate, points, pc
    frs = rsframes_cls(idx)
    frames = pipe.wait_for_frames()
    # frs.idx = idx
    frs.fidx = frames.get_frame_number()
    frs.tstamp = frames.get_timestamp()
    if self.align_frames_en:
      decimated = decimate.process(frames).as_frameset()
      aligned_frames = align.process(decimated)
      depth_frame = aligned_frames.get_depth_frame()
      color_frame = aligned_frames.get_color_frame()
    else:
      depth_frame = frames.get_depth_frame()
      color_frame = frames.get_color_frame()
    frs.depth = np.asanyarray(depth_frame.data)
    frs.rgb = np.asanyarray(color_frame.data)
    if self.clip_depth_en:
      depth_image_3d = np.dstack((frs.depth,frs.depth,frs.depth)) #depth image is 1 channel, color is 3 channels
      frs.rgb = np.where((depth_image_3d > self.clipping_distance) | (depth_image_3d <= 0), self.clipping_grey_color, frs.rgb)
    frs.dcmap = cv2.applyColorMap(cv2.convertScaleAbs(frs.depth, alpha=0.03), cv2.COLORMAP_JET)
    #frs.dcmap = np.asanyarray(colorizer.colorize(depth_frame).get_data())
    #nsprint("frs.dcmap", frs.dcmap)
    if sav_frs_en:
      # tag = f"{frs.idx:06d}_{frs.fidx:06d}_{frs.tstamp}s_" # w fidx
      tag = f"{frs.idx:06d}_{frs.tstamp}s_"
      self.sav_frames(tag, frs)
    if self.gen_pc_en:
      # logging.info("generate pointclouds.")
      points = pc.calculate(depth_frame)
      if sav_frs_en:
        fname = self.ply_dir+tag+"pc.ply" # type: ignore
        points.export_to_ply(fname, color_frame)
      # v, t = points.get_vertices(), points.get_texture_coordinates()
      # frs.pc_verts = np.asanyarray(v).view(np.float32).reshape(-1, 3)  # xyz
      # frs.pc_tex = np.asanyarray(t).view(np.float32).reshape(-1, 2)  # uv
      # intr = aprof.get_stream(rs.stream.color).as_video_stream_profile().get_intrinsics()
      # frs.w = intr.width
      # frs.h = intr.height
      # frs.fx = intr.fx
      # frs.fy = intr.fy
      # frs.ppx = intr.ppx
      # frs.ppy = intr.ppy
      # # nsprint("frs.pc_verts", frs.pc_verts)
      # nsprint("frs.pc_tex", frs.pc_tex)
    else:
      logging.info("will not generate pointclouds.")
    return frs # get_frames()

  def check_frames(self, idx, frames, lp_dt):
    logging.info(f"idx:{idx} - get_frame() exec time: {lp_dt} sec.")
    if frames is None:
      logging.warning("idx:{idx} - Null frames returned.")
    if frames.fidx != frames.idx or frames.fidx != idx:
      logging.error(f"idx:{idx} - index missmatch --->  opt.idx:{idx}, frames.idx:{frames.idx}, frames.fidx:{frames.fidx}!")
    return # check_frames()

  def init_vis2D(self, shw_en=True):
    self.shw_en = shw_en
    if shw_en:
      cv2.namedWindow('Color & Depth Streams', cv2.WINDOW_AUTOSIZE)
      #cv2.namedWindow("Depth Color Map Stream", cv2.WINDOW_AUTOSIZE)
      # cv2.resizeWindow(state.WIN_NAME, w, h)
      # cv2.setMouseCallback(state.WIN_NAME, mouse_cb)
    return

  def vis_render2D(self, frs):
    if self.shw_en:
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

  def vis_close(self):
    if self.shw_en:
      cv2.destroyWindow('Color & Depth Streams')
    return

  def sav_frames(self, tag, frs):
    # tag = f"{frs.idx:06d}_{frs.tstamp}s_"
    self.sav_img(frs.idx, self.dep_dir+tag+"depth.png", frs.depth, RGB2BGR=False)
    self.sav_img(frs.idx, self.img_dir+tag+"rgb.png", frs.rgb, RGB2BGR=True)
    self.sav_img(frs.idx, self.dcm_dir+tag+"dcmap.png", frs.dcmap)
    return
  #------------------------------------------------------------------- rsDevice

  def sav_img(self, idx, fname, img, RGB2BGR=False):
    if img is not None:
      if RGB2BGR:
        img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)
      cv2.imwrite(fname, img)
    else:
      logging.error(f"[{idx:05d}] no img for {fname}.")
    return # sav_img()

class rsframes_cls:
  ''' state-frame class '''
  def __init__(self, idx, *args, **kwargs):
    self.idx = idx
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




def main(): #todo --------------------- rsDevice main()

  cfg = cfg_cls("rsDevice Module cfg")
  cfg.init()

  rscam = rsDevice()
  rscam.load_cfg(cfg) # config

  #stfr = stframe_cls()
  #stfr.load_cfg(cfg)


  rscam.init_recorder() # starts streams
  st()
  keep_running = True
  idx = 0 # data sample counter
  try:
    while keep_running:

      ''' get new state and frame '''
      frames = rscam.get_frames(idx) # saves to file
      #vis_render2D(frames)
      #prt_state(idx, state, idx_wp) # print state to terminal
      #shw_dframe(idx, dframe, idx_wp) # open interactive point cloud window

      ''' log state and frame '''
      #dset.log_st(idx, idx_wp, state)
      #dset.log_fr(idx, idx_wp, frames) #todo add fr dlogger

      #robot.check_waypoint(opt_st, rob_st) #todo add robot waypoint handler
      idx += 1
      # end of while keep_running

  except KeyboardInterrupt:
    logging.info("keyboard interrupt recieved.")
    keep_running = False

  rscam.stop_streams()
  logging.info("end of data collection.")

  st()
  logging.info('<<----- end of main ----->>')
  logging.info('<<----- post-processing ----->>')

  #rscam.process_bag()

  return # end of main


if __name__ == "__main__":
  main()
  print('---------   End   ---------')
