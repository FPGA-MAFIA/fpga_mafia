import os
from termcolor import colored, cprint
import subprocess
import argparse
import difflib

parser = argparse.ArgumentParser(description= 'get test name from build')
parser.add_argument('test_name', help='The name of the test to run pp on')
args = parser.parse_args()

def print_message(msg):
    msg_type = msg.split()[0]
    try:
        color = {
            '[ERROR]'   : 'red',
            '[WARNING]' : 'yellow',
            '[INFO]'    : 'green',
            '[COMMAND]' : 'cyan',
        }[msg_type]
    except:
        color = 'blue'
    print(colored(msg,color,attrs=['bold']))        

MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
os.chdir(MODEL_ROOT)

print_message('--------------------------------------------------------')
print_message("     Cache Post-Process  : "+args.test_name )
print_message('--------------------------------------------------------')
# Path to the directory containing the tests
base_path = "target/cache/tests"

# Initialize variable to keep track of total diffs
total_diffs = 0

fails = 0
num_tests = 0


num_tests +=1
# Construct the paths to the two files to compare
file1_path = os.path.join(base_path, args.test_name, "cache_top_trk.log").replace("\\", "/")
file2_path = os.path.join("verif", "cache", "golden_trk", "golden_" + args.test_name + "_top_trk.log").replace("\\", "/")

if os.path.exists(file2_path):
    # Open the two files
    with open(file1_path, "r") as file1, open(file2_path, "r") as file2:
        # Read the contents of the two files
        file1_contents = file1.readlines()
        file2_contents = file2.readlines()
        # Initialize variables to keep track of diffs
        num_diffs = 0
        diff_lines = []
    # Construct the path to the output file
    output_path = os.path.join(base_path, args.test_name, "test_golden_checker.log")
    output_path = os.path.normpath(output_path)
    output_path = output_path.replace("\\","/")
    
    # Read the contents of both files
    with open(file1_path, 'r') as file1, open(file2_path, 'r') as file2:
        file1_contents = file1.readlines()
        file2_contents = file2.readlines()
        print(f"Current test file: ",colored(file1_path,'yellow', attrs=['bold']))
        print(f"Golden file:       ",colored(file2_path,'yellow', attrs=['bold']))

    # Find the differences between the files
    differ  = difflib.Differ()
    diff    = list(differ.compare(file1_contents, file2_contents))
    # print the diff to the output file
    diff_file = open(output_path, 'w')
    diff_file.write("review the diff between the current test and the golden tracker\n\n")
    diff_file.write("The + : line is present in test but not in the golden \n")
    diff_file.write("The - : line is present in golden but not in the test\n")
    for line in diff:
        diff_file.write(line)

    # Count the number of differences
    num_diffs = len([line for line in diff if line.startswith('+') or line.startswith('-')])

    # Print the differences
    for line in diff:
        if line.startswith('+'):
            print(f"{colored(line, 'green')}")
        elif line.startswith('-'):
            print(f"{colored(line, 'red')}")


    # Print the path to the output file
    if num_diffs > 0:
        #print(f"There are {num_diffs} differences between the two files:")
        #print(f"Please refer to" ,colored(output_path,'white',attrs=['bold']), "to see the full diff\n")
        print_message(f"[ERROR] There are {num_diffs} differences between the two files:")
        print_message(f"[INFO] Please refer to {output_path} to see the full diff\n")
else: 
    print_message(f"\n[INFO] No golden tracker found for test {args.test_name}")

print_message('--------------------------------------------------------') 
if total_diffs == 0:
    print(colored("\n[INFO] Post-Process finish succesfuly ",'green',attrs=['bold']))
else:
    print_message(f"\n[WARNING] {args.test_name} have failed Post-Process")
   

#print_message('******************************************************************************')           

