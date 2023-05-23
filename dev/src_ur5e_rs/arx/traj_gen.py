import matplotlib.pyplot as plt
import numpy as np


def mjtg(current, setpoint, frequency, move_time):
    trajectory = []
    trajectory_derivative = []
    timefreq = int(move_time * frequency)

    for time in range(1, timefreq):
        trajectory.append(
            current + (setpoint - current) *
            (10.0 * (time/timefreq)**3
             - 15.0 * (time/timefreq)**4
             + 6.0 * (time/timefreq)**5))

        trajectory_derivative.append(
            frequency * (1.0/timefreq) * (setpoint - current) *
            (30.0 * (time/timefreq)**2.0
             - 60.0 * (time/timefreq)**3.0
             + 30.0 * (time/timefreq)**4.0))

    return trajectory, trajectory_derivative

# Set up and calculate trajectory.
average_velocity = 20.0
current = 0.0
setpoint = 180.0
frequency = 1000
time = (setpoint - current) / average_velocity

traj, traj_vel = mjtg(current, setpoint, frequency, time)

# Create plot.
xaxis = [i / frequency for i in range(1, int(time * frequency))]

plt.plot(xaxis, traj)
plt.plot(xaxis, traj_vel)
plt.title("Minimum jerk trajectory")
plt.xlabel("Time [s]")
plt.ylabel("Angle [deg] and angular velocity [deg/s]")
plt.legend(['pos', 'vel'])
plt.show()


average_velocity = 26.7
current = 0.0
setpoint = 180.0
frequency = 1000
time = (setpoint - current) / average_velocity

traj, traj_vel = mjtg(current, setpoint, frequency, time)
