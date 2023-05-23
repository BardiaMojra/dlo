

import logging, time
import numpy as np
import cv2


''' local '''

import rtde.rtde as rtde
from config import configuration as cfg_cls
from dmm import dmm as dmm_cls
from dlm import dlm as dlm_cls
from rs_device import rsDevice
from urBot import urRobot


''' NBUG '''
from pdb import set_trace as st
from nbug import *



''' config '''
SHW_en = False; REC_en = True # Record Mode
#SHW_en = True; REC_en = False # View Mode
SAV2FILE = False
URROB_EN = False
RSDEV_EN = True
PAUSED_START_EN = False



''' local routines '''
def init_vis2D():
  if SHW_en:
    cv2.namedWindow('Color & Depth Streams', cv2.WINDOW_AUTOSIZE)
    #cv2.namedWindow("Depth Color Map Stream", cv2.WINDOW_AUTOSIZE)
    # cv2.resizeWindow(state.WIN_NAME, w, h)
    # cv2.setMouseCallback(state.WIN_NAME, mouse_cb)
  return

def vis_render2D(frs):
  if SHW_en:
    img = cv2.cvtColor(frs.rgb, cv2.COLOR_RGB2BGR)
    dcmbgr = cv2.cvtColor(frs.dcmap, cv2.COLOR_RGB2BGR)
    if dcmbgr.shape != img.shape:
      nimg = cv2.resize(img, dsize=(dcmbgr.shape[1], dcmbgr.shape[0]), interpolation=cv2.INTER_AREA)
      images = np.hstack((nimg, dcmbgr))
    else:
      images = np.hstack((img, dcmbgr))
    cv2.imshow('Color & Depth Streams', images)
  return

def vis_close():
  if SHW_en:
    cv2.destroyWindow('Color & Depth Streams')
  return


class wpoints_cls:
  ''' waypoints class ''' # pose  [m & rad] - in tool space
  def __init__(self, *args, **kwargs):
    self.labs = ["x","y","z","rx","ry","rz"]
    self.units = ["m","m","m","rad","rad","rad"]
    self.wp_home   = [ 0.00, -0.680, 0.650, 0, -2.2, 2.2]
    self.wp_left   = [ 0.24, -0.680, 0.650, 0, -2.2, 2.2]
    self.wp_right  = [-0.24, -0.680, 0.650, 0, -2.2, 2.2]
    self.wpoints = [self.wp_home,
                    self.wp_right,
                    self.wp_left,
                    self.wp_right,
                    self.wp_left,
                    self.wp_right,
                    self.wp_left,
                    self.wp_right,
                    self.wp_left,
                    self.wp_right,
                    self.wp_left,
                    self.wp_home]
    self.len = len(self.wpoints)
  # ---------------------------------------------------------------- wpoints_cls
class opt_cls:
  ''' operational vars class '''
  def __init__(self, *args, **kwargs):
    self.lp_stime = time.time()
    self.lp_dur = 0.0
    self.prog_stime = 0.0
    self.fps = 0
    self.lp_etime = 0.0
    self.idx = 0 # data sample counter
    self.idx_wp = 0 # waypoint cntr
    self.keep_running = True
    # self.moves_completed = False
    self.runtime_max = 5.0 # [sec]
    self.runtime_max_en = True # self terminate for bagfile graceful writes
    self.rpt_wps_en = True
    # self._nbug = True
    # self._prt = True # prt to term
    # self._shw = True

  def init_ptime(self):
    self.prog_stime = time.time()
    return

  def update_fps(self):
    self.lp_dur = time.time() - self.lp_stime
    self.fps = int(1.0/self.lp_dur)
    self.lp_stime = time.time()

  def check_runtime(self):
    if self.runtime_max_en:
      if ((time.time()-self.prog_stime) >= self.runtime_max): # timeout
        logging.warning(f"runtime timeout: {self.runtime_max} sec.")
        self.keep_running = False
    return # check_runtime()

  def check_key(self, key):
    if key & 0xFF == ord('q') or key == 27:
      self.keep_running = False
    return # check_key()
  # ------------------------------------------------------------------- opt_cls




def main():
  if SHW_en and REC_en:
    assert ~(SHW_en is True and REC_en is True),"both SHW_en and REC_en can NOT be True"
    exit()
  logging.basicConfig(filename="main.log", filemode='w', level=logging.DEBUG, format='[log]-->> %(message)s') #, datefmt='%m/%d/%Y %I:%M:%S %p')

  ''' init cfg '''
  cfg = cfg_cls("DLO Dataset Test Config");
  cfg.init()
  wps = wpoints_cls() # waypoints
  dmm = dmm_cls(); dmm.load_cfg(cfg)
  dmm.sav_wps(wps.wpoints)
  dset = dlm_cls() # data log class

  if RSDEV_EN:
    rscam = rsDevice(); rscam.load_cfg(cfg)
    rscam.init_recorder(REC_en)
    # init_vis2D()

  # cv2.namedWindow('Color & Depth Streams', cv2.WINDOW_AUTOSIZE)

  #v3D = vis3D()
  # v3D.load_cfg(cfg)
  #v3D.init_phCam_v3D(frs=rscam.get_intr())


  if URROB_EN:
    rob = urRobot("UR5e"); rob.load_cfg(cfg)
    rob.init_rob()

  opt = opt_cls() # opt vars

  if PAUSED_START_EN:
    input("Press any key to continue...")

  li = 0
  opt.init_ptime()
  while opt.keep_running:  # ---------------------- main loop
    opt.update_fps()
    # logging.info(f"idx:{opt.idx:06d} - fps:{opt.fps}")
    # print(f"idx:{opt.idx:06d} - fps:{opt.fps}")


    if RSDEV_EN and li == 0:
      frames = rscam.get_frames(opt.idx, SAV2FILE)
      rscam.check_frames(opt.idx, frames, opt.lp_dur)
      # vis_render2D(frames)
      # v3D.renderAll(opt, frames)

    # st()
    #-----------------------------------------------------------------------
    if URROB_EN:
      state = rob.get_state(opt.idx)
      if state is None:
        logging.warning(f"idx:{opt.idx} - Null state returned.")
        continue
      rob.prt_st(opt)
      # prt_state(opt.idx, state, opt.idx_wp) # print state to terminal
      #dset.log_st(opt.idx, opt.idx_wp, state, frames)
      rob.check_wps(opt, state, wps)
    #----------------------------------------------------------------- loop end
    opt.check_runtime()
    if li == 4: li = 0 # sampling counter update
    else: li += 1
    # if SHW_en:
      # key = cv2.waitKey(1)
      # opt.check_key(key)
    opt.idx += 1
  # ---------------------------------------------------- while opt.keep_running:
  logging.info(f"idx:{opt.idx} - end of data collection.")


  if URROB_EN:
    rob.pause_discon()

  if RSDEV_EN:
    rscam.stop_streams()
    vis_close()


  logging.info('<<----- end of main ----->>')
  logging.info('<<----- post-processing ----->>')
  print('<<----- end of main ----->>')
  print('<<----- post-processing ----->>')

  # if URROB_EN:
    # dmm.sav_logs(dset) # save data log to file

  return # main


if __name__ == "__main__":
  main()
  print('---------   End   ---------')
  #exit()
# EOF
