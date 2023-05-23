import logging
import numpy as np
import pandas as pd
import csv
import os.path as osp


from pdb import set_trace as st
from nbug import *


class dmm:
  ''' data management mod '''
  def __init__(self):
    # files and dirs
    self.todir = None
    self.wps_file = None
    self.st_file = None
    self.pc_file = None
    self.rgb_file = None
    self.dm_file = None
    self.st_dir = None

    # self.pc_dir = None
    # self.rgb_dir = None
    # self.dm_dir = None


    # run time config
    # labels, units, and dtypes
    self.st_labs = None
    self.st_dtypes = None
    #cfg.st_units = ???
    self.wps_labs = None
    self.wps_units = None
    # __init__()

  def load_cfg(self, cfg):
    # files and dirs
    self.todir = cfg.todir
    self.wps_file = cfg.wps_file
    self.st_file = cfg.st_file
    self.st_dir = cfg.st_dir
    # self.pc_file = cfg.pc_file
    # self.rgb_file = cfg.rgb_file
    # self.dm_file = cfg.dm_file
    # self.pc_dir = cfg.pc_dir
    # self.rgb_dir = cfg.rgb_dir
    # self.dm_dir = cfg.dm_dir

    # run time config
    self.st_labs = cfg.st_labs
    self.st_dtypes = cfg.st_dtypes
    self.wps_labs = cfg.wps_labs
    self.wps_units = cfg.wps_units
    return # load_cfg()

  def sav_wps(self, wps):
    ''' save waypoints '''
    wps_np = np.asarray(wps)
    np.savetxt(self.wps_file, wps_np, delimiter=", ", header=", ".join(self.wps_labs)) # type: ignore
    return # sav_wps()



  def sav_st_cfg(self):
    with open(osp.join(self.st_dir+"/st_info.txt"), "a") as file:
      file.write("state data")
      file.write("labels: ")
      file.write(', '.join(self.st_labs))
      #file.write("units: ")
      #file.write(', '.join(self.st_units))
      file.write("dtypes: ")
      file.write(', '.join(self.st_dtypes))
      # file.write("config: ")
      # file.write(', '.join(self.st_cfg)) #todo consolidate all into a cfg obj
    return

  def sav_logs(self, log):
    self.sav_st(log)
    #self.sav_pc(log)
    #self.sav_rgb(log)
    #self.sav_dm(log)

    return

  def sav_st(self, log):

    lab_list = self.st_labs
    dat_list = [ log.idx_hist,
                 log.wp_hist,
                 log.fr_tstamp_hist,
                 # add logs here
                 log.st_timestamp_hist,
                 log.st_robot_mode_hist,
                 log.st_target_q_hist,
                 log.st_actual_q_hist,
                 log.st_actual_qd_hist,
                 log.st_target_TCP_pose_hist,
                 log.st_actual_TCP_pose_hist,
                 log.st_actual_TCP_speed_hist,
                 log.st_output_int_register_0_hist]
    fname = osp.join(self.st_dir, "data.csv")
    self.sav_stream(lab_list, dat_list, fname) # sav data frames
    return

  def sav_stream(self, labs, dats, fname):
    assert len(labs)==len(dats), "number of labels and data streams don't match!"
    df = pd.DataFrame()
    for i_l, l in enumerate(labs):
      # nprint("label", l)
      # nprint(f"dat[{i_l}]", l)
      dat = dats[i_l]
      for c in range(dat.shape[1]):
        if dat.shape[1] > 1:
          lab = '_'.join([l, f"{c}"])
        else:
          lab = l
        df[lab] = dat[:,c].tolist()
      # nprint("df", df)
      # st()
    with open(fname, 'w') as f:
      df.to_csv(f)
    return df
