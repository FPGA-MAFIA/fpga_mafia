#!/usr/bin/env python
import os
import yaml
import argparse
import subprocess
import datetime
import time

# For colored output
class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

parser = argparse.ArgumentParser(description="Execute commands from a YAML file.")
parser.add_argument("-yml", "--file", required=True, help="YAML file to process.")
parser.add_argument("-dut", "--dut", help="Optional: Specific DUT (Device Under Test) to run.")

args = parser.parse_args()

MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().strip()
os.chdir(MODEL_ROOT)

yaml_file_path = os.path.join('.github', 'workflows', f"{args.file}.yml")

try:
    with open(yaml_file_path, 'r') as file:
        data = yaml.load(file, Loader=yaml.FullLoader)
except FileNotFoundError:
    print(Colors.FAIL + f"Error: File '{yaml_file_path}' not found." + Colors.ENDC)
    exit(1)

def should_execute_step(step_command):
    if not args.dut:
        return True
    return f" -dut '{args.dut}'" in step_command or f" -dut {args.dut} " in step_command

timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
log_file_dir = os.path.join(MODEL_ROOT, 'target')
log_file_name = f'sanity_{args.file}_{timestamp}.log'
log_file_path = os.path.join(log_file_dir, log_file_name)
relative_log_file_path = os.path.relpath(log_file_path, MODEL_ROOT).replace('\\', '/')
os.makedirs(os.path.dirname(log_file_path), exist_ok=True)

def print_status(tasks, start_time):
    current_time = time.time()  # Get the current time for calculating the elapsed time
    elapsed_time = current_time - start_time  # Calculate the elapsed time since the script started

    os.system('cls' if os.name == 'nt' else 'clear')  # Clear the screen
    print(f"See progress: {relative_log_file_path}")
    print(f"Current run time: {elapsed_time:.2f}s")  # Display the current run time
    print(Colors.HEADER + '=' * 80 + Colors.ENDC)
    print(Colors.HEADER + "STATUS:       - Command" + Colors.ENDC)
    print(Colors.HEADER + '=' * 80 + Colors.ENDC)
    for status, command in tasks:
        status_parts = status.split()
        status_text = status_parts[0]  # Get the "PASS" or "FAIL" part
        duration = f"({status_parts[1]})" if len(status_parts) > 1 else ""  # Get the duration part if exists
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

script_start_time = time.time()  # Record the overall start time for the script

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

        result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        task_end_time = time.time()  # Record the end time for this task
        task_duration = task_end_time - task_start_time  # Calculate the task duration

        with open(log_file_path, 'a') as log_file:
            log_file.write(f"Executing command: {command}\n")
            log_file.write(result.stdout.decode())

        if result.returncode == 0:
            tasks[i][0] = f"PASS ({task_duration:.2f}s)"
        else:
            tasks[i][0] = f"FAIL ({task_duration:.2f}s)"
            any_task_failed = True

        print_status(tasks, script_start_time)

script_end_time = time.time()  # Record the overall end time for the script
total_script_duration = script_end_time - script_start_time  # Calculate the total script duration

if any_task_failed:
    print(Colors.BOLD + Colors.FAIL + f"Total execution time: {total_script_duration:.2f}s" + Colors.ENDC)
else:
    print(Colors.BOLD + Colors.OKGREEN + f"Total execution time: {total_script_duration:.2f}s" + Colors.ENDC)
