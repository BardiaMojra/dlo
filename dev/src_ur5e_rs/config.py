
import sys, os
from nbug import *
from pdb import set_trace as st

import logging, yaml
import os.path as osp
from datetime import datetime
import rtde.rtde as rtde
import rtde.rtde_config as rtde_config


# TIMESTAMP_TID = False
TIMESTAMP_TID = True


def get_labels_from_xml(xml_file):
  conf = rtde_config.ConfigFile(xml_file)
  state_names, state_types = conf.get_recipe("state")
  return state_names

def get_dtypes_from_xml(xml_file):
  conf = rtde_config.ConfigFile(xml_file)
  state_names, state_types = conf.get_recipe("state")
  return state_types

class configuration(object):
  """ config (cfg) """
  def __init__(self, *args):
    # proj cfg
    self.__header__ = str(args[0]) if args else None
    self.tname = "basic_x" # test name
    self.tnum = 1 # test num
    self.wdir = os.getcwd() # working dir
    self.odir = osp.normpath(osp.join(osp.join(self.wdir,".."),"out"))
    self.log_file = osp.normpath(osp.join(self.wdir,"main.log"))
    # self.log_file = osp.normpath(osp.join(self.odir,"main.log"))
    self.tdtime = datetime.now().strftime("%Y-%m-%d_%H-%M-%S") # time tag
    if TIMESTAMP_TID:
      self.tid = '_'.join([f"{self.tnum:03}", self.tname, self.tdtime]) # test id (num + name + datetime)
    else:
      self.tid = '_'.join([f"{self.tnum:03}", self.tname]) # test id (num + name)
    self.todir = osp.join(self.odir,self.tid) # test output directory
    # test files n dirs
    self.todir = osp.join(self.odir,self.tid) # test output directory
    self.cfg_file = osp.join(self.todir,"self.yml")
    self.notes_file = osp.join(self.todir,"notes.txt")
    # waypoints cfg
    self.wps_file = osp.join(self.todir,"wps.txt") # waypoints
    self.wps_units = ["m","m","m","rad","rad","rad"]
    self.wps_labs = ["x","y","z","rx","ry","rz"]
    # rsDevice cfg
    self.rs_dir = osp.join(self.todir,"frames") # frames dir
    self.rs_freq = 30 # Hz
    # urRobot cfg
    self.st_dir = osp.join(self.todir,"states") # states dir
    self.rtde_cfg_file = osp.join(self.wdir,"comms_config.xml")
    # self.ur_file = osp.join(self.todir,"urRobot.txt") # state frames
    self.ur_freq = 125 # Hz
    self.ur_host = "192.168.1.147"
    self.ur_port = 30004
    self.st_file =  osp.join(self.st_dir,"states.txt")
    self.st_labs = get_labels_from_xml(self.rtde_cfg_file)
    self.st_dtypes = get_dtypes_from_xml(self.rtde_cfg_file)
    self.st_labs = ["idx", "idx_wps", "frs_tstamp"] + self.st_labs
    self.st_dtypes = ["INT", "INT", "FLOAT"] + self.st_dtypes
    # test details
    self.dlo_name = "reinforced tube"
    self.dlo_length = "1000 mm"
    self.dlo_diameter = "50 mm"
    # run time flags
    # self._nbug = True
    # self._prt = True # prt to term
    # self._shw = True
    # self._repeat_wps = False

    # __init__()

  def __repr__(self):
    if self.__header__ is None:
      return super(configuration, self).__repr__()
    return self.__header__

  def next(self):
    """ Fake iteration functionality.
    """
    raise StopIteration

  def __iter__(self):
    """ Fake iteration functionality.
    We skip magic attribues and configurations, and return the rest.
    """
    ks = self.__dict__.keys()
    for k in ks:
      if not k.startswith('__') and not isinstance(k, configuration):
        yield getattr(self, k)

  def __len__(self):
    """ Don't count magic attributes or configurations.
    """
    ks = self.__dict__.keys()
    return len([k for k in ks if not k.startswith('__')\
                and not isinstance(k, configuration)])

  def init(self):
    self.init_odirs()
    self.init_subdirs()
    #self.init_cfg_file() # sav cfg to file
    #self.init_notes_file() #
    #self.init_st_file()
    return

  def init_odirs(self):
    ks = self.__dict__.keys()
    for k in ks:
      if not k.startswith("__") and not isinstance(k, configuration):
        if k == "odir":
          self.check_n_mkdir(getattr(self, k), False)
        elif k == "todir":
          self.check_n_mkdir(getattr(self, k), True)
    return

  def check_n_mkdir(self, subdir, needEmpty=True):
    if not os.path.exists(subdir):
      print("DOES NOT EXIST: \n" + subdir)
      print("IT WILL BE CREATED.... \n")
      os.makedirs(subdir)
    else:
      if needEmpty == True:
        print("DOES EXIST: \n" + subdir)
        logging.error("SUBDIR CONFLICT!!!")
        exit()
      else:
        print("DOES EXIST: \n" + subdir)
        print("Use existing dir: " + subdir+"\n")
    return

  def init_subdirs(self):
    ks = self.__dict__.keys()
    for k in ks:
      if not k.startswith("__") and \
        not isinstance(k, configuration) and \
        k.endswith("_dir"):
        if not os.path.exists(getattr(self, k)):
          print("DOES NOT EXIST: {} \n".format(k)+getattr(self, k)+"\n")
          os.makedirs(getattr(self, k))
        else:
          logging.error("subdir exists, but it should not!!!")
          exit()
    return

  def init_cfg_file(self):
    ks = self.__dict__.keys()
    for k in ks:
      if not k.startswith("__") and not isinstance(k, configuration) and \
        k == "cfg_file":
        if not os.path.exists(getattr(self, k)):
          print("DOES NOT EXIST: {} \n".format(k)+getattr(self, k)+"\n")
          with open(getattr(self, k), 'w') as f:
            yaml.dump(self, f)
          # with open(getattr(self, k), 'a') as f:
          #   f.write("{}: \n".format(getattr(self, "__header__")))
          #   for prop in ks:
          #     if not prop.startswith("__") and not isinstance(prop, configuration):
          #       f.write("  {}: {} \n".format(prop, getattr(self, prop)))
        else:
          logging.error("cfg_file EXISTS, but it should not!!!")
          exit()
    return

  def init_notes_file(self):
    ks = self.__dict__.keys()
    for k in ks:
      if not k.startswith("__") and not isinstance(k, configuration) and \
        k == "notes_file":
        if not os.path.exists(getattr(self, k)):
          print("DOES NOT EXIST: {} \n".format(k)+getattr(self, k)+"\n")
          with open(getattr(self, k), 'a') as f:
            f.write("Notes: \n")
        else:
          logging.error("notes_file EXISTS, but it should not!!!")
          exit()
    return

  def init_st_file(self):
    ks = self.__dict__.keys()
    for k in ks:
      if not k.startswith("__") and not isinstance(k, configuration) and \
        k == "st_file":
        if not os.path.exists(getattr(self, k)):
          print("DOES NOT EXIST: {} \n".format(k)+getattr(self, k)+"\n")
          with open(getattr(self, k), 'a') as f:
            f.write("{} \n".format(", ".join(getattr(self, "st_labs"))))
        else:
          logging.error("notes_file EXISTS, but it should not!!!")
          exit()
    return

  def init_files(self):
    ks = self.__dict__.keys()
    for k in ks:
      if not k.startswith('__') and \
        not isinstance(k, configuration) and \
        k.endswith('_file'):
        if not os.path.exists(k):
          print("DOES NOT EXIST: \n"+k)
          os.makedirs(k)
        else:
          logging.error("subdir exists, but it should not!!!")
          exit()
    return

  def prt(self):
    print("cfg:")
    pp(self.__dict__)
    return
