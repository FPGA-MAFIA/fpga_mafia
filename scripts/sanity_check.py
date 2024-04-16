#!/usr/bin/env python
import os
import yaml
import argparse
import subprocess
import datetime
import time

# examples
# python ./scripts/sanity_check.py -yml mafia_level0
# python ./scripts/sanity_check.py -yml mafia_level0 -dut big_core

# Class for color-coding the output in the terminal
class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# Set up command-line argument parsing
parser = argparse.ArgumentParser(description="Execute commands from a YAML file.")
parser.add_argument("-yml", "--file", required=True, help="YAML file to process.")
parser.add_argument("-dut", "--dut", help="Optional: Specific DUT (Device Under Test) to run.")

args = parser.parse_args()

# Get the root directory of the git repository
MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().strip()
# Change the current working directory to the root of the git repository
os.chdir(MODEL_ROOT)

# Construct the path to the YAML file within the GitHub workflows directory
yaml_file_path = os.path.join('.github', 'workflows', f"{args.file}.yml")

# Attempt to open and read the specified YAML file
try:
    with open(yaml_file_path, 'r') as file:
        data = yaml.load(file, Loader=yaml.FullLoader)
except FileNotFoundError:
    print(Colors.FAIL + f"Error: File '{yaml_file_path}' not found." + Colors.ENDC)
    exit(1)

# Function to determine whether to execute a step based on the DUT argument
def should_execute_step(step_command):
    if not args.dut:
        return True
    return f" -dut '{args.dut}'" in step_command or f" -dut {args.dut} " in step_command

# Create a timestamp for logging
timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
log_file_dir = os.path.join(MODEL_ROOT, 'target')
log_file_name = f'sanity_{args.file}_{timestamp}.log'
log_file_path = os.path.join(log_file_dir, log_file_name)
# Compute the relative path to the log file for display
relative_log_file_path = os.path.relpath(log_file_path, MODEL_ROOT).replace('\\', '/')
# Ensure the log file directory exists
os.makedirs(os.path.dirname(log_file_path), exist_ok=True)

# Function to print the current status of tasks
def print_status(tasks, start_time):
    current_time = time.time()
    elapsed_time = current_time - start_time  # Calculate elapsed time since start

    os.system('cls' if os.name == 'nt' else 'clear')  # Clear the terminal screen
    print(Colors.HEADER + '=' * 80 + Colors.ENDC)
    print(f"See progress: {relative_log_file_path}")
    print(f"Current run time: {elapsed_time:.2f}s")
    print(Colors.HEADER + '=' * 80 + Colors.ENDC)
    print(Colors.HEADER + "STATUS:       - Command" + Colors.ENDC)
    print(Colors.HEADER + '=' * 80 + Colors.ENDC)
    for status, command in tasks:
        status_parts = status.split()
        status_text = status_parts[0]
        duration = f"({status_parts[1]})" if len(status_parts) > 1 else ""
        color = {
            "WAIT": Colors.OKBLUE,
            "RUNNING": Colors.WARNING,
            "PASS": Colors.OKGREEN,
            "FAIL": Colors.FAIL
        }.get(status_text, Colors.ENDC)
        print(f"{color}[{status_text}]{Colors.ENDC} {duration} - {command}")
    print(Colors.HEADER + '=' * 80 + Colors.ENDC)

any_task_failed = False
tasks = []

# Record the start time of the script
script_start_time = time.time()

# Parsing the YAML file and preparing tasks based on the 'build' job steps
if isinstance(data, dict) and 'jobs' in data and 'build' in data['jobs'] and 'steps' in data['jobs']['build']:
    steps = data['jobs']['build']['steps']
    for step in steps:
        if 'run' in step and should_execute_step(step['run']):
            tasks.append(["WAIT", step['run']])

    print_status(tasks, script_start_time)

    for i, task in enumerate(tasks):
        task_start_time = time.time()  # Record the start time for this task
        command = task[1]
        tasks[i][0] = "RUNNING"
        print_status(tasks, script_start_time)

        # Execute the command and capture its output
        result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        task_end_time = time.time()
        task_duration = task_end_time - task_start_time  # Calculate the duration of this task

        # Write the command and its output to the log file
        with open(log_file_path, 'a') as log_file:
            log_file.write(f"Executing command: {command}\n")
            log_file.write(result.stdout.decode())

        # Update the task status based on the command's success or failure
        if result.returncode == 0:
            tasks[i][0] = f"PASS ({task_duration:.2f}s)"
        else:
            tasks[i][0] = f"FAIL ({task_duration:.2f}s)"
            any_task_failed = True

        print_status(tasks, script_start_time)

# Calculate and print the total execution time at the end
script_end_time = time.time()
total_script_duration = script_end_time - script_start_time

if any_task_failed:
    print(Colors.BOLD + Colors.FAIL + f"Total execution time: {total_script_duration:.2f}s" + Colors.ENDC)
else:
    print(Colors.BOLD + Colors.OKGREEN + f"Total execution time: {total_script_duration:.2f}s" + Colors.ENDC)
