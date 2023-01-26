import os
from termcolor import colored

# Path to the directory containing the "dir_name" subdirectories
base_path = "target/cache/tests"

# Initialize variable to keep track of total diffs
total_diffs = 0

# Iterate over all subdirectories in the base path
for dir_name in os.listdir(base_path):
    # Construct the paths to the two files to compare
    file1_path = os.path.join(base_path, dir_name, "cache_top_trk.log")
    file2_path = os.path.join("verif/cache/golden_trk", "golden_" + dir_name + "_top_trk.log")

    # Open the two files
    with open(file1_path, "r") as file1, open(file2_path, "r") as file2:
        # Read the contents of the two files
        file1_contents = file1.readlines()
        file2_contents = file2.readlines()

        # Initialize variables to keep track of diffs
        num_diffs = 0
        diff_lines = []

        # Iterate over the lines in the two files
        for line1, line2 in zip(file1_contents, file2_contents):
            # Compare the lines
            if line1 != line2:
                # Increment the diff count
                num_diffs += 1
                total_diffs += 1
                # Append the line number and the diff to the list
                diff_lines.append((num_diffs, line1, line2))

    # Print the number of diffs to the screen
    print("Number of diffs for {}: {}".format(dir_name, num_diffs))

    # Construct the path to the output file
    output_path = os.path.join(base_path, dir_name, "test_golden_checker.log")
    output_path = os.path.normpath(output_path)

    # Open the output file
    with open(output_path, "w") as output_file:
        # Write the number of diffs
        output_file.write("Number of diffs: {}\n".format(num_diffs))

        # Write the line


        # Write the line numbers, the lines in file1 and the lines in file2
        for diff_line in diff_lines:
            output_file.write("Line {}:\n{}\n{}\n".format(diff_line[0], diff_line[1], diff_line[2]))

    if num_diffs > 0:
        # Print the path to the output file
        print("Path to test_golden_checker.log: {}".format(output_path))

