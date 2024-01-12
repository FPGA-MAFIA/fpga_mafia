#!/usr/bin/env python
import yaml             # run "pip install pyyaml" if required
import argparse
import subprocess

# Create a command-line argument parser
parser = argparse.ArgumentParser(description="Execute commands from a YAML file.")
parser.add_argument("-yml", "--file", required=True, help="YAML file to process")

# Examples:
# ./sanity_check.py -yml mafia_sanity

# Parse the command-line arguments
args = parser.parse_args()

# Read the specified YAML file
yaml_file_path = '../.github/workflows/' + args.file + ".yml"

try:
    with open(yaml_file_path, 'r') as file:
        data = yaml.load(file, Loader=yaml.FullLoader)
except FileNotFoundError:
    print("\033[91m" + f"Error: File '{yaml_file_path}' not found." + "\033[0m") 
    exit(1)

# Run the YAML file
if isinstance(data, dict) and 'jobs' in data and 'build' in data['jobs'] and 'steps' in data['jobs']['build']:
    steps = data['jobs']['build']['steps']
    for step in steps:
        if 'run' in step:
            command = step['run']
            if command.startswith("python build.py"):
                # Remove single quotes around the 'dut' argument
                command = command.replace(" -dut '", " -dut ").replace("' ", " ")
                print(f"Executing command: {command}")
                subprocess.run(command, shell=True)

