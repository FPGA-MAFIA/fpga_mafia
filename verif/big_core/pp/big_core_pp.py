#! /usr/bin/env python
import os
import subprocess
import argparse
import sys
from termcolor import colored

parser = argparse.ArgumentParser(description='Get test name from build')
parser.add_argument('test_name', help='The name of the test to run post-processing on')
parser.add_argument('-v', '--verbose', action='store_true', help='Increase output verbosity')
args = parser.parse_args()



# Define the function to print messages with color
def print_message(msg):
    if not msg:  # Check if the message is None or empty
        print(colored('[PP_ERROR] No message to print', 'red', attrs=['bold']))
        return
    msg_type = msg.split()[0] if msg.split() else '[PP_NOTICE]'
    color = {
        '[PP_ERROR]': 'red',
        '[PP_WARNING]': 'yellow',
        '[PP_INFO]': 'green',
        '[PP_COMMAND]': 'cyan',
        '[PP_NOTICE]': 'magenta',  # For messages that don't fit other categories
    }.get(msg_type, 'blue')
    print(colored(msg, color, attrs=['bold']))

# Make sure we are in the MODEL_ROOT directory
MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
def chdir(dir):
    if args.verbose:  # Check if the verbose flag is set
        print_message(f'[PP_COMMAND] cd '+dir)
    os.chdir(dir)
chdir(MODEL_ROOT)
def run_cmd_with_capture(cmd):
    if args.verbose:
        print_message(f'[PP_COMMAND] {cmd}')
    try:
        # Execute the actual command passed to this function
        results = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True, check=True)
        return results
    except subprocess.CalledProcessError as e:
        print_message(f'[PP_ERROR] Command failed with error: {e}')
        return None  # Return None to indicate failure

# Validate the script path
scripts_path = './scripts/'
vga_script = os.path.join(scripts_path, 'vga_parser.py').replace('\\', '/')
if not os.path.exists(vga_script):
    print_message('[PP_ERROR] Post-processing script not found')
    sys.exit(1)

# Execute the VGA parser script
verbose_flag = ' '
if args.verbose:
    verbose_flag = '-v'
vga_script_command = f'python {vga_script} {args.test_name} big_core {verbose_flag}'
results = run_cmd_with_capture(vga_script_command)
# remove the \n from the end of the stdout (if it exists)
if results.stdout and results.stdout[-1] == '\n':
    results.stdout = results.stdout[:-1]

if results:
    if(results.stdout):
        print_message(results.stdout)
    print_message('[PP_INFO] Post-processing completed successfully')
else:
    print_message('[PP_ERROR] Post-processing failed')
    sys.exit(1)
sys.exit(0)
