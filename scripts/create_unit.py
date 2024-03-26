#! /usr/bin/env python

# This script will create a new unit in the MAFIA repository
# It will get a Unit name from the user and create all the necessary files for getting started
# The Place Holder unit is A simple ALU unit that support ADD,SUB,AND,OR,XOR operations

import os
import sys
import shutil
import argparse
import re
import subprocess
from termcolor import colored

# this is the content of the files for the unit template
import create_unit_content


parser = argparse.ArgumentParser(description='Create a new unit template in the MAFIA project', formatter_class=argparse.RawDescriptionHelpFormatter)
parser.add_argument('-unit',  help='Name of the unit to create', required=True)

args = parser.parse_args()

# =====================================================================
# defs to create directories and files + print colored messages
# =====================================================================
def mkdir(dir):
    if os.path.exists(dir):
        print_message(f'[INFO] Directory {dir} already exists')
        return
    print_message(f'[COMMAND] mkdir '+dir)
    os.makedirs(dir)
def chdir(dir):
    if not os.path.exists(dir):
        print_message(f'[ERROR] Directory {dir} does not exist')
        return
    print_message(f'[COMMAND] cd '+dir)
    os.chdir(dir)
def touch(file):
    if os.path.exists(file):
        print_message(f'[INFO] File {file} already exists')
        return
    print_message(f'[COMMAND] touch '+file)
    open(file, 'w').close()

# write to file string
def write_to_file(file, string):
    print_message(f'[COMMAND] echo "Content" > {file}')
    with open(file, 'w') as f:
        f.write(string)

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

    print(colored(msg, color, attrs=['bold']))



#=====================================================================
# Define the Paths
#=====================================================================
# Define the root of the model
MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
# Unit source directory
SOURCE_DIR      = './source/'+args.unit+'/'
SOURCE_PKG      = './source/'+args.unit+'/'+args.unit+'_pkg.sv'
SOURCE_UNIT     = './source/'+args.unit+'/'+args.unit+'.sv'
RTL_FILE_LIST   = './source/'+args.unit+'/'+args.unit+'_rtl_list.f'
# Unit Verif directory
VERIF_DIR       = './verif/'+args.unit+'/'
TB_DIR          = './verif/'+args.unit+'/tb/'
TB_FILE         = './verif/'+args.unit+'/tb/'+args.unit+'_tb.sv'
HW_SEQ_DIR      = './verif/'+args.unit+'/tb/hw_seq/'
TASKS_DIR       = './verif/'+args.unit+'/tb/tasks/'
TRK_DIR         = './verif/'+args.unit+'/tb/trk/'
REGRESS_DIR     = './verif/'+args.unit+'/regress/'
TEST_DIR        = './verif/'+args.unit+'/tests/'
HW_SEQ_FILE     = './verif/'+args.unit+'/tb/hw_seq/'+args.unit+'_hw_seq.vh'
TASKS_FILE      = './verif/'+args.unit+'/tb/tasks/'+args.unit+'_tasks.vh'
TRK_FILE        = './verif/'+args.unit+'/tb/trk/'+args.unit+'_trk.vh'
FILE_LIST_DIR   = './verif/'+args.unit+'/file_list/'
FILE_LIST       = './verif/'+args.unit+'/file_list/'+args.unit+'_list.f'
VERIF_FILE_LIST = './verif/'+args.unit+'/file_list/'+args.unit+'_verif_list.f'
TEST_FILE       = './verif/'+args.unit+'/tests/alive.vh'
LEVEL0_FILE     = './verif/'+args.unit+'/regress/level0'
PP              = './verif/'+args.unit+'/pp/'+args.unit+'_pp.py'


SOURCE_PKG_CONTENT      = create_unit_content.SOURCE_PKG_CONTENT.format(unit=args.unit)
SOURCE_UNIT_CONTENT     = create_unit_content.SOURCE_UNIT_CONTENT.format(unit=args.unit)
RTL_FILE_LIST_CONTENT   = create_unit_content.RTL_FILE_LIST_CONTENT.format(unit=args.unit)

# Now you can use `formatted_pkg_content` and `formatted_unit_content` in your script

# Create the source directory and it's its files
def create_source():
    print_message(f'[INFO] Creating source directory and files for unit {args.unit}')
    mkdir(SOURCE_DIR)
    touch(SOURCE_PKG)
    touch(SOURCE_UNIT)
    touch(RTL_FILE_LIST)
    write_to_file(SOURCE_PKG    , SOURCE_PKG_CONTENT)
    write_to_file(SOURCE_UNIT   , SOURCE_UNIT_CONTENT)
    write_to_file(RTL_FILE_LIST , RTL_FILE_LIST_CONTENT)


TB_FILE_CONTENT         = create_unit_content.TB_FILE_CONTENT.format(unit=args.unit)
VERIF_FILE_LIST_CONTENT = create_unit_content.VERIF_FILE_LIST_CONTENT.format(unit=args.unit)
FILE_LIST_CONTENT       = create_unit_content.FILE_LIST_CONTENT.format(unit=args.unit)
VERIF_TASKS_CONTENT     = create_unit_content.VERIF_TASKS_CONTENT.format(unit=args.unit)
#VERIF_HW_SEQ_CONTENT    = create_unit_content.VERIF_HW_SEQ_CONTENT.format(unit=args.unit)
#VERIF_TRK_CONTENT       = create_unit_content.VERIF_TRK_CONTENT.format(unit=args.unit)
#VERIF_TEST_CONTENT      = create_unit_content.VERIF_TEST_CONTENT.format(unit=args.unit)
#VERIF_LEVEL0_CONTENT    = create_unit_content.VERIF_LEVEL0_CONTENT.format(unit=args.unit)
#VERIF_PP_CONTENT        = create_unit_content.VERIF_PP_CONTENT.format(unit=args.unit)

def create_verif():
    print_message(f'[INFO] Creating verif directory and files for unit {args.unit}')
    mkdir(VERIF_DIR)
    mkdir(TB_DIR)
    mkdir(REGRESS_DIR)
    mkdir(HW_SEQ_DIR)
    mkdir(TASKS_DIR)
    mkdir(TRK_DIR)
    mkdir(TEST_DIR)
    mkdir(FILE_LIST_DIR)
    touch(TB_FILE)
    touch(VERIF_FILE_LIST)
    touch(FILE_LIST)
    touch(TASKS_FILE)
    write_to_file(TB_FILE, TB_FILE_CONTENT)
    write_to_file(VERIF_FILE_LIST, VERIF_FILE_LIST_CONTENT)
    write_to_file(FILE_LIST, FILE_LIST_CONTENT)
    write_to_file(TASKS_FILE, VERIF_TASKS_CONTENT)
#    touch(HW_SEQ_FILE)
#    touch(TASKS_FILE)
#    touch(TRK_FILE)
#    touch(FILE_LIST)
#    touch(VERIF_FILE_LIST)
#    touch(TEST_FILE)
#    touch(LEVEL0_FILE)
#    touch(PP)


create_source()
create_verif()