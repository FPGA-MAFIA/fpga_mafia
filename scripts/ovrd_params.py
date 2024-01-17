#!/usr/bin/env python

"""
This script allows you to override parameters in files recursively within a specified DUT directory.
You can provide a CSV file with parameter overrides, and the script will search for parameters in the files and replace
them with the new values. 
Usage: ./scripts/ovrd_params.py -dut core_rrv -ovrd_file override_rrv_rv32e 
"""


import argparse
import os
import re
import sys
import subprocess

## ./scripts/ovrd_params.py -dut core_rrv -ovrd_file override_rrv_rv32e
MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
os.chdir(MODEL_ROOT)

def parse_arguments():
    parser = argparse.ArgumentParser(description='Override parameters in files.')
    parser.add_argument('-dut', required=True, help='DUT name')
    parser.add_argument('-ovrd_file', required=True, help='File with parameter overrides without .csv extension')
    return parser.parse_args()

def parse_parameters(content):
    parsed_output = {}
    for line in content.splitlines():
        match = re.search(r'parameter\s+(\w+)\s*=\s*(.*?);', line)
        if match:
            parameter_name, parameter_value = match.groups()
            parsed_output[parameter_name] = parameter_value
    return parsed_output

def search_and_replace_parameters(dut_path, params):
    changed_files = []
    found_parameters = {}  # Separate dictionary for tracking found parameters

    for root, dirs, files in os.walk(dut_path):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                with open(file_path, 'r') as file_handle:
                    content = file_handle.read()
            except FileNotFoundError:
                print(f"{file_path} file not found", file=sys.stderr)
                continue

            file_changed = False
            changed_params = []  # Separate list for tracking changed parameters
            for param, value in params.items():
                # Construct a regex pattern to match parameter lines like "parameter RF_NUM_MSB = 31;"
                pattern = r"(parameter\s+" + re.escape(param) + r"\s*=\s*)" + r"(\d+);"
                # Replace the old value with the new value
                new_content, num_replacements = re.subn(pattern, fr"parameter {param} = {value};", content)
                if num_replacements > 0:
                    content = new_content
                    file_changed = True
                    changed_params.append(param)  # Add changed parameter to the list
                    found_parameters[param] = value  # Add found parameter to the dictionary

            if file_changed:
                changed_files.append((file_path, content, changed_params))

    not_found_parameters = set(params.keys()) - set(found_parameters.keys())

    return changed_files, not_found_parameters

def main():
    args = parse_arguments()
    script_dir = os.path.dirname(os.path.abspath(__file__))
    params = {}
    dut_name = args.dut

    # Check if the CSV file exists and read parameter overrides
    csv_file_path = os.path.join(script_dir, 'ovrd_params', f"{args.ovrd_file}.csv")
    if not os.path.isfile(csv_file_path):
        print(f"{args.ovrd_file}.csv file not found in 'ovrd_params' folder", file=sys.stderr)
        exit(1)

    try:
        with open(csv_file_path, 'r') as file:
            for line in file:
                parts = line.strip().split(',')
                if len(parts) == 2:
                    param, value = parts[0].strip(), parts[1].strip()
                    params[param] = value
    except FileNotFoundError:
        print(f"{args.ovrd_file}.csv file not found in 'ovrd_params' folder", file=sys.stderr)
        exit(1)

    # Adjust the DUT path format to include the correct directory separator
    dut_path = os.path.join("verif", dut_name.replace('/', os.sep))
    if not os.path.isdir(dut_path):
        print(f"Error: Directory '{dut_path}' does not exist.", file=sys.stderr)
        exit(1)

    changed_files, not_found_parameters = search_and_replace_parameters(dut_path, params)

    # Print the list of changed files and changed parameters
    print("Changed Files:")
    for file_path, _, changed_params in changed_files:
        print(file_path)
        if changed_params:
            print("Changed Parameters:")
            for param in changed_params:
                print(f"- {param} (New Value: {params[param]})")

    # Print the list of parameters not found
    if not_found_parameters:
        print("\nParameters Not Found:")
        for param in not_found_parameters:
            print(param)

    # Save the changes to files
    for file_path, new_content, _ in changed_files:
        with open(file_path, 'w') as file:
            file.write(new_content)

if __name__ == "__main__":
    main()
