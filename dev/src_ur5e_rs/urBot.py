
import logging, yaml
# import open3d as o3d
from datetime import datetime


# moveit example
# @link https://github.com/vfdev-5/move_group_tutorial_ur5/blob/master/src/move_group_tutorial_ur5.py

# @link https://robodk.com/download
# @link https://robodk.com/doc/en/Post-Processors.html

# @link https://axisnj.com/controlling-a-universal-robots-cobot-using-python/


import numpy as np
import rtde.rtde as rtde
import rtde.rtde_config as rtde_config
from config import configuration as cfg_cls
import rtde.csv_writer as csv_writer

from nbug import *
from pdb import set_trace as st
import os.path as osp

def setp_to_list(setp):
  list = []
  for i in range(0,6):
    list.append(setp.__dict__["input_double_register_%i" % i])
  return list

def list_to_setp(setp, list):
  for i in range (0,6):
    setp.__dict__["input_double_register_%i" % i] = list[i]
  return setp

def setwp(setp, wp):
  setp.__dict__["input_int_register_1"] = wp
  return setp

def get_labels_from_xml(xml_file):
  conf = rtde_config.ConfigFile(xml_file)
  state_names, state_types = conf.get_recipe("state")
  return state_names

def get_dtypes_from_xml(xml_file):
  conf = rtde_config.ConfigFile(xml_file)
  state_names, state_types = conf.get_recipe("state")
  return state_types

global conn
global setp
global watchdog
# global urOpt

class urRobot:
  ''' universal robot class
    @brief this class/mod handles ur robot config, init, and API.
    @link
  '''
  # setp = None
  # watchdog = None
  # conn = None
  def __init__(self, name="urRobot", *args, **kwargs):
    # cfg
    self.name = name
    self.todir = "../out/"
    self.rob_id = 0 #
    self.freq = 125 # Hz - 125 min
    self.host = "192.168.1.147" # type: ignore
    self.port = 30004 # type: ignore
    self.rtde_cfg_file = osp.join("./","comms_config.xml") # type: ignore
    self.st_file = None
    self.rMode = { # @source ClientInterfaces_Realtime.pdf
                  -1: "NO_CONTROLLER",
                    0: "DISCONNECTED",
                    1: "CONFIRM_SAFETY",
                    2: "BOOTING",
                    3: "POWER_OFF",
                    4: "POWER_ON",
                    5: "IDLE",
                    6: "BACKDRIVE",
                    7: "RUNNING",
                    8: "UPDATING_FIRMWARE",
                  }
    self.tMode = { # @source ClientInterfaces_Realtime.pdf
                     235: "JOINT_MODE_RESET",
                     236: "JOINT_MODE_SHUTTING_DOWN",
                     239: "JOINT_MODE_POWER_OFF",
                     245: "JOINT_MODE_NOT_RESPONDING",
                     247: "JOINT_MODE_BOOTING",
                     249: "JOINT_MODE_BOOTLOADER",
                     252: "JOINT_MODE_FAULT",
                     253: "JOINT_MODE_RUNNING",
                     255: "JOINT_MODE_IDLE",
                 }
   # setp = None
    # watchdog = None
    # conn = None




    # self.st_dir = osp.join(self.todir,"states") # states dir
    # self.rtde_cfg_file = osp.join(self.wdir,"comms_config.xml")
    # #self.ur_file = osp.join(self.todir,"urRobot.txt") # state frames
    # self.ur_freq = 125 # Hz
    # self.ur_host = "192.168.1.147"
    # self.ur_port = 30004
    # self.runtime_max = 30 # [sec]
    # # labels, units, and dtypes
    # self.st_file =  osp.join(self.st_dir,"states.txt")
    # self.st_labs = get_labels_from_xml(self.rtde_cfg_file)
    # self.st_dtypes = get_dtypes_from_xml(self.rtde_cfg_file)
    # self.st_labs = ["idx", "idx_wps", "frs_tstamp"] + self.st_labs
    # self.st_dtypes = ["INT", "INT", "FLOAT"] + self.st_dtypes
    # # test details
    # self.dlo_name = "reinforced tube"
    # self.dlo_length = "1000 mm"
    # self.dlo_diameter = "50 mm"
    # # run time flags
    # self._nbug = True
    # self._prt = True # prt to term
    # self._shw = True
    # self._repeat_wps = False



  def init_cfg(self):
    self.st_labs = get_labels_from_xml(self.rtde_cfg_file) # type: ignore
    self.st_dtypes = get_dtypes_from_xml(self.rtde_cfg_file) # type: ignore
    self.st_labs = ["idx", "idx_wps"] + self.st_labs # type: ignore
    self.st_dtypes = ["INT", "INT"] + self.st_dtypes # type: ignore
    return

  def load_cfg(self, cfg):
    self.todir = cfg.st_dir
    # self.freq = cfg.ur_freq
    # self.host = cfg.ur_host
    # self.port = cfg.ur_port
    self.rtde_cfg_file = cfg.rtde_cfg_file
    self.st_file = cfg.st_file
    self.st_labs = cfg.st_labs
    self.st_dtypes = cfg.st_dtypes
    return # load_cfg()

  def init_rob(self):
    global setp, watchdog, conn
    self.rtde_cfg = rtde_config.ConfigFile(self.rtde_cfg_file)
    st_labs, st_dtypes = self.rtde_cfg.get_recipe("state")
    setp_labs, setp_dtypes = self.rtde_cfg.get_recipe("setp")
    # wd_labs, wd_dtypes = self.rtde_cfg.get_recipe("watchdog")
    # urOpt_labs, urOpt_dtypes = self.rtde_cfg.get_recipe("urOpt")
    conn = rtde.RTDE(self.host, self.port)
    conn.connect()
    conn.get_controller_version()
    # setup recipes
    conn.send_output_setup(st_labs, st_dtypes, frequency=self.freq)
    setp = conn.send_input_setup(setp_labs, setp_dtypes)
    # watchdog = conn.send_input_setup(wd_labs, wd_dtypes)
    # urOpt = conn.send_input_setup(urOpt_labs, urOpt_dtypes)
    setp.input_double_register_0 = 0
    setp.input_double_register_1 = 0
    setp.input_double_register_2 = 0
    setp.input_double_register_3 = 0
    setp.input_double_register_4 = 0
    setp.input_double_register_5 = 0
    # setp.input_int_register_0 = -1
    # watchdog.input_int_register_0 = 0 # rtde_set_watchdog() in rtde_control_loop.urp creates a 1 Hz watchdog
    setp.output_int_register_1 = 0
    if not conn.send_start():
      logging.error("NULL state returned.")
      sys.exit() # start data synchronization
    return # init_rob

  def get_state(self, idx):
    global conn, setp, watchdog
    state = conn.receive()
    if state is None: # or frame is None:
      logging.error("NULL state or frame.")
      return None
    state.idx = idx # type: ignore
    self.state = state
    return state # get_state

  def check_wps(self, opt, st, wp):
    global conn, setp, watchdog
    # conn.send(watchdog)
    opt.ur_ready = self.eval_input_0(st)
    if not opt.ur_ready: # moving btw wps
      logging.info("[busy moving!](idx:{0}|fps:{5}|wp:{6}):[{1}][ready:{4}][pos_a:{3}]".format(f"{st.idx}", f"{self.rMode.get(st.robot_mode)}", pos_t, pos_a, f"{ready}",opt.fps, opt.idx_wp))

      # logging.info(f"cwps(idx:{opt.idx}):[ready:{opt.ur_ready}][wp:{opt.idx_wp:02d}/{wp.len:02d}][rpt_en:{opt.rpt_wps_en}][fps:{opt.fps:02d}]: busy moving!")
    elif opt.ur_ready and opt.idx_wp < wp.len-1: # next wp
      opt.idx_wp += 1
      new_setp = wp.wpoints[opt.idx_wp]
      list_to_setp(setp,new_setp)
      setwp(setp, opt.idx_wp)
      conn.send(setp)
      # logging.info(f"cwps(idx:{opt.idx}): new waypoint: {new_setp}.")
      # logging.info(f"cwps(idx:{opt.idx}):[ready:{opt.ur_ready}][wp:{opt.idx_wp:02d}/{wp.len:02d}][rpt_en:{opt.rpt_wps_en}][fps:{opt.fps:02d}]: go to next waypoint!")
      # logging.info("[Next WP!](idx:{0}|fps:{5}|wp:{6}):[{1}][ready:{4}][pos_a:{3}]".format(f"{st.idx}", f"{self.rMode.get(st.robot_mode)}", pos_t, pos_a, f"{ready}",opt.fps, opt.idx_wp))
    elif opt.ur_ready and opt.idx_wp == wp.len and opt.repeat_wps_en: # repeat/restart wps
      opt.idx_wp = 0
      logging.info(f"cwps(idx:{opt.idx}):[ready:{opt.ur_ready}][wp:{opt.idx_wp:02d}/{wp.len:02d}][rpt_en:{opt.rpt_wps_en}][fps:{opt.fps:02d}]: restart waypoints!")
    elif opt.ur_ready and opt.idx_wp == wp.len and not opt.repeat_wps_en: # stop wps
      opt.keep_running = False
      logging.info(f"cwps(idx:{opt.idx}):[ready:{opt.ur_ready}][wp:{opt.idx_wp:02d}/{wp.len:02d}][rpt_en:{opt.rpt_wps_en}][fps:{opt.fps:02d}]: stop!")
    elif rtde.RTDEException: # rtde.RTDEException: stop
      self.err_rtde()
      opt.keep_running = False
      logging.info(f"cwps(idx:{opt.idx}):[ready:{opt.ur_ready}][wp:{opt.idx_wp:02d}/{wp.len:02d}][rpt_en:{opt.rpt_wps_en}][fps:{opt.fps:02d}]: RTDEException --> stop!")
    else: # undefine state
      logging.info(f"cwps(idx:{opt.idx})[ready:{opt.ur_ready}][wp:{opt.idx_wp}/{wp.len}][rpt_en:{opt.rpt_wps_en}][fps:{opt.fps}]: undefine state!")
    return # check_wps()

  def err_rtde(self):
    global conn
    logging.error("RTDE exception recieved.")
    conn.disconnect()
    return # err_rtde()

  def pause_discon(self):
    global conn
    conn.send_pause()
    conn.disconnect()
    return

  def eval_input_0(self, st):
    if st.output_int_register_0 != 0: ready = True
    else: ready = False
    return ready # eval_input_0()


  def prt_st(self, opt):
    st = self.state
    precision = 2
    pos_t = ','.join(str(x) for x in [round(x,precision) for x in st.target_TCP_pose])
    pos_a = ','.join(str(x) for x in [round(x,precision) for x in st.actual_TCP_pose])
    ready = self.eval_input_0(st)
    logging.info("state(idx:{0}|fps:{5}|wp:{6}):[{1}][ready:{4}][pos_t:{2}][pos_a:{3}]".format(f"{st.idx}", f"{self.rMode.get(st.robot_mode)}", pos_t, pos_a, f"{ready}",opt.fps, opt.idx_wp))
    print("state(idx:{0}|fps:{5}|wp:{6}):[{1}][ready:{4}][pos_t:{2}][pos_a:{3}]".format(f"{st.idx}", f"{self.rMode.get(st.robot_mode)}", pos_t, pos_a, f"{ready}",opt.fps, opt.idx_wp))
    return # prt_st()

def main(): #todo ------------------------------------------------------- urBot
  cfg = cfg_cls("rsDevice cfg")
  cfg.init()

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
