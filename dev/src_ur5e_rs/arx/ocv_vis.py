
'''
@author Bardia Mojra
@date 02/16/2023
'''

import open3d as o3d
import logging
import numpy as np
import cv2
import os.path as osp

from config import configuration as cfg_cls


# nbug
from pdb import set_trace as st
from nbug import *


class AppState:
  def __init__(self, *args, **kwargs):
    self.WIN_NAME = 'RealSense'
    self.pitch, self.yaw = math.radians(-10), math.radians(-15)
    self.translation = np.array([0, 0, -1], dtype=np.float32)
    self.distance = 2
    self.prev_mouse = 0, 0
    self.mouse_btns = [False, False, False]
    self.paused = False
    self.decimate = 1
    self.scale = True
    self.color = True

  def reset(self):
    self.pitch, self.yaw, self.distance = 0, 0, 2
    self.translation[:] = 0, 0, -1

  @property
  def rotation(self):
    Rx, _ = cv2.Rodrigues((self.pitch, 0, 0))
    Ry, _ = cv2.Rodrigues((0, self.yaw, 0))
    return np.dot(Ry, Rx).astype(np.float32)

  @property
  def pivot(self):
    return self.translation + np.array((0, 0, self.distance), dtype=np.float32)

def mouse_cb(event, x, y, flags, param):
  global ocv_render_app_state
    if event == cv2.EVENT_LBUTTONDOWN:
        state.mouse_btns[0] = True
    if event == cv2.EVENT_LBUTTONUP:
        state.mouse_btns[0] = False
    if event == cv2.EVENT_RBUTTONDOWN:
        state.mouse_btns[1] = True
    if event == cv2.EVENT_RBUTTONUP:
        state.mouse_btns[1] = False
    if event == cv2.EVENT_MBUTTONDOWN:
        state.mouse_btns[2] = True
    if event == cv2.EVENT_MBUTTONUP:
        state.mouse_btns[2] = False
    if event == cv2.EVENT_MOUSEMOVE:
        h, w = out.shape[:2]
        dx, dy = x - state.prev_mouse[0], y - state.prev_mouse[1]
        if state.mouse_btns[0]:
            state.yaw += float(dx) / w * 2
            state.pitch -= float(dy) / h * 2

        elif state.mouse_btns[1]:
            dp = np.array((dx / w, dy / h, 0), dtype=np.float32)
            state.translation -= np.dot(state.rotation, dp)

        elif state.mouse_btns[2]:
            dz = math.sqrt(dx**2 + dy**2) * math.copysign(0.01, -dy)
            state.translation[2] += dz
            state.distance -= dz

    if event == cv2.EVENT_MOUSEWHEEL:
        dz = math.copysign(0.1, flags)
        state.translation[2] += dz
        state.distance -= dz

    state.prev_mouse = (x, y)

class vis3D:
  ''' Open3D visualization class
  '''
  # class static vars
  windows = list()
  vis = None
  pc = None
  ph_intr = None

  def __init__(self,  *args, **kwargs):
    # gen cfg
    self.todir = "../out/"
    self.dep_dir = None
    self.img_dir = None
    self.pc_dir = None
    # feat cfg
    self.geometrie_added_en = False
    self.view_ind = 0
    self.breakLoopFlag = 0
    self.backgroundColorFlag = 1
    # internal vars
    self.saveCurrentRGBD = None
    self.breakLoop = None
    self.change_background_color = None
    # self.w = None
    # self.h = None
    # init
    # self.init_cfg()
    # --------------------------------------------------------------- __init__()

  # def init_cfg(self):
  #   self.dep_dir = osp.join(self.todir, "depth")
  #   self.img_dir = osp.join(self.todir, "image")
  #   self.pc_dir = osp.join(self.todir, "pointcloud")
  #   return

  def init_dir(self, tag):
    subdir = osp.join(self.todir, tag)
    if not os.path.exists(subdir):
      logging.info(f"[check_n_mkdir]->> dir {subdir} does not exist, will be created!")
      os.makedirs(subdir)
    return subdir

  # def load_cfg(self, cfg):
  #   self.todir = cfg.rs_dir
  #   self.init_cfg()
  #   return # load_cfg()


  def init_phCam_v3D(self, frs=None):
    if frs is None:
      logging.error("no pinhole camera intrinsics provided!")
      exit()
    st()
    vis3D.ph_intr = o3d.camera.PinholeCameraIntrinsic(frs.w, \
      frs.h, frs.fx, frs.fy, frs.ppx, frs.ppy)
    vis3D.vis = o3d.visualization.VisualizerWithKeyCallback()
    vis3D.pc = o3d.geometry.PointCloud()
    cv2.namedWindow("Color Stream", cv2.WINDOW_AUTOSIZE)
    vis3D.windows.append("Color Stream")
    cv2.namedWindow("Depth Stream", cv2.WINDOW_AUTOSIZE)
    vis3D.windows.append("Depth Stream")
    # vis3D.vis.create_window("Pointcloud")
    # vis3D.windows.append("Pointcloud")
    vis3D.vis.register_key_callback(ord(" "), self.saveCurrentRGBD)
    vis3D.vis.register_key_callback(ord("Q"), self.breakLoop)
    vis3D.vis.register_key_callback(ord("K"), self.change_background_color)
    return # init_phCam_v3D()

  # def saveCurrentRGBD(self):
  #   if not os.path.exists('./output/'):
  #     os.makedirs('./output')
  #   cv2.imwrite('./output/depth_'+str(self.view_ind)+'.png',frames.depth)
  #   cv2.imwrite('./output/color_'+str(self.view_ind)+'.png',color_image1)
  #   o3d.io.write_point_cloud('./output/pointcloud_'+str(view_ind)+'.pcd', pcd)
  #   print('No.'+str(self.view_ind)+' shot is saved.' )
  #   self.view_ind += 1
  #   return False

  # def breakLoop(vis):
  #   global breakLoopFlag
  #   breakLoopFlag +=1
  #   return False

  def change_background_color(self):
    # global backgroundColorFlag
    opt = vis3D.vis.get_render_option()
    if self.backgroundColorFlag:
      opt.background_color = np.asarray([0, 0, 0])
      self.backgroundColorFlag = 0
    else:
      opt.background_color = np.asarray([1, 1, 1])
      self.backgroundColorFlag = 1
    # background_color ~=backgroundColorFlag
    return False

  def renderAll(self, opt, frs):
    bgr = cv2.cvtColor(frs.depth, cv2.COLOR_RGB2BGR)
    depbgr = cv2.cvtColor(frs.depth, cv2.COLOR_RGB2BGR)
    dcmbgr = cv2.cvtColor(frs.dcmap, cv2.COLOR_RGB2BGR)
    cv2.imshow('Color Stream', bgr)
    cv2.imshow("Depth Stream", dcmbgr)

    depth = o3d.geometry.Image(frs.depth)
    color = o3d.geometry.Image(frs.rgb)
    rgbd = o3d.geometry.RGBDImage.create_rgbd_image_from_color_and_depth(color, depth, convert_rgb_to_intensity = False)
    pcd = o3d.geometry.PointCloud.create_point_cloud_from_rgbd_image(rgbd, vis3D.ph_intr)
    pcd.transform([[1,0,0,0],[0,-1,0,0],[0,0,-1,0],[0,0,0,1]])
    if not pcd:
      logging.warning(f"idx:{opt.idx} - no pointcloud returned!")
      return

    vis3D.pc.clear()
    vis3D.pc += pcd
    if not self.geometrie_added_en:
      vis3D.vis.add_geometry(vis3D.pc)
      self.geometrie_added_en = True
    vis3D.vis.update_geometry()
    vis3D.vis.poll_events()
    vis3D.vis.update_renderer()
    return # renderAll()


  # end of vis3D class




def main(): #todo ----------------------------------------- o3dVis - test main()

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

  rscam.process_bag()

  return # end of main


if __name__ == "__main__":
  main()
  print('---------   End   ---------')
