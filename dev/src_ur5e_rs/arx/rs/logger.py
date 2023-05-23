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
      logging.info("logger is enabled.")
      self.idx_hist = None
      self.wp_hist = None
      self.st_timestamp_hist = None



    else:
      logging.error("dlm is disabled.")
    return



  def log_fr(self, idx:int, idx_wp:int, frames):
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
