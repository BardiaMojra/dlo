import logging
import pandas as pd
import numpy as np

from pdb import set_trace as st
from nbug import *

class dlm:
  ''' data log manager (dlm):
    log data on RAM memory at run-time so it can be
    processed and written to file at post-processing. This module uses
    operations that are much faster than writing to file. The dmm module is
    resposible for reading/writing data from/to file.

    - keep operations fast
    - the mod should remain independent other local modules
  '''
  def __init__(self, enabled=True):
    self.enabled = enabled
    if self.enabled == True:
      logging.info("dlm is enabled.")
      self.idx_hist = None
      self.wp_hist = None
      self.st_timestamp_hist = None
      self.st_robot_mode_hist = None
      self.st_target_q_hist = None
      self.st_actual_q_hist = None
      self.st_actual_qd_hist = None
      self.st_target_TCP_pose_hist = None
      self.st_actual_TCP_pose_hist = None
      self.st_actual_TCP_speed_hist = None
      self.st_output_int_register_0_hist = None
      # frames
      self.fr_tstamp_hist = None
      # self.fr_pc_hist = None # point cloud
      # self.fr_rgb_hist = None # rgb
      # self.fr_d_hist = None # depth
    else:
      logging.error("dlm is disabled.")
    return


  def log_st(self, idx:int, idx_wp:int, state, frames):
    FRAMES_EN = False

    if state is None:
      logging.error("state is None.")
      exit()
    if frames is None and FRAMES_EN is True:
      logging.error("frames is None.")
      exit()
    #st()
    #if (self.fr_tstamp is None):
    #  logging.info("starting new frames log.")

    if (self.idx_hist is None) or \
        (self.wp_hist is None) or \
        (self.st_timestamp_hist is     None) or \
        (self.st_robot_mode_hist is None) or \
        (self.st_target_q_hist is None) or \
        (self.st_actual_q_hist is None) or \
        (self.st_actual_qd_hist is None) or \
        (self.st_target_TCP_pose_hist is None) or \
        (self.st_actual_TCP_pose_hist is None) or \
        (self.st_actual_TCP_speed_hist is None) or \
        (self.st_output_int_register_0_hist is None) or \
        (self.fr_tstamp_hist is None and FRAMES_EN is True):
      logging.info("starting new state log.")
      self.idx_hist = np.copy(np.asarray(idx).reshape((1,-1)))
      self.wp_hist = np.copy(np.asarray(idx_wp).reshape((1,-1)))
      if FRAMES_EN is True:
        self.fr_tstamp_hist = np.copy(np.asarray(frames.tstamp).reshape((1,-1)))

      # nprint("state.timestamp", state.timestamp)
      # nprint("state.robot_mode", state.robot_mode)
      # nprint("state.target_q", state.target_q)
      # nprint("state.actual_q", state.actual_q)
      # nprint("state.actual_qd", state.actual_qd)
      # nprint("state.target_TCP_pose", state.target_TCP_pose)
      # nprint("state.actual_TCP_pose", state.actual_TCP_pose)
      # nprint("state.actual_TCP_speed", state.actual_TCP_speed)
      # nprint("state.output_int_register_0", state.output_int_register_0)


      #st()

      self.st_timestamp_hist = np.copy(np.asarray(state.timestamp).reshape((1,-1)))
      self.st_robot_mode_hist = np.copy(np.asarray(state.robot_mode).reshape((1,-1)))
      self.st_target_q_hist = np.copy(np.asarray(state.target_q).reshape((1,-1)))
      self.st_actual_q_hist = np.copy(np.asarray(state.actual_q).reshape((1,-1)))
      self.st_actual_qd_hist = np.copy(np.asarray(state.actual_qd).reshape((1,-1)))
      self.st_target_TCP_pose_hist = np.copy(np.asarray(state.target_TCP_pose).reshape((1,-1)))
      self.st_actual_TCP_pose_hist = np.copy(np.asarray(state.actual_TCP_pose).reshape((1,-1)))
      self.st_actual_TCP_speed_hist = np.copy(np.asarray(state.actual_TCP_speed).reshape((1,-1)))
      self.st_output_int_register_0_hist = np.copy(np.asarray(state.output_int_register_0).reshape((1,-1)))

    else: # append log
      #st()
      self.idx_hist = np.concatenate((self.idx_hist, np.asarray(idx).reshape(1,-1)), axis=0)
      self.wp_hist = np.concatenate((self.wp_hist, np.asarray(idx_wp).reshape(1,-1)), axis=0)
      if FRAMES_EN is True:
        self.fr_tstamp_hist = np.concatenate((self.fr_tstamp_hist, np.asarray(frames.tstamp).reshape(1,-1)), axis=0)

      self.st_timestamp_hist = np.concatenate((self.st_timestamp_hist, np.asarray(state.timestamp).reshape(1,-1)), axis=0)
      self.st_robot_mode_hist = np.concatenate((self.st_robot_mode_hist, np.asarray( state.robot_mode).reshape(1,-1)), axis=0)
      self.st_target_q_hist = np.concatenate((self.st_target_q_hist, np.asarray(state.target_q).reshape(1,-1)), axis=0)
      self.st_actual_q_hist = np.concatenate((self.st_actual_q_hist, np.asarray(state.actual_q).reshape(1,-1)), axis=0)
      self.st_actual_qd_hist = np.concatenate((self.st_actual_qd_hist, np.asarray(state.actual_qd).reshape(1,-1)), axis=0)
      self.st_target_TCP_pose_hist = np.concatenate((self.st_target_TCP_pose_hist, np.asarray(state.target_TCP_pose).reshape(1,-1)), axis=0)
      self.st_actual_TCP_pose_hist = np.concatenate((self.st_actual_TCP_pose_hist, np.asarray(state.actual_TCP_pose).reshape(1,-1)), axis=0)
      self.st_actual_TCP_speed_hist = np.concatenate((self.st_actual_TCP_speed_hist, np.asarray(state.actual_TCP_speed).reshape(1,-1)), axis=0)
      self.st_output_int_register_0_hist = np.concatenate((self.st_output_int_register_0_hist, np.asarray(state.output_int_register_0).reshape(1,-1)), axis=0)

    # npprint("self.wp_hist", self.wp_hist)
    # npprint("self.idx_hist", self.idx_hist)
    # npprint("self.st_timestamp_hist", self.st_timestamp_hist)
    # npprint("self.st_robot_mode_hist", self.st_robot_mode_hist)
    # npprint("self.st_output_int_register_0_hist", self.st_output_int_register_0_hist)
    # npprint("self.idx_hist", self.idx_hist)
    # npprint("self.st_target_q_hist", self.st_target_q_hist)
    # npprint("self.st_actual_q_hist", self.st_actual_q_hist)
    # npprint("self.st_actual_qd_hist", self.st_actual_qd_hist)
    # npprint("self.st_target_TCP_pose_hist", self.st_target_TCP_pose_hist)
    # npprint("self.st_actual_TCP_pose_hist", self.st_actual_TCP_pose_hist)
    # npprint("self.st_actual_TCP_speed_hist", self.st_actual_TCP_speed_hist)
    # st()

    return # log_st()

  def log_rgb(self, idx:int, idx_wp:int, frames):
    if frames == None:
      logging.error("rgb is None.")
      exit()
    if  (self.idx_fr_hist == None) or \
        (self.dm_hist == None) or \
        (self.pc_hist == None) or \
        (self.rgb_hist == None):
      logging.info("starting new rgb log.")

      st()
      self.idx_hist = np.copy(np.asarray(idx).reshape((1,-1)))
      self.idx_fr_hist = np.zeros((1), dtype=int)
      self.rgb_hist = np.copy(np.asarray(rgb).flatten())


      nprint("rgb:", type(rgb))
      nprint("self.fr_rgb_hist:", type(self.fr_rgb_hist))
      st()
    else: # append log
      self.idx_rgb_hist = np.concatenate((self.idx_rgb_hist, np.asarray([idx])), axis=0)
      self.fr_rgb_hist = np.concatenate((self.fr_rgb_hist, np.asarray(rgb).flatten()), axis=0)
      nprint("rgb:", type(rgb))
      nprint("self.fr_rgb_hist type", type(self.fr_rgb_hist))
      nprint("self.fr_rgb_hist ", self.fr_rgb_hist)
      st()
    return # log_rgb()



# end of file
