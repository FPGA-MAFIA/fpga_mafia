#!/usr/bin/env python
import os
import yaml             # run "pip install pyyaml" if required
import argparse
import subprocess

# Examples:
# ./sanity_check.py -yml mafia_sanity
# ./sanity_check.py -yml mafia_sanity -dut core_rrv
parser = argparse.ArgumentParser(description="Execute commands from a YAML file.")
parser.add_argument("-yml", "--file", required=True, help="YAML file to process. Example: ./scripts/sanity_check.py -yml mafia_sanity")
parser.add_argument("-dut", "--dut", help="Optional: Specific DUT (Device Under Test) to run. Example: core_rrv")

# Parse the command-line arguments
args = parser.parse_args()

# Return to root dir no matter where the file is located
MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
os.chdir(MODEL_ROOT)

# Read the specified YAML file
yaml_file_path = './.github/workflows/' + args.file + ".yml"

try:
    with open(yaml_file_path, 'r') as file:
        data = yaml.load(file, Loader=yaml.FullLoader)
except FileNotFoundError:
    print("\033[91m" + f"Error: File '{yaml_file_path}' not found." + "\033[0m") 
    exit(1)

# Function to determine if a step should be executed based on the -dut argument
def should_execute_step(step_command):
    # If -dut argument is not specified, execute all steps
    if not args.dut:
        return True
    # Execute step only if it contains the specific DUT
    return f" -dut '{args.dut}'" in step_command or f" -dut {args.dut} " in step_command


import datetime
import os
import subprocess

# Generate the timestamp and log file path
timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
log_file_path = os.path.join(MODEL_ROOT, 'target', f'sanity_{args.file}_{timestamp}.log')
os.makedirs(os.path.dirname(log_file_path), exist_ok=True)

# Track if any task has failed
any_task_failed = False

if isinstance(data, dict) and 'jobs' in data and 'build' in data['jobs'] and 'steps' in data['jobs']['build']:
    steps = data['jobs']['build']['steps']
    with open(log_file_path, 'w') as log_file:
        for step in steps:
            if 'run' in step:
                command = step['run']
                if should_execute_step(command):

                    # Print task start message with the command
                    print(f"Task Started: {command}")

                    # Execute the command and redirect output to log file
                    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                    log_file.write(f"Executing command: {command}\n")
                    log_file.write(result.stdout.decode())

                    # Check the result and update the task failure tracker
                    if result.returncode == 0:
                        print("Task Finished Successfully")
                    else:
                        print("Task Finished with Error")
                        any_task_failed = True

# After all tasks have been executed, print the summary message
print("\n^^^^^^^^^^^^^^^^^^^^^^^^^")
if any_task_failed:
    print("Some tasks finished with errors.")
else:
    print("All tasks finished successfully.")
print(f"See log file here: {log_file_path}")
