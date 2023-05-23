"""Utility to send commands and receive responses from the Dashboard server. Please use 'exit' or 'e'
   to stop running and close the socket.
"""
import socket
import sys
import logging

# Enter robot IP address here.
host = '192.168.208.128'


class Dashboard:
    def __init__(self, robotIP):
        self.robotIP = robotIP
        self.port = 29999
        self.timeout = 5
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        logging.getLogger().setLevel(logging.INFO)

    def connect(self):
        self.sock.settimeout(self.timeout)
        self.sock.connect((self.robotIP, self.port))
        # Receive initial "Connected" Header
        self.sock.recv(1096)

    def sendAndReceive(self, command):
        try:
            self.sock.sendall((command + '\n').encode())
            return self.get_reply()
        except (ConnectionResetError, ConnectionAbortedError):
            logging.warning('The connection was lost to the robot. Please connect and try running again.')
            self.close()
            sys.exit()

    def get_reply(self):
        """
        read one line from the socket
        :return: text until new line
        """
        collected = b''
        while True:
            part = self.sock.recv(1)
            if part != b"\n":
                collected += part
            elif part == b"\n":
                break
        return collected.decode("utf-8")

    def close(self):
        self.sock.close()


if __name__ == "__main__":
    dash = Dashboard(host)
    dash.connect()
    # Check to see if robot is in remote mode.
    remoteCheck = dash.sendAndReceive('is in remote control')
    if 'false' in remoteCheck:
        logging.warning('Robot is in local mode. Some commands may not function.')

    while True:
        cmd = input('Enter command: ')
        if cmd.lower() == 'exit' or cmd.lower() == 'e':
            logging.info('Closing Dashboard connection and exiting...')
            break
        else:
            print(dash.sendAndReceive(cmd)+'\n')

    dash.close()
