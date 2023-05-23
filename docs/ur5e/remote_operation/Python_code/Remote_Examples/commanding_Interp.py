from rtdeState import RtdeState
from Dashboard import Dashboard
import sendInterpreterFromFile as sendFile
from interpreter.interpreter import InterpreterHelper
import logging
import sys
import time
import datetime as dt

ROBOT_HOST = '192.168.0.2'
rtde_config = 'rtdeState.xml'
robotCommands = 'pnp.txt'
# Enter robot path to Interpret.urp file
pathToRobotProgram = '/programs/RemoteOperation/interpret.urp'


def robot_boot():
    # Check to make sure robot is in remote control.
    remoteCheck = dash.sendAndReceive('is in remote control')
    if 'false' in remoteCheck:
        logging.error('Robot is in local mode. Cannot issue system commands. Exiting...')
        shutdown()
        sys.exit()
    # Check robot mode and boot if necessary.
    powermode = dash.sendAndReceive('robotmode')
    if 'POWER_OFF' in powermode:
        logging.info('Attempting to power robot and release brakes.')
        logging.info(dash.sendAndReceive('brake release'))
        temp_state = rState.receive()
        bootStatus = temp_state.robot_mode
        # Grab robot mode from RTDE and loop until robot fully boots. Monitor safety state
        # and exit if safety state enters a non-normal mode.
        while bootStatus != 7:
            temp_state = rState.receive()
            bootStatus = temp_state.robot_mode
            safetyStatus = temp_state.safety_status
            if safetyStatus != 1:
                logging.error('Robot could not boot successfully. Exiting...')
                shutdown()
                sys.exit()
        logging.info('Robot booted succesfully. Ready to run.')


def startRobotProgram():
    # Check to see if currently loaded program is Interpret.urp
    currentProgram = dash.sendAndReceive('get loaded program')
    # Users should add error handling in case program load fails.
    if not currentProgram.endswith('interpret.urp'):
        dash.sendAndReceive(f'load {pathToRobotProgram}')
        logging.info('Found and loaded Interpret.urp')
    else:
        logging.info('Interpret.urp already loaded.')
    dash.sendAndReceive('play')
    # Check program status via RTDE and wait until it returns a "Playing" state.
    temp_state = rState.receive()
    startStatus = temp_state.runtime_state
    while startStatus != 2:
        temp_state = rState.receive()
        startStatus = temp_state.runtime_state
    logging.info('Playing program')


def pStopRecover():
    response = input('Is the robot safe to continue running? (y/n): ')
    if response == str.lower('y') or str.lower('yes'):
        # Log operator confirming safety.
        now = dt.datetime.now()
        logging.warning(f'[{now:%Y-%m-%d %H:%M}]Operator confirmed cell safety.')
        logging.warning('Robot restarting in 5 seconds.')
        # Dashboard requires 5 second wait before unlocking a pstop.
        time.sleep(5)
        logging.warning('Restarting...')
        dash.sendAndReceive('unlock protective stop')
        temp_state = rState.receive()
        safetyStatus = temp_state.safety_status
        runStatus = temp_state.runtime_state
        # Wait until robot fully restarts from protective stop.
        while safetyStatus != 1 or runStatus != 4:
            temp_state = rState.receive()
            safetyStatus = temp_state.safety_status
            runStatus = temp_state.runtime_state
        time.sleep(1)
        dash.sendAndReceive('play')
    else:
        logging.warning('Unable to verify cell safety. Please manually clear issue. Exiting...')
        shutdown()


def shutdown():
    dash.close()
    rState.con.send_pause()
    rState.con.disconnect()


if __name__ == "__main__":
    # Set up Dashboard monitor.
    dash = Dashboard(ROBOT_HOST)
    dash.connect()
    # Set up RTDE monitor.
    rState = RtdeState(ROBOT_HOST, rtde_config, frequency=500)
    rState.initialize()
    robot_boot()
    startRobotProgram()
    # Set up Interpreter.
    interpreter = InterpreterHelper(ROBOT_HOST)
    interpreter.connect()
    # Attempt to call an interpreter function. Exit if robot program is stopped.
    try:
        sendFile.send_cmd_interpreter_mode_file(interpreter, robotCommands)
    except Exception as e:
        # Look for "invalid state" in the interpreter error message. Raise exception otherwise.
        if 'invalid state' in e.args[1]:
            logging.warning('Robot program state invalid. Exiting...')
            shutdown()
        else:
            raise

    runtime_old = 0
    while rState.keep_running:
        state = rState.receive()

        if state is None:
            logging.error('No RTDE data received. Exiting...')
            break

        if state.runtime_state != runtime_old:
            logging.info(f'Robot program is {rState.programState[state.runtime_state]}')
            runtime_old = state.runtime_state
            if state.runtime_state == 1 or state.runtime_state == 0:
                logging.info('Robot program was stopped. Exiting...')
                break

        if state.safety_status == 3:
            logging.error('Robot went into Protective Stop.')
            pStopRecover()

        # Safely exit interpreter mode once commands have been executed. Handle edge case where the robot
        # is already stopped by the time this part of the main loop executes.
        try:
            linesleft = interpreter.get_unexecuted_count()
            if linesleft == 0:
                logging.info('All commands completed. Exiting...')
                interpreter.end_interpreter()
                break
        except Exception as e:
            if 'invalid state' in e.args[1]:
                logging.warning('Robot program state invalid. Exiting...')
                break
            else:
                raise

    shutdown()
