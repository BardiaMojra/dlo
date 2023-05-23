
# main_0201_rQ5Lom.py


import sys, os, time, logging
from datetime import datetime
import os.path as op
import numpy as np
# import pandas as pd
# import pyrealsense2 as rs
# import yaml
import cv2


''' local '''
import rtde.rtde as rtde
import rtde.rtde_config as rtde_config
from config import configuration as cfg_cls
import rtde.csv_writer as csv_writer
#import rtde.csv_binary_writer as csv_binary_writer
from dmm import dmm as dmm_cls
from dlm import dlm as dlm_cls
from vision import rsDCamera_cls


''' NBUG '''
from pdb import set_trace as st
from nbug import *


# TIMESTAMP_TID = False
TIMESTAMP_TID = True




''' local routines '''
def setp_to_list(setp):
  list = []
  for i in range(0,6):
    list.append(setp.__dict__["input_double_register_%i" % i])
  return list

def list_to_setp(setp, list):
  for i in range (0,6):
    setp.__dict__["input_double_register_%i" % i] = list[i]
  return setp

def prt_state(idx, st, idx_wp):
  nprint("idx",idx)
  nprint("idx_wp",idx_wp)
  nprint("timestamp",st.timestamp)
  nprint("robot_mode",st.robot_mode)
  #nprint("target_q",st.target_q)
  #nprint("actual_q",st.actual_q)
  #nprint("actual_qd",st.actual_qd)
  nprint("target_TCP_pose",st.target_TCP_pose)
  nprint("actual_TCP_pose",st.actual_TCP_pose)
  nprint("actual_TCP_speed",st.actual_TCP_speed)
  nprint("output_int_register_0",st.output_int_register_0)
  print("\n\n\n")
  return


def get_labels_from_xml(xml_file):
  conf = rtde_config.ConfigFile(xml_file)
  state_names, state_types = conf.get_recipe("state")
  return state_names

def get_dtypes_from_xml(xml_file):
  conf = rtde_config.ConfigFile(xml_file)
  state_names, state_types = conf.get_recipe("state")
  return state_types

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

  ''' init cfg '''
  #todo make cfg a separate mod, use box to store objs as json files
  # proj
  cfg = cfg_cls("DLO Dataset Test Config")
  cfg.wdir = "./" #os.getcwd() # working dir # type: ignore
  cfg.odir = op.normpath(op.join(op.join(cfg.wdir,".."),"out"))  # type: ignore
  # test id
  cfg.tnum = 1 # test num # type: ignore
  cfg.tname = "basic_x" # test name # type: ignore
  cfg.tdtime = now.strftime("%Y-%m-%d_%H-%M-%S") # time tag # type: ignore
  if TIMESTAMP_TID:
    cfg.tid = '_'.join([f"{cfg.tnum:03}", cfg.tname, cfg.tdtime]) # test id (num + name + datetime)  # type: ignore
  else:
    cfg.tid = '_'.join([f"{cfg.tnum:03}", cfg.tname]) # test id (num + name) # type: ignore
  # files
  cfg.todir = op.join(cfg.odir,cfg.tid) # test output directory # type: ignore
  cfg.cfg_file = op.join(cfg.todir,"cfg.yml")  # type: ignore
  cfg.log_file = op.join(cfg.wdir,"main.log") # type: ignore
  cfg.notes_file = op.join(cfg.todir,"notes.txt") # type: ignore
  cfg.wps_file = op.join(cfg.todir,"wps.txt") # waypoints # type: ignore
  cfg.st_file = op.join(cfg.todir,"st_frames.txt") # state frames # type: ignore
  cfg.pc_file = op.join(cfg.todir,"pc_frames.txt") # point cloud # type: ignore
  cfg.rgb_file = op.join(cfg.todir,"rgb_frames.txt") # rgb frames  # type: ignore
  cfg.dm_file = op.join(cfg.todir,"d_frames.txt") # depth frames  # type: ignore
  # dirs
  cfg.st_dir = op.join(cfg.todir,"st_frames") # state frames # type: ignore
  cfg.pc_dir = op.join(cfg.todir,"pc_frames") # point cloud frames dir # type: ignore
  cfg.rgb_dir = op.join(cfg.todir,"rgb_frames") # rgb frames dir # type: ignore
  cfg.dm_dir = op.join(cfg.todir,"d_frames") # depth frames dir # type: ignore
  # test details
  cfg.dlo_name = "reinforced tube" # type: ignore
  cfg.dlo_length = "1000 mm" # type: ignore
  cfg.dlo_diameter = "50 mm" # type: ignore

  # run time config #todo run-time cfg
  cfg.host = "192.168.1.147" # type: ignore
  cfg.port = 30004 # type: ignore
  cfg.rtde_cfg_file = op.join(cfg.wdir,"comms_config.xml") # type: ignore
  cfg.freq = 10 # Hz # type: ignore
  cfg.runtime_max = 30 # [sec] # type: ignore

  # labels, units, and dtypes
  cfg.st_labs = get_labels_from_xml(cfg.rtde_cfg_file) # type: ignore
  cfg.st_dtypes = get_dtypes_from_xml(cfg.rtde_cfg_file) # type: ignore
  #cfg.st_units = ???
  cfg.st_labs = ["idx", "idx_wps"] + cfg.st_labs # type: ignore
  #cfg.st_units = ??? # type: ignore
  cfg.st_dtypes = ["INT", "INT"] + cfg.st_dtypes # type: ignore
  cfg.wps_labs = ["x","y","z","rx","ry","rz"] # type: ignore
  cfg.wps_units = ["m","m","m","rad","rad","rad"] # type: ignore

  # run time flags
  cfg._nbug = True # type: ignore
  cfg._prt = True # prt to term # type: ignore
  cfg._shw = True # type: ignore
  #cfg._sav = True # type: ignore
  cfg._repeat_wps = False  # type: ignore

  ''' waypoints ''' # pose  [m & rad] - in tool space
  wp_home   = [ 0.00, -0.680, 0.650, 0, -2.2, 2.2]
  wp_left   = [ 0.24, -0.680, 0.650, 0, -2.2, 2.2]
  wp_right  = [-0.24, -0.680, 0.650, 0, -2.2, 2.2]
  wpoints = [wp_home,
             wp_right,
             wp_left,
             wp_right,
             wp_left,
             wp_right,
             wp_left,
             wp_right,
             wp_left,
             wp_right,
             wp_left,
             wp_home]

  cfg.init()
  #cfg.prt() # prt to term

  ''' init mods '''
  dmm = dmm_cls(); dmm.load_cfg(cfg); dmm.sav_wps(wpoints)
  dset = dlm_cls() # data log class
  cam = rsDCamera_cls(cam_model="D455")
  #cam.load_cfg(cfg) # config
  cam.init() # init device and streams

  ''' init nbug logger '''
  logging.basicConfig(filename=cfg.log_file, filemode='w', level=logging.DEBUG, format='[log]-->> %(message)s') #, datefmt='%m/%d/%Y %I:%M:%S %p')

  ''' init UR5e rtde '''
  #todo: make mod
  conf = rtde_config.ConfigFile(cfg.rtde_cfg_file)
  st_labs, st_dtypes = conf.get_recipe("state")
  setp_labs, setp_dtypes = conf.get_recipe("setp")
  wd_labs, wd_dtypes = conf.get_recipe("watchdog")
  con_ur5e = rtde.RTDE(cfg.host, cfg.port)
  con_ur5e.connect()
  con_ur5e.get_controller_version()
  # setup recipes
  con_ur5e.send_output_setup(st_labs, st_dtypes, frequency=cfg.freq)
  setp = con_ur5e.send_input_setup(setp_labs, setp_dtypes)
  watchdog = con_ur5e.send_input_setup(wd_labs, wd_dtypes)
  setp.input_double_register_0 = 0
  setp.input_double_register_1 = 0
  setp.input_double_register_2 = 0
  setp.input_double_register_3 = 0
  setp.input_double_register_4 = 0
  setp.input_double_register_5 = 0
  watchdog.input_int_register_0 = 0 # rtde_set_watchdog() in rtde_control_loop.urp creates a 1 Hz watchdog
  if not con_ur5e.send_start():
    logging.error("NULL state returned.")
    sys.exit() # start data synchronization


  ''' main loop '''
  idx_wp = 0 # waypoint cntr
  idx = 0 # data sample counter
  move_completed = True
  keep_running = True
  t0 = time.time()
  try:
    while keep_running:

      tnow = time.time()


      ''' get robot state '''
      #todo ---------------------------->> frame
      state = con_ur5e.receive()
      # check_st_and_fr(st, fr)
      if state is None: # or frame is None:
        logging.error("NULL state or frame.")
        break

      ''' get camera frames '''
      #dframe = perception.get_frames()
      # frames = cam.get_frames() #
      frames = cam.get_framesCV() #

      ''' prt and render '''
      vis_render2D(frames)
      prt_state(idx, state, idx_wp) # print state to terminal
      #shw_dframe(idx, dframe, idx_wp) # open interactive point cloud window

      ''' log state and frame '''
      dset.log_st(idx, idx_wp, state)
      dset.log_fr(idx, frames) #todo add fr dlogger


      #robot.check_waypoint(opt_st, rob_st) #todo add robot waypoint handler


      prt_state(idx, state, idx_wp) # print state to terminal
      #shw_dframe(idx, dframe, idx_wp) # open interactive point cloud window

      ''' log state and frame '''

      dset.log_st(idx, idx_wp, state)

      #dlm.log_rgb(state, idx_wp)


      ''' handle waypoint '''
      if move_completed and state.output_int_register_0 == 1: # next waypoint
        move_completed = False
        new_setp = wpoints[idx_wp]
        list_to_setp(setp, new_setp)
        nprint("new waypoint", new_setp)
        con_ur5e.send(setp)
        idx_wp += 1
        if idx_wp >= len(wpoints) and cfg._repeat_wps is True:
          idx_wp = 0
          logging.info("restart at waypoint 0.")
        elif idx_wp > len(wpoints) and cfg._repeat_wps is False:
          keep_running = False
          logging.info(f"reached final waypoint: {idx_wp}.")
        watchdog.input_int_register_0 = 1
      elif not move_completed and state.output_int_register_0 == 0: # moving
        nprint("move to confirmed pose: ", state.target_q)
        move_completed = True
        watchdog.input_int_register_0 = 0
      elif ((tnow-t0) >= cfg.runtime_max): # timeout
        logging.warning("runtime timeout: "+str(cfg.runtime_max)+" sec.")
        keep_running = False
      # else: # get new sample
      idx += 1
  except KeyboardInterrupt: #todo add keyboard interrupt to end recording session
    logging.info("keyboard interrupt recieved.")
    keep_running = False
  except rtde.RTDEException:
    logging.error("RTDE exception recieved.")
    con_ur5e.disconnect()
  logging.info("end of data collection.")

  con_ur5e.send_pause()
  con_ur5e.disconnect()

  logging.info('<<----- end of main ----->>')
  logging.info('<<----- post-processing ----->>')

  dmm.sav_logs(dset) # save data log to file

  # st()
  # st()

  # quat_meas_df = pd.DataFrame(qekf.log.z_hist[:,6:10],
  #                             index=qekf.log.idx,
  #                             columns=['qx', 'qy', 'qz', 'qw'])# change to xyzw
  # # x_quat_wxyz
  # quat_est_df = pd.DataFrame(qekf.log.x_hist[:,6:10],\
  #   index=qekf.log.idx,\
  #   columns=['qx', 'qy', 'qz', 'qw'])

  # # plot EKF output
  # fignum+=1;
  # plot_quat_vs_quat(quat_A_df=quat_meas_df,
  #   quat_B_df=quat_est_df,
  #   title='z vs x_prior free range',
  #   fignum=fignum,
  #   show=_show,
  #   colors=['maroon','darkgoldenrod'],
  #   save=True,
  #   output_dir=dset.output_dir,
  #   start=dset.start,
  #   end=dset.end,
  #   labels=['meas.', 'est.'])

  return # main


if __name__ == "__main__":
  main()
  print('---------   End   ---------')
# EOF
