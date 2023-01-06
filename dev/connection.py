import socket
import time

HOST = "192.168.1.147"
PORT = 30002

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST,PORT))

'''
  send a code script to robot, i.e., waypoints, IO, or functions to be executed
  The “\n” is the newline which has to be added after the script code, because
  the UR needs a newline after each command sent. In this case, for socket
  communication, the strings being sent need to be encoded in “utf8” which is
  character encoding. Python 3 does not support Unicode() function and all
  strings by default are unicode.
'''
s.send((“set_digital_out(0,True)”+”\n”).encode(‘utf8’))
