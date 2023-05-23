
import os
import subprocess
import time

from pdb import set_trace as st

srcDir = './'

def rsParseAll():
  for i, file in enumerate(sorted(os.listdir(srcDir))):
    if os.path.isfile(file) and file.endswith(".bag"):
      fnum = int(file.split('.')[0])
      # st()
      tag = "t"+str(fnum).zfill(3)
      if os.path.exists(tag):
        print(f" \--->> dir exists: {tag}, skipping...")
        continue
      else:
        print(f" \--->> now parsing {fnum}: {file}")
        outFile = os.path.join("./", tag, f"{tag}.log")
        # outlogger = f"1> {outFile}.out  2> {outFile}.err"
        # subprocess.Popen(["nohup", "bash", "./rs_parsebag.sh", file, tag, outFile])
        # subprocess.Popen(["nohup", "bash", "-c", "./rs_parsebag.sh", file, tag, outlogger])
        subprocess.Popen(["./rs_parsebag.sh", file, tag])
                                #  stdout=subprocess.PIPE,
                                #  stderr=subprocess.PIPE,
                                #  shell=True)
        # while proc.poll() is None:
          # print(f" \--->> {tag}: running...")
          # time.sleep(1)
        # out = proc.poll() == 0
        # print(f" \--->> {tag} output pass: {out}")
        # output, error = proc.communicate()
        # with open(outFile, 'a') as f:
        #   print(output)
        #   print(error)


# 0, means the shell
        #subprocess.Popen(["mv", file, os.path.join("./", tag,file)])
  return # rsParseAll()

def rename_files():
  for i, file in enumerate(os.listdir(srcDir)):
    if os.path.isfile(file):
      newfile = file
      newfile = newfile.replace(' ', '_').lower()
      newfile = newfile.replace('&', 'n')
      newfile = newfile.replace(',', '')
      newfile = newfile.replace('and', 'n')
      newfile = newfile.replace("'", '')
      newfile = newfile.replace('-', '_')
      newfile = newfile.replace('__', '_')
      newfile = newfile.replace('__', '_')
      src = srcDir+file
      dest = srcDir+newfile
      os.rename(src,dest)
      print(i, file)

  print('files renamed... ')
  for i, file in enumerate(os.listdir(srcDir)):
    print(i, file)
  return # rename files

if __name__ == '__main__':

  rsParseAll()


# EOF
