

import logging, time
import os
# from plyfile import plydata
import open3d as o3d
import numpy as np
import pandas as pd

from nbug import *
from pdb import set_trace as st


import numpy as np
import open3d as o3d

""" HSV Color limits
  Hue values:
    red = [0, 30] & [325, 360]
    blue = [175, 265]
"""


def rFile_ply(fname, _shw=False):
  ''' read XYZRGB point cloud from file with ply ext '''
  assert(os.path.isfile(fname)), "\n\n \-->> file does not exist!\n"

  pcd = o3d.io.read_point_cloud(fname)
  if _shw:
    o3d.visualization.draw_geometries([pcd])
  pcPoints = np.asarray(pcd.points)
  pcColors = np.asarray(pcd.colors)
  nPnts = pcColors.shape[0]
  nsprint("pcPoints", pcPoints)
  nsprint("pcColors", pcColors)
  nprint("pcPoints", pcPoints)
  nprint("pcColors", pcColors)

  # segmentation

  pcAnnots = np.zeros((nPnts, 1)) # per pixel binary annotation
  for i in range(nPnts):
    r,g,b = pcColors[i,:]
    h,s,v = colorsys.rgb_to_hsv(r,g,b)
    nprint("rgb", [r,g,b])
    nprint("hsv", [h,s,v])
    st()



    # if
  st()
  # num_verts = ply['vertex'].count
  # vertices = np.zeros(shape=[num_verts, 6], dtype=np.float32)
  # vertices[:,0] = ply['vertex'].data['x']
  # vertices[:,1] = ply['vertex'].data['y']
  # vertices[:,2] = ply['vertex'].data['z']
  # vertices[:,3] = ply['vertex'].data['red']
  # vertices[:,4] = ply['vertex'].data['green']
  # vertices[:,5] = ply['vertex'].data['blue']




def main():
  logging.basicConfig(filename="main.log", filemode='w', level=logging.DEBUG, format='[log]-->> %(message)s') #, datefmt='%m/%d/%Y %I:%M:%S %p')

  ''' init cfg '''
  datDir = "../set_0002/big_blue/t001/ply/"
  fname01 = "t001__1682969798977.04077148437500.ply"
  fname02 = "t001__1682969799010.36572265625000.ply"

  file = os.path.join(datDir, fname01)

  pc =  rFile_ply(file)
  st()


  logging.info('<<----- end of main ----->>')
  print('<<----- end of main ----->>')

  # if URROB_EN:
    # dmm.sav_logs(dset) # save data log to file

  return # main
if __name__ == "__main__":
  main()
  print('---------   End   ---------')
  #exit()
# EOF
