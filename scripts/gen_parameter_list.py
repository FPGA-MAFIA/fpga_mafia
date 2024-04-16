#! /usr/bin/env python
"""
This script generates a list of parameters of the DUT (Device Under Test) that is being tested.
It reads the DUT name as an argument, searches for parameters in the source files, and outputs 
a list of these parameters along with their values in a specified format.
For example: ./gen_parameter_list.py big_core
"""

import os
import sys
import re
import argparse
import subprocess

MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
os.chdir(MODEL_ROOT)
def parse_parameters(content):
    """
    Parses the parameters from the given content.
    Args: content (str): The content to parse the parameters from.
    Returns: str: Parsed parameters in 'name, value' format.
    """
    parsed_output = ""
    for line in content.splitlines():
        # Updated regex to handle more complex parameter definitions
        match = re.search(r'parameter\s+(\w+)\s*=\s*(.*?);', line)
        if match:
            parameter_name, parameter_value = match.groups()
            parsed_output += f"{parameter_name}, {parameter_value}\n"
    return parsed_output



def search_parameters(dut_path):
    """  Searches for parameters in the files located at the given path.
    Args: dut_path (str): The path where the DUT files are located.
    Returns:   str: The content of the files with parameters.
    """
    content = ""
    for root, dirs, files in os.walk(dut_path):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                with open(file_path, 'r') as file_handle:
                    file_content = file_handle.read()
                    if "parameter" in file_content:
                        content += file_content
            except UnicodeDecodeError as e:
                # Log the file path and the error
                print(f"Error reading file {file_path}: {e}")
                continue

    # make sure each parameter appears only once
    content = "\n".join(list(set(content.splitlines())))
    return content


def main():
    parser = argparse.ArgumentParser(description='Generate a list of parameters for the DUT')
    parser.add_argument('dut_name', help='name of the DUT')
    args = parser.parse_args()

    dut_name = args.dut_name
    #print(f"DUT name: {dut_name}")

    dut_path = os.path.join("verif", dut_name)
    if not os.path.isdir(dut_path):
        print(f"Error: Directory '{dut_path}' does not exist.")
        sys.exit(1)

    # check if target/dut_parameters directory exists and create it if not
    target_path = os.path.join("target", "dut_parameters")
    if not os.path.isdir(target_path):
        os.makedirs(target_path)

    # remove any existing parameter list file
    parameter_list_file = os.path.join(target_path, f"{dut_name}_parameter_list.csv")
    if os.path.isfile(parameter_list_file):
        os.remove(parameter_list_file)

    try:
        content = search_parameters(dut_path)
    except Exception as e:
        print(f"Error reading files: {e}")
        sys.exit(1)

    parsed_output = parse_parameters(content)
    if not parsed_output:
        print("No parameters found.")
        sys.exit(0)

    with open(parameter_list_file, "w") as file:
        file.write(parsed_output)

    #print("Parsed output:")
    #print(parsed_output)

if __name__ == "__main__":
    main()
