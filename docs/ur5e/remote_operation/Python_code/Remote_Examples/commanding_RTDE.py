import rtdeState
import csv
import time

name = 'path500.csv'
ROBOT_HOST = '192.168.0.2'
ROBOT_PORT = 30004
config_filename = 'rtdeCommand.xml'


def list_to_set_q(set_q, list):
    for i in range(0, len(list)):
        set_q.__dict__["input_double_register_%i" % i] = list[i]
    return set_q


with open(name, 'rt') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    q1 = []
    q2 = []
    q3 = []
    q4 = []
    q5 = []
    q6 = []
    for row in reader:
        q1.append(float(row[0]))
        q2.append(float(row[1]))
        q3.append(float(row[2]))
        q4.append(float(row[3]))
        q5.append(float(row[4]))
        q6.append(float(row[5]))

rtde = rtdeState.RtdeState(ROBOT_HOST, config_filename)
rtde.initialize()
rtde.set_q.input_double_register_0 = q1[0]
rtde.set_q.input_double_register_1 = q2[0]
rtde.set_q.input_double_register_2 = q3[0]
rtde.set_q.input_double_register_3 = q4[0]
rtde.set_q.input_double_register_4 = q5[0]
rtde.set_q.input_double_register_5 = q6[0]
rtde.servo.input_int_register_0 = 0

# Wait for program to be started and ready.
state = rtde.receive()
while state.output_int_register_0 != 1:
    state = rtde.receive()

# Send command to robot to begin servoing.
rtde.servo.input_int_register_0 = 1
rtde.con.send(rtde.servo)
time.sleep(0.01)

# Main control loop. Receive an output packet from the robot and then send the next joint positions.
for i in range(len(q1)):
    rtde.receive()
    list_to_set_q(rtde.set_q, [q1[i], q2[i], q3[i], q4[i], q5[i], q6[i]])
    rtde.con.send(rtde.set_q)

# Stop servoing.
rtde.servo.input_int_register_0 = 0
rtde.con.send(rtde.servo)
time.sleep(0.01)
rtde.con.send_pause()
rtde.con.disconnect()
