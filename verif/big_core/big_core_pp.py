import os
from termcolor import colored, cprint
import subprocess
import argparse
import difflib
import sys

parser = argparse.ArgumentParser(description= 'get test name from build')
parser.add_argument('test_name', help='The name of the test to run pp on')
args = parser.parse_args()

def print_message(msg):
    msg_type = msg.split()[0]
    try:
        color = {
            '[PP_ERROR]'   : 'red',
            '[PP_WARNING]' : 'yellow',
            '[PP_INFO]'    : 'green',
            '[PP_COMMAND]' : 'cyan',
        }[msg_type]
    except:
        color = 'blue'
    print(colored(msg,color,attrs=['bold']))        

MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
os.chdir(MODEL_ROOT)


print_message('--------------------------------------------------------')
print_message("         Big Core Post-Process  :  "+args.test_name      )
print_message('--------------------------------------------------------')
# Path to the directory containing the tests
base_path = "target/big_core/tests"
sc_path = "target/sc_core/tests"
# Construct the path to the transcript file
transcript = args.test_name+"_transcript"
file_transcript = os.path.join(base_path, args.test_name, transcript).replace("\\", "/")

# Construct the paths to the two files to compare
big_core_trk_path = os.path.join(base_path, args.test_name, "trk_rf.log").replace("\\", "/")
sc_core_trk_path = os.path.join(sc_path, args.test_name, "trk_rf.log").replace("\\", "/")

if os.path.exists(sc_core_trk_path):
    # Construct the path to the output file
    output_path = os.path.join(base_path, args.test_name, "test_golden_checker.log")
    output_path = os.path.normpath(output_path)
    output_path = output_path.replace("\\","/")
    
    # Read the contents of both files
    with open(big_core_trk_path, 'r') as big_core_trk, open(sc_core_trk_path, 'r') as sc_core_trk:
        big_core_trk_contents = big_core_trk.readlines()
        sc_core_trk_contents = sc_core_trk.readlines()
        print(f"Current test file: ",colored(big_core_trk_path,'yellow', attrs=['bold']))
        print(f"Golden file:       ",colored(sc_core_trk_path,'yellow', attrs=['bold']))
    
    # ignore timestamp
    for i, line in enumerate(big_core_trk_contents):
        big_core_trk_contents[i] = ('|'.join(line.split('|')[1:])).split('\n')[0]
    for i, line in enumerate(sc_core_trk_contents):
        sc_core_trk_contents[i]  = ('|'.join(line.split('|')[1:])).split('\n')[0]
    
    # Find the differences between the files
    differ  = difflib.Differ()
    diff    = list(differ.compare(big_core_trk_contents, sc_core_trk_contents))
    # print the diff to the output file
    diff_file = open(output_path, 'w')
    diff_file.write("review the diff between the current test and the golden tracker\n\n")
    diff_file.write("The + : line is present in golden but not in the test \n")
    diff_file.write("The - : line is present in test but not in the golden\n")
    diff_file.write("The ? : both line exist, with a diff mark with ^^^^^^ \n")
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
        print_message(f"[PP_WARNING] There are {num_diffs} differences between the two files:")
        print_message(f"[PP_INFO] Please refer to {output_path} to see the full diff\n")

    #check if the test have failed: 
    # 1) the test has the string "ERROR" in the transcript
    # 2) number of diff > 0 
    if("ERROR" in open(file_transcript).read()):
        print_message(f"\n[PP_ERROR] {args.test_name} has failed - See Error in the test transcript\n"+file_transcript)
        sys.exit(1)
    if num_diffs == 0:
        print(colored("\n[PP_INFO] Post-Process finish successfully ",'green',attrs=['bold']))
        sys.exit(0)
    else:
        print_message(f"\n[PP_ERROR] {args.test_name} have failed Post-Process")
        sys.exit(1)



