import re
import os
import argparse
import subprocess
import sys
from termcolor import colored
# Setup argument parsing
parser = argparse.ArgumentParser(description="Parse VGA memory access log and convert it to text.")
parser.add_argument("test", help="The name of the test to process")
parser.add_argument('-v', '--verbose', action='store_true', help='Increase output verbosity')
args = parser.parse_args()
found_error = False

def print_message(msg):
    # Trim whitespace and check if the message is empty
    if not msg.strip():
        return  # Exit the function early if there's nothing to print

    # Split the message once and reuse the result
    msg_parts = msg.split()
    msg_type = msg_parts[0] if msg_parts else '[INFO]'  # Default to '[INFO]' if msg is empty
    # Use a try-except block to handle KeyError when msg_type isn't found in the dictionary
    try:
        color = {
            '[ERROR]'   : 'red',
            '[WARNING]' : 'yellow',
            '[INFO]'    : 'green',
            '[COMMAND]' : 'cyan',
        }[msg_type]
    except KeyError:
        color = 'blue'  # Default color if msg_type isn't one of the predefined keys
    # Print the message in color if not in command mode or if it's a command
    #print only if verbose is set
    if args.verbose:
        print(colored(msg, color, attrs=['bold']))
# Make sure we are in the MODEL_ROOT directory
MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
def chdir(dir):
    if args.verbose:  # Check if the verbose flag is set
        print_message(f'[COMMAND] cd '+dir)
    os.chdir(dir)
chdir(MODEL_ROOT)



# Define the ASCII table font
ascii_table_font = {
    # ascii value : <char>, <name>, <FONT_TOP>, <FONT_BTM>
    0x20: (' ', 'SPACE'),
    0x21: ('!', 'EXCLM'),
    0x22: ('"', 'DQ'),
    0x23: ('#', 'NUM'),
    0x24: ('$', 'DOL'),
    0x25: ('%', 'PCNT'),
    0x26: ('&', 'AMP'),
    0x27: ("'", 'SQ'),
    0x28: ('(', 'OP_PRN'),
    0x29: (')', 'CL_PRN'),
    0x2A: ('*', 'AST'),
    0x2B: ('+', 'PLUS'),
    0x2C: (',', 'COMMA'),
    0x2D: ('-', 'DASH'),
    0x2E: ('.', 'POINT'),
    0x2F: ('/', 'SLASH'),
    0x30: ('0', 'ZERO'),
    0x31: ('1', 'ONE'),
    0x32: ('2', 'TWO'),
    0x33: ('3', 'THREE'),
    0x34: ('4', 'FOUR'),
    0x35: ('5', 'FIVE'),
    0x36: ('6', 'SIX'),
    0x37: ('7', 'SEVEN'),
    0x38: ('8', 'EIGHT'),
    0x39: ('9', 'NINE'),
    0x3A: (':', 'COLON'),
    0x3B: (';', 'SCOLON'),
    0x3C: ('<', 'LT'),
    0x3D: ('=', 'EQL'),
    0x3E: ('>', 'GT'),
    0x3F: ('?', 'QMARK'),
    0x40: ('@', 'AT'),
    0x41: ('A', 'A'),
    0x42: ('B', 'B'),
    0x43: ('C', 'C'),
    0x44: ('D', 'D'),
    0x45: ('E', 'E'),
    0x46: ('F', 'F'),
    0x47: ('G', 'G'),
    0x48: ('H', 'H'),
    0x49: ('I', 'I'),
    0x4A: ('J', 'J'),
    0x4B: ('K', 'K'),
    0x4C: ('L', 'L'),
    0x4D: ('M', 'M'),
    0x4E: ('N', 'N'),
    0x4F: ('O', 'O'),
    0x50: ('P', 'P'),
    0x51: ('Q', 'Q'),
    0x52: ('R', 'R'),
    0x53: ('S', 'S'),
    0x54: ('T', 'T'),
    0x55: ('U', 'U'),
    0x56: ('V', 'V'),
    0x57: ('W', 'W'),
    0x58: ('X', 'X'),
    0x59: ('Y', 'Y'),
    0x5A: ('Z', 'Z'),
    0x5B: ('[', 'OB'),
    0x5C: ('\\', 'BSLASH'),
    0x5D: (']', 'CB'),
    0x5E: ('^', 'CIR'),
    0x5F: ('_', 'UNDR_SCR'),
    0x60: ('`', 'GRV'),
    0x61: ('a', 'a'),
    0x62: ('b', 'b'),
    0x63: ('c', 'c'),
    0x64: ('d', 'd'),
    0x65: ('e', 'e'),
    0x66: ('f', 'f'),
    0x67: ('g', 'g'),
    0x68: ('h', 'h'),
    0x69: ('i', 'i'),
    0x6A: ('j', 'j'),
    0x6B: ('k', 'k'),
    0x6C: ('l', 'l'),
    0x6D: ('m', 'm'),
    0x6E: ('n', 'n'),
    0x6F: ('o', 'o'),
    0x70: ('p', 'p'),
    0x71: ('q', 'q'),
    0x72: ('r', 'r'),
    0x73: ('s', 's'),
    0x74: ('t', 't'),
    0x75: ('u', 'u'),
    0x76: ('v', 'v'),
    0x77: ('w', 'w'),
    0x78: ('x', 'x'),
    0x79: ('y', 'y'),
    0x7A: ('z', 'z'),
    0x7B: ('{', 'OBR'),
    0x7C: ('|', 'VBAR'),
    0x7D: ('}', 'CBR'),
    0x7E: ('~', 'TLD'),
}






def create_new_ascii_table_font(ascii_table_font, header_content):
    new_ascii_table_font = {}
    pattern = re.compile(r'#define\s+([A-Za-z0-9_]+)_TOP\s+0x([0-9A-Fa-f]+).*?#define\s+\1_BTM\s+0x([0-9A-Fa-f]+)', re.DOTALL)
    matches = pattern.findall(header_content)

    name_to_font_data = {match[0]: (int(match[1], 16), int(match[2], 16)) for match in matches}

    for ascii_val, (char, name) in ascii_table_font.items():
        font_name = name
        if font_name in name_to_font_data:
            font_top, font_btm = name_to_font_data[font_name]
            new_ascii_table_font[ascii_val] = (char, name, font_top, font_btm)
        else:
            print_message(f"[ERROR] No match found for: {char} ({name})")

    return new_ascii_table_font



# grab the content from "app/defines/graphic_vga.h"
def read_header_content(file_path):
    try:
        with open(file_path, 'r') as file:
            return file.read()
    except FileNotFoundError:
        print_message(f"[ERROR] File not found: {file_path}")
        return None
    except Exception as e:
        print_message(f"[INFO] An error occurred while reading the file: {e}")
        return None

# Path to the header file containing the ASCII table font
header_file_path = f'./app/defines/graphic_vga.h'

# Read the content of the header file
header_content = read_header_content(header_file_path)

if header_content is not None:
    # Now you can proceed to use header_content with the rest of your script logic
    print_message("[INFO] Header content read successfully.")
else:
    print_message("[ERROR] Failed to read header content.")



# Create the new ASCII table font
new_ascii_table_font = create_new_ascii_table_font(ascii_table_font, header_content)



# Assuming VGA_MEM_BASE as 0x00ff0000 based on the log pattern provided.
VGA_MEM_BASE = 0x00ff0000
LINE_SIZE = 0x140  # Size of a line in the memory map.

# Helper function to convert data to ASCII character based on the ascii_table_font
def data_to_ascii(top_data, bottom_data):
    for ascii_val, (char, _, font_top, font_btm) in new_ascii_table_font.items():
        if font_top == top_data and font_btm == bottom_data:
            return char
    return '?'  # If no match is found, return a question mark

# Main function to parse the VGA memory access log
def parse_vga_log_to_text(log_lines):
    output_lines = []  # Stores the lines of ASCII characters
    current_line = []  # Stores the current line of ASCII characters
    current_line_number = 0  # Track the current line number
    
    for index in range(0, len(log_lines), 2):  # Process entries in pairs
        top_entry_parts = log_lines[index].split('|')
        bottom_entry_parts = log_lines[index + 1].split('|')
        
        # Extract address and data values
        top_address = int(top_entry_parts[3].strip(), 16)
        bottom_address = int(bottom_entry_parts[3].strip(), 16)
        top_data = int(top_entry_parts[4].strip(), 16)
        bottom_data = int(bottom_entry_parts[4].strip(), 16)
        
        # Calculate line number based on top address
        line_number = (top_address - VGA_MEM_BASE) // (LINE_SIZE * 2)
        
        if line_number != current_line_number:  # New line detected
            # Join the current line characters and add to the output
            output_lines.append(''.join(current_line))
            current_line = []  # Reset current line
            current_line_number = line_number
        
        # Convert the data values to an ASCII character and add to the current line
        ascii_char = data_to_ascii(top_data, bottom_data)
        current_line.append(ascii_char)
    
    # Add the last line if not empty
    if current_line:
        output_lines.append(''.join(current_line))
    
    # Join all the lines with newline characters to form the output text
    return '\n'.join(output_lines)


# Construct the path to the log file and the output file based on the test name argument
TESTS_PATH = f'target/core_rrv/tests/{args.test}/'
log_file_path = f'{TESTS_PATH}trk_vga_memory_access.log'
output_file_path = f'{TESTS_PATH}vga_output.txt'

# Read the log file
with open(log_file_path, 'r') as file:
    log_lines = file.readlines()[3:]  # Skip the header lines

# Parse the log lines to text
output_text = parse_vga_log_to_text(log_lines)

# Save the output to a text file
with open(output_file_path, 'w') as file:
    file.write(output_text)

print(f"=== VGA screen results >>>>>>>> {output_file_path}")

if(found_error):
    sys.exit(1)
else:
    sys.exit(0)