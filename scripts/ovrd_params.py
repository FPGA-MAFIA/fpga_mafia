#!/usr/bin/env python

"""
This script allows you to override parameters in files recursively within a specified DUT directory.
You can provide a CSV file with parameter overrides, and the script will search for parameters in the files and replace
them with the new values. 
Usage: ./scripts/ovrd_params.py -dut big_core -ovrd_file override_rrv_rv32e 
"""

import argparse
import os
import re
import sys
import subprocess

# Get the root directory of the model
MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
os.chdir(MODEL_ROOT)

def parse_arguments():
    parser = argparse.ArgumentParser(description='Override parameters in files.')
    parser.add_argument('-dut', required=True, help='DUT name')
    parser.add_argument('-ovrd_file', required=True, help='File with parameter overrides without .csv extension')
    parser.add_argument('-v', '--verbose', action='store_true', help='Increase output verbosity')
    return parser.parse_args()

def search_and_replace_parameters(path, params):
    changed_files = []
    replacements_log = []  # Log details of replacements
    not_found_parameters = params.copy()  # Copy to track not found parameters

    for root, dirs, files in os.walk(path):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                with open(file_path, 'r') as file_handle:
                    content = file_handle.readlines()
            except FileNotFoundError:
                print(f"{file_path} file not found", file=sys.stderr)
                continue

            file_changed = False

            for line_num, line in enumerate(content):
                for param, new_value in params.items():
                    # Pattern to match parameter declarations only
                    pattern = re.compile(r"^\s*parameter\s+" + re.escape(param) + r"\s*=\s*([^;]+)(;.*|$)")
                    match = pattern.search(line)
                    if match:
                        old_value = match.group(1).strip()  # The current value of the parameter
                        # Replace the entire line, using standard formatting
                        new_line = f"parameter {param} = {new_value}; // NOTE!!!: auto inserted from script ovrd_params.py\n"
                        content[line_num] = new_line
                        file_changed = True
                        # Log the replacement details
                        replacements_log.append((param, old_value, new_value, line_num + 1, file_path))
                        # Correctly update the not_found_parameters
                        if param in not_found_parameters:
                            del not_found_parameters[param]

            if file_changed:
                changed_files.append((file_path, ''.join(content)))

    return changed_files, replacements_log, not_found_parameters


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

    # Define the paths
    source_path = os.path.join("source", dut_name.replace('/', os.sep))
    verif_path = os.path.join("verif", dut_name.replace('/', os.sep))

    # Process both paths
    total_changed_files = []
    total_replacements_log = []
    total_not_found_parameters = params.copy()

    for path in [source_path, verif_path]:
        if not os.path.isdir(path):
            print(f"Error: Directory '{path}' does not exist.", file=sys.stderr)
            continue

        changed_files, replacements_log, not_found_parameters = search_and_replace_parameters(path, params)

        total_changed_files.extend(changed_files)
        total_replacements_log.extend(replacements_log)

        # Remove found parameters from total_not_found_parameters
        for param in params:
            if param not in not_found_parameters:
                total_not_found_parameters.pop(param, None)


    # Print the log of replacements in the specified format
    
    if args.verbose:
        if total_replacements_log:
            print("\n     Parameter           |   Old value   |   New Value   |  Line  |   File path")
            print("-" * 100)
            for log in total_replacements_log:
                param, old_value, new_value, line_num, file_path = log
                print(f"{param:<24} | {old_value:<13} | {new_value:<13} | {line_num:<6} | {file_path}")
            print("-" * 100)

        if total_not_found_parameters:
            print("\nParameters not found (source OR verif):")
            for param in total_not_found_parameters:
                print(f"- {param}")            
            print("\n")
    
    # Save the changes to files
    for file_path, new_content in total_changed_files:
        with open(file_path, 'w') as file:
            file.write(new_content)

if __name__ == "__main__":
    main()
