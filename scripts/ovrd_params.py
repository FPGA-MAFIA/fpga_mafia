#!/usr/bin/env python
import csv
import os
import re
import argparse

def read_csv_parameters(csv_file):
    # Initialize an empty dictionary to store parameters from the CSV file.
    params = {}
    with open(csv_file, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            if len(row) == 2:
                # Strip whitespace and store parameter name and value in the dictionary.
                params[row[0].strip()] = row[1].strip()
    print(f"Read {len(params)} parameters from CSV file.")  # Debug print
    return params

def update_rtl_files(params, rtl_directory):
    # Walk through all files in the RTL directory.
    for root, dirs, files in os.walk(rtl_directory):
        for file in files:
            file_path = os.path.join(root, file)
            with open(file_path, 'r') as file:
                content = file.read()

            updated = False
            for param, value in params.items():
                # Create a regular expression to find the parameter in the file.
                regex = r"parameter\s+" + re.escape(param) + r"\s*=\s*\d+;"
                if re.search(regex, content):
                    # If found, create a new line with the overridden parameter value.
                    new_line = f"parameter {param} = {value}; //Script override"
                    content = re.sub(regex, new_line, content)
                    updated = True

            # If any parameter was updated, write the updated content back to the file.
            if updated:
                with open(file_path, 'w') as file:
                    file.write(content)
                print(f"Updated parameters in {file_path}")  # Debug print

def parse_arguments():
    # Create a parser for command line arguments.
    parser = argparse.ArgumentParser(description='Override RTL parameters from a CSV file.')
    parser.add_argument('-dut', required=True, help='Design Under Test (DUT) directory name')
    parser.add_argument('-ovrd_file', required=True, help='Path to the override CSV file')
    return parser.parse_args()

def main():
    # Parse command line arguments.
    args = parse_arguments()
    csv_file = args.ovrd_file
    rtl_directory = f'source/{args.dut}/'
    print(f"Overriding parameters in RTL files at {rtl_directory} using {csv_file}")  # Debug print

    # Read parameters from CSV and update RTL files.
    params = read_csv_parameters(csv_file)
    update_rtl_files(params, rtl_directory)

    print("RTL files update complete.")  # Confirmation message

if __name__ == "__main__":
    main()
