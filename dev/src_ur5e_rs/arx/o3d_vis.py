
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
