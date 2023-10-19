
import os
import subprocess
import time
import glob

from pdb import set_trace as st

srcDir = './'
# fileExt = ".bag" #
dirs = ["ply", "png", "raw"]

def tree_fCount():
  for tDir in sorted(os.listdir(srcDir)):
    if os.path.isdir(tDir):
      print(f"\--> {tDir}/")
      for d in os.listdir(tDir):
        if d in dirs:
          fExt = "*."+d
          cnt = len(glob.glob1(os.path.join(srcDir,tDir,d),fExt))
          print(f"  \--> {tDir}/{d}: {cnt}")
      print(" ")
  return # tree_fCount()


if __name__ == '__main__':

  tree_fCount()


# EOF
