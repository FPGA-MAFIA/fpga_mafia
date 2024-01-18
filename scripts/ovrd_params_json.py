#!/usr/bin/env python

"""
This script allows you to override parameters in files recursively within a specified DUT directory.
You can provide a JSON file with parameter overrides, and the script will search for parameters in the files and replace
them with the new values. 
Usage: ./scripts/ovrd_params_json.py -dut core_rrv -cfg mini_rv32e 
"""

import argparse
import os
import re
import sys
import subprocess
import json

# Get the root directory of the model
MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
os.chdir(MODEL_ROOT)

def parse_arguments():
    parser = argparse.ArgumentParser(description='Override parameters in files.')
    parser.add_argument('-dut', required=True, help='DUT name')
    parser.add_argument('-cfg', required=True, help='File with parameter overrides without .json extension')
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
                    pattern = re.compile(r"^\s*parameter\s+" + re.escape(param) + r"\s*=\s*([^;]+)(;.*|$)")
                    match = pattern.search(line)
                    if match:
                        old_value = match.group(1).strip()
                        new_line = f"parameter {param} = {new_value}; // NOTE!!!: auto inserted from script build.py\n"
                        content[line_num] = new_line
                        file_changed = True
                        replacements_log.append((param, old_value, new_value, line_num + 1, file_path))
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

    # Read parameter overrides from JSON file
    json_file_path = os.path.abspath(os.path.join(script_dir, '..', 'app', 'cfg', f"{args.cfg}.json"))
    if not os.path.isfile(json_file_path):
        print(f"{args.cfg}.json file not found in '/app/cfg' directory", file=sys.stderr)
        exit(1)

    try:
        with open(json_file_path, 'r') as file:
            json_data = json.load(file)
            rtl_params = json_data.get('rtl_parameter_override', {})
            verif_params = json_data.get('verif_pkg_parameter_override', {})
    except FileNotFoundError:
        print(f"{args.cfg}.json file not found in '/app/cfg' directory", file=sys.stderr)
        exit(1)

    # Define the paths
    source_path = os.path.join("source", dut_name.replace('/', os.sep))
    verif_path = os.path.join("verif", dut_name.replace('/', os.sep))

    # Process source and verif paths
    total_changed_files = []
    total_replacements_log = []

    changed_files, replacements_log, not_found_rtl_params = search_and_replace_parameters(source_path, rtl_params)
    total_changed_files.extend(changed_files)
    total_replacements_log.extend(replacements_log)

    changed_files, replacements_log, not_found_verif_params = search_and_replace_parameters(verif_path, verif_params)
    total_changed_files.extend(changed_files)
    total_replacements_log.extend(replacements_log)

    # Print the log of replacements in the specified format
    if total_replacements_log:
        print("\n     Parameter           |   Old value   |   New Value   |  Line  |   File path")
        print("-" * 100)
        for log in total_replacements_log:
            param, old_value, new_value, line_num, file_path = log
            print(f"{param:<24} | {old_value:<13} | {new_value:<13} | {line_num:<6} | {file_path}")
        print("-" * 100)

    # Report parameters not found
    if not_found_rtl_params or not_found_verif_params:
        print("\nParameters not found:")
        for param in not_found_rtl_params:
            print(f"- {param}   (/source/{dut_name})")
        for param in not_found_verif_params:
            print(f"- {param}   (/verif/{dut_name})")
        print("\n")

    # Save the changes to files
    for file_path, new_content in total_changed_files:
        with open(file_path, 'w') as file:
            file.write(new_content)

if __name__ == "__main__":
    main()
