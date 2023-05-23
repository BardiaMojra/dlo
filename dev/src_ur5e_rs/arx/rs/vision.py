
import math, logging
import ctypes
# from matplotlib.pyplot import axes
import pyglet
import pyglet.gl as gl
import numpy as np
import pyrealsense2 as rs
import cv2
from nbug import *
from pdb import set_trace as st

"""
OpenGL Pointcloud viewer with http://pyglet.org
Usage:
------
Mouse:
    Drag with left button to rotate around pivot (thick small axes),
    with right button to translate and the wheel to zoom.
Keyboard:
    [p]     Pause
    [r]     Reset View
    [d]     Cycle through decimation values
    [z]     Toggle point scaling
    [x]     Toggle point distance attenuation
    [c]     Toggle color source
    [l]     Toggle lighting
    [f]     Toggle depth post-processing
    [s]     Save PNG (./out.png)
    [e]     Export points to ply (./out.ply)
    [q/ESC] Quit
Notes:
------
Using deprecated OpenGL (FFP lighting, matrix stack...) however, draw calls
are kept low with pyglet.graphics.* which uses glDrawArrays internally.
Normals calculation is done with numpy on CPU which is rather slow, should really
be done with shaders but was omitted for several reasons - brevity, for lowering
dependencies (pyglet doesn't ship with shader support & recommends pyshaders)
and for reference.
"""



def rotation_matrix(axis, theta):
  """
  Return the rotation matrix associated with counterclockwise rotation about
  the given axis by theta radians.
  @link https://stackoverflow.com/a/6802723
  """
  axis = np.asarray(axis)
  axis = axis / math.sqrt(np.dot(axis, axis))
  a = math.cos(theta / 2.0)
  b, c, d = -axis * math.sin(theta / 2.0)
  aa, bb, cc, dd = a * a, b * b, c * c, d * d
  bc, ad, ac, ab, bd, cd = b * c, a * d, a * c, a * b, b * d, c * d
  return np.array([[aa + bb - cc - dd, 2 * (bc + ad), 2 * (bd - ac)],
                    [2 * (bc - ad), aa + cc - bb - dd, 2 * (cd + ab)],
                    [2 * (bd + ac), 2 * (cd - ab), aa + dd - bb - cc]])

def convert_fmt(fmt):
  """rs.format to pyglet format string"""
  return {
          rs.format.rgb8: 'RGB',
          rs.format.bgr8: 'BGR',
          rs.format.rgba8: 'RGBA',
          rs.format.bgra8: 'BGRA',
          rs.format.y8: 'L',
        }[fmt]



class AppState_cls:
  def __init__(self, *args, **kwargs):
    ''' default config '''
    self.pitch, self.yaw = math.radians(-10), math.radians(-15)
    self.translation = np.array([0, 0, 1], np.float32)
    self.distance = 2
    self.mouse_btns = [False, False, False]
    self.paused = False
    self.decimate = 0
    self.scale = True
    self.attenuation = False
    self.color = True
    self.lighting = False
    self.postprocessing = False

  def reset(self):
    self.pitch, self.yaw, self.distance = 0, 0, 2
    self.translation[:] = 0, 0, 1
    return # reset()

  @property
  def rotation(self):
    Rx = rotation_matrix((1, 0, 0), math.radians(-self.pitch))
    Ry = rotation_matrix((0, 1, 0), math.radians(-self.yaw))
    return np.dot(Ry, Rx).astype(np.float32) # rotation()
  # AppState_cls()

class rsDCamera_cls:
  ''' realsense depth camera device class
    @brief this class/mod handles realsense camera config, init, and API.
    @link https://intelrealsense.github.io/librealsense/python_docs/_generated/pyrealsense2.html
  '''
  def __init__(self, *args, **kwargs):
    self.app_st = AppState_cls()
    #todo add properties
    self.todir = None
    self.freq = 30
    self.pipe = None
    self.device = None
    self.config = None
    self.pwrap = None
    self.pprof = None
    self.found_rgb = None
    self.rgb_stream = None
    self.rgb_format = None
    self.aprof = None
    self.dm_prof = None
    self.dm_intr = None
    self.dm_w = None
    self.dm_h = None
    self.pc = None
    self.pc_decimate = None
    self.pc_colorizer = None
    self.pc_filters = None
    self.rgb_prof = None
    self.rgb_w = None
    self.rgb_h = None
    self.rgb_intr = None


  def load_cfg(self, cfg):
    #self.dev_id = cfg.cam_device_id
    self.todir = cfg.todir
    self.freq = cfg.freq
    #self.rec_to_file_en = False # sav to bagfile directly

    # self.st_file = cfg.st_file
    # self.pc_file = cfg.pc_file
    # self.rgb_file = cfg.rgb_file
    # self.dm_file = cfg.dm_file
    # self.st_dir = cfg.st_dir
    # self.pc_dir = cfg.pc_dir
    # self.rgb_dir = cfg.rgb_dir
    # self.dm_dir = cfg.dm_dir
    #
    # def sav_to_bagfile_en(self, enable):

    return # load_cfg()

  def init(self):
    self.init_device()
    self.start_streams()
    self.init_dm()
    self.init_pc()
    self.init_rgb()
    return # init()

  def init_device(self): # config and enable streams
    self.pipe = rs.pipeline()
    self.config = rs.config()
    self.pwrap = rs.pipeline_wrapper(self.pipe)
    self.pprof = self.config.resolve(self.pwrap)
    self.device = self.pprof.get_device()

    self.found_rgb = False
    for s in self.device.sensors:
      if s.get_info(rs.camera_info.name) == 'RGB Camera':
        self.found_rgb = True
        break
    if not self.found_rgb:
      logging.error("The demo requires Depth camera with Color sensor")
      exit(0)
    self.config.enable_stream(rs.stream.depth, rs.format.z16, self.freq)
    self.rgb_stream = rs.stream.color
    self.rgb_format = rs.format.bgr8 # rbg8
    self.config.enable_stream(self.rgb_stream, self.rgb_format, self.freq)
    return # init()

  def start_streams(self):
    self.pipe.start(self.config)
    self.aprof = self.pipe.get_active_profile()
    return # start_streams()

  def stop_streams(self):
    self.pipe.stop()
    return # stop_streams()


  def init_dm(self): # init depth map handles
    self.dm_prof = rs.video_stream_profile(self.aprof.get_stream(rs.stream.depth))
    self.dm_intr = self.dm_prof.get_intrinsics()
    self.dm_w, self.dm_h = self.dm_intr.width, self.dm_intr.height
    return # init_dm

  def init_pc(self): # init point cloud handles
    self.pc = rs.pointcloud()
    self.pc_decimate = rs.decimation_filter()
    self.pc_decimate.set_option(rs.option.filter_magnitude, 2 ** self.app_st.decimate)
    self.pc_colorizer = rs.colorizer()
    self.pc_filters = [rs.disparity_transform(),
                       rs.spatial_filter(),
                       rs.temporal_filter(),
                       rs.disparity_transform(False)]
    return # init_pc()

  def init_rgb(self):
    self.rgb_prof = rs.video_stream_profile(self.aprof.get_stream(self.rgb_stream))
    self.rgb_w, self.rgb_h = self.dm_w, self.dm_h
    self.rgb_intr = self.rgb_prof.get_intrinsics()
    self.rgb_w, self.rgb_h = self.rgb_intr.width, self.rgb_intr.height
    #if self.st_app.color:
      #image_w, image_h = color_w, color_h

    return # init_rgb()

  def get_frames(self):
    if self.app_st.paused:
      logging.warning("appState paused.")
      return
    success, frames = self.pipe.try_wait_for_frames(timeout_ms=0)
    if not success:
      logging.warning("frame polling failed.")
      return
    self.dm_fr = frames.get_depth_frame().as_video_frame()
    self.rgb_fr = frames.first(self.rgb_stream).as_video_frame()
    self.dm_fr = self.pc_decimate.process(self.dm_fr)
    if self.app_st.postprocessing:
      for f in self.pc_filters:
        self.dm_fr = f.process(self.dm_fr)

    # Grab new intrinsics (may be changed by decimation)
    self.dm_intr = rs.video_stream_profile(self.dm_fr.profile).get_intrinsics()
    self.dm_w, self.dm_h = self.dm_intr.width, self.dm_intr.height
    self.rgb_img = np.asanyarray(self.rgb_fr.get_data())
    self.dm_cdep = self.pc_colorizer.colorize(self.dm_fr)
    self.dm_cmap = np.asanyarray(self.dm_cdep.get_data())
    if self.app_st.color:
      self.mapped_fr, self.color_src = self.rgb_fr, self.rgb_img
    else:
      self.mapped_fr, self.color_src = self.dm_cdep, self.dm_cmap
    self.pc_points = self.pc.calculate(self.dm_fr)
    self.pc.map_to(self.mapped_fr)
    st()
    return frames

  def get_framesCV(self):
    frames = self.pipe.wait_for_frames() # Wait for a coherent pair of frames: depth and color
    depth_frame = frames.get_depth_frame()
    color_frame = frames.get_color_frame()
    if not depth_frame or not color_frame:
      return
    depth_image = np.asanyarray(depth_frame.get_data())
    color_image = np.asanyarray(color_frame.get_data())
    # Apply colormap on depth image (image must be converted to 8-bit per pixel first)
    depth_colormap = cv2.applyColorMap(cv2.convertScaleAbs(depth_image, alpha=0.03), cv2.COLORMAP_JET)
    frames = {"dm_img": depth_image,
              "rgb_img": color_image,
              "dcm_img": depth_colormap}
    return frames
  # rsDCamera_cls

def vis_render2D(frames):
  depth_colormap_dim = frames["dcm_img"].shape
  color_colormap_dim = frames["rgb_img"].shape
  # If depth and color resolutions are different, resize color image to match depth image for display
  if depth_colormap_dim != color_colormap_dim:
    resized_color_image = cv2.resize(frames["rgb_img"], dsize=(depth_colormap_dim[1], depth_colormap_dim[0]), interpolation=cv2.INTER_AREA)
    images = np.hstack((resized_color_image, frames["dcm_img"]))
  else:
    images = np.hstack((frames["rgb_img"], frames["dcm_img"]))
  cv2.namedWindow('RealSense', cv2.WINDOW_AUTOSIZE)
  cv2.imshow('RealSense', images)
  cv2.waitKey(1)
  return

def main():
  cam = rsDCamera_cls(cam_model="D455")
  #cam.load_cfg(cfg) # config
  cam.init() # init device and streams


  keep_running = True
  try:
    while keep_running:

      ''' get new state and frame '''
      #todo ---------------------------->> frame
      #state = con_ur5e.receive()
      # check_st_and_fr(st, fr)
      # if state is None: # or frame is None:
      #   logging.error("NULL state or frame.")
      #   break

      # frames = cam.get_frames() #
      frames = cam.get_framesCV() #

      vis_render2D(frames)

      #prt_state(idx, state, idx_wp) # print state to terminal
      #shw_dframe(idx, dframe, idx_wp) # open interactive point cloud window

      ''' log state and frame '''
      #dset.log_st(idx, idx_wp, state)
      #dset.log_fr(idx, idx_wp, frames) #todo add fr dlogger


      #robot.check_waypoint(opt_st, rob_st) #todo add robot waypoint handler
  except KeyboardInterrupt:
    logging.info("keyboard interrupt recieved.")
    keep_running = False

  cam.stop()
  logging.info("end of data collection.")

  st()
  logging.info('<<----- end of main ----->>')
  logging.info('<<----- post-processing ----->>')
  return # end of main


if __name__ == "__main__":
  main()
  print('---------   End   ---------')
