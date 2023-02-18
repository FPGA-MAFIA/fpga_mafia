import os
from termcolor import colored, cprint

def print_message(msg):
    msg_type = msg.split()[0]
    try:
        color = {
            '[ERROR]'   : 'red',
            '[WARNING]' : 'red',
            '[INFO]'    : 'yellow',
            '[COMMAND]' : 'cyan',
        }[msg_type]
    except:
        color = 'blue'
    print(colored(msg,color,attrs=['bold']))        

print_message('******************************************************************************')
#print_message('                              Cache Post-Process')
cprint("                              Cache Post-Process", "red",attrs=['bold'])
# Path to the directory containing the "dir_name" subdirectories
base_path = "target/cache/tests"

# Initialize variable to keep track of total diffs
total_diffs = 0

fails = 0
num_tests = 0

# Iterate over all subdirectories in the base path
for dir_name in os.listdir(base_path):
    num_tests +=1
    # Construct the paths to the two files to compare
    file1_path = os.path.join(base_path, dir_name, "cache_top_trk.log")
    file2_path = os.path.join("verif/cache/golden_trk", "golden_" + dir_name + "_top_trk.log")

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
        output_path = os.path.join(base_path, dir_name, "test_golden_checker.log")
        output_path = os.path.normpath(output_path)
        output_path = output_path.replace("\\","/")
        

        with open(file1_path, 'r') as file1, open(file2_path, 'r') as file2, open(output_path, 'w') as diff_file:
            line_num = 1
            while True:
                # Read a line from each file
                line1 = file1.readline()
                line2 = file2.readline()

                # If we've reached the end of either file, exit the loop
                if not line1 or not line2:
                    break

                # If the lines are different, write them to the diff file with differences highlighted
                if line1 != line2:
                    num_diffs += 1
                    total_diffs +=1
                    diff_file.write(f'Line {line_num}:\n')
                    diff_file.write(f'{line1.strip()}\n')
                    diff_file.write(f'{line2.strip()}\n')

                    # Highlight the differences between the lines
                    max_len = max(len(line1), len(line2))
                    for i in range(max_len):
                        if i >= len(line1) or i >= len(line2) or line1[i] != line2[i]:
                            diff_file.write('^')
                            break
                        else:
                            diff_file.write(' ')
                    diff_file.write('\n')
                
                line_num += 1

        # Print the number of diffs to the screen, if no diff skip this part
        if num_diffs > 0:
            messg = "\nTest - " + dir_name
            print(colored(messg,'blue',attrs=['bold']))
            print(f"\nNumber of diffs: ",colored(num_diffs,'red', attrs=['bold']))
            fails += 1

        with open(output_path, "r+") as output_file:
            old_data = output_file.read()
            output_file.seek(0)
            # Write the number of diffs
            output_file.write("Number of diffs: {}\n\n".format(num_diffs) + old_data)


        if num_diffs > 0:
        # Print the path to the output file
            print(f"Please refer to" ,colored(output_path,'white',attrs=['bold']), "to see the diff\n")
    else: 
        print_message(f"\n[WARNING] No golden tracker found for test {dir_name}")

print_message('------------------------------------------------------------------------------')         
if total_diffs == 0:
    print(colored("\n[INFO] All golden trackers Match",'green',attrs=['bold']))
else:
    print(colored(f"\n[INFO] {fails} test(s) have failed Post-Process out of {num_tests}",'yellow',attrs=['bold']))
   

print_message('******************************************************************************')           
