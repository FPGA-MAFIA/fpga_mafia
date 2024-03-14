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

# Run the YAML file
if isinstance(data, dict) and 'jobs' in data and 'build' in data['jobs'] and 'steps' in data['jobs']['build']:
    steps = data['jobs']['build']['steps']
    for step in steps:
        if 'run' in step:
            command = step['run']
            if command.startswith("python build.py") and should_execute_step(command):
                # Remove single quotes around the 'dut' argument
                command = command.replace(" -dut '", " -dut ").replace("' ", " ")
                print(f"Executing command: {command}")
                subprocess.run(command, shell=True)
