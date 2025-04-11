
import os

script_dir = os.path.dirname(os.path.abspath(__file__))
mc_file = f"{script_dir}/../../../target/mini_core/tests/stress/trk_memory_access.log"
mcd_file = f"{script_dir}/../../../target/mini_core_di/tests/stress/trk_memory_access.log"
# Open both files
with open(mc_file, 'r') as file1, open(mcd_file, 'r') as file2:
    # Read lines from both
    lines1 = file1.readlines()
    lines2 = file2.readlines()

# Get the maximum number of lines
max_lines = max(len(lines1), len(lines2))

error_flag = 0
# Compare line by line
for i in range(max_lines)[3:]:
    line1 = lines1[i].strip().split("|")[1:] if i < len(lines1) else "<No line>"
    line2 = lines2[i].strip().split("|")[1:] if i < len(lines2) else "<No line>"
    # print(line1, line2)
    if line1 != line2:
        print(f"Difference at line {i+1}:\n  File1: {line1}\n  File2: {line2}")
        continue
        error_flag += 1
          
print(f"Program finished with {error_flag} errors")
exit(error_flag)
