#!/usr/bin/python3

import logging
import argparse
import sys
import time
from interpreter.interpreter import InterpreterHelper

# num of commands after which clear_interpreter() command will be invoked.
# If interpreted statements are not cleared periodically then "runtime too much behind" error may
# be shown when leaving interpreter mode
CLEARBUFFER_LIMIT = 500


def parseArgs():
    parser = argparse.ArgumentParser(description = 'Send commands from file')
    parser.add_argument('ip', help='Specify the IP of the robot (required)')
    parser.add_argument('file', help='Specify the file to read the commands from (required)')
    parser.add_argument('-v', '--verbose', help='increase output verbosity', action='store_true')
    parser.add_argument('-d', '--debug', help='print debug level messages', action='store_true')
    args = parser.parse_args()

    if args.file is None:
        sys.exit('Command file has to be specified')

    if args.ip is None:
        sys.exit('Robot ip has to be specified')

    if args.debug:
        logging.basicConfig(level=logging.DEBUG)
    elif args.verbose:
        logging.basicConfig(level=logging.INFO)

    return args


def send_cmd_interpreter_mode_file(intrp, commandFile):
    f = open(commandFile, "r")
    command_count = 1
    lines = f.readlines()
    logging.info(f"{len(lines)} commands read from file")
    for line in lines:
        command_id = intrp.execute_command(line)
        if command_count % CLEARBUFFER_LIMIT == 0:
            logging.info(f"{command_count} commands sent. Waiting for all commands to be executed before clear.")
            # Wait for interpreted commands to be executed. New commands will be discarded if interpreter buffer
            # limit is exceeded.
            while intrp.get_last_executed_id() != command_id:
                logging.info(f"Last executed id {intrp.get_last_executed_id()}/{command_id}")
                time.sleep(2)

            # Manual buffer clear is necessary when large amount of statements is sent in one interpreter mode session.
            # By default statements are cleared when leaving interpreter mode.
            # Look at CLEARBUFFER_LIMIT comment for more info.
            logging.info("Clearing all interpreted statements")
            intrp.clear()
        command_count += 1


if __name__ == "__main__":
    args = parseArgs()
    interpreter = InterpreterHelper(args.ip)
    interpreter.connect()
    send_cmd_interpreter_mode_file(interpreter, args.file)
    interpreter.end_interpreter()   
