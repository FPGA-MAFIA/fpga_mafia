#!/bin/python3

import os
import subprocess
import glob
import argparse
from termcolor import colored

parser = argparse.ArgumentParser(description='Build script for any project')
parser.add_argument('-all', action='store_true', default=False, help='running all the tests')
parser.add_argument('-tests', default='', help='list of the tests for run the script on')
parser.add_argument('-debug', action='store_true', help='run simulation with debug flag')
parser.add_argument('-app', action='store_true', help='compile the RISCV SW into SV executables')
parser.add_argument('-hw', action='store_true', help='compile the RISCV HW into simulation')
parser.add_argument('-sim', action='store_true', help='start simulation')
parser.add_argument('-full_run', action='store_true', help='compile SW, HW of the test and simulate it')
parser.add_argument('-proj_name', default='big_core', help='insert your project name (as mentioned in the dirs name')
args = parser.parse_args()

MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
VERIF = './verif/'+args.proj_name+'/'
TB = './verif/'+args.proj_name+'/tb/'
MODELSIM = './modelsim/'+args.proj_name+'/'
SOURCE = './source/'+args.proj_name+'/'
TARGET = './target/'+args.proj_name+'/'
APP = './app/'
APP_C = './app/c/'

#####################################################################################################
#                                           class Test
#####################################################################################################
class Test:
    def __init__(self, name, project):
        self.name = name
        self.project = project 
        self.gcc_dir = self._create_gcc_dir()
        self.path = APP_C+self.name+'.c' if os.path.exists(APP_C+self.name+'.c') else ''
    def _create_gcc_dir(self):
        if os.path.exists(TARGET+'gcc_gen_files/'+self.name):
            pass
            #for file in os.listdir(TARGET+'gcc_gen_files/'+self.name):
            #    os.remove(TARGET+'gcc_gen_files/'+self.name+'/'+file)
        else:
            os.mkdir(TARGET+'gcc_gen_files/'+self.name)
        return TARGET+'gcc_gen_files/'+self.name+'/'
    def _test_compilation(self):
        if self.path:
            cs_path =  self.name+'_rv32i.c.s'
            elf_path = self.name+'_rv32i.elf'
            txt_path = self.name+'_rv32i_elf.txt'
            commands = []
            commands.append('rv_gcc -S -ffreestanding -march=rv32i ../../../../'+self.path+' -o '+cs_path)
            commands.append('rv_gcc -O3 -march=rv32i -T ../../../../app/link.common.ld -nostartfiles -D__riscv__ '+cs_path+' -o '+elf_path)
            commands.append('rv_objdump -gd '+elf_path+' > '+txt_path)
            commands.append('rv_objcopy --srec-len 1 --output-target=verilog '+elf_path+' inst_mem.sv')
            with open(self.gcc_dir+'commands.sh', 'w') as p:
                for cmd in commands:
                    p.write(cmd+' ;\n')
            try:
                os.chdir(self.gcc_dir)
                subprocess.call('commands.sh', shell=True)
                os.chdir(MODEL_ROOT)
            except:
                print_message('[ERROR] Failed to compile SW of '+self.name+'.c')
        else:
            print_message('[ERROR] Can\'t find the c files of '+self.name)
            exit(1)
    def _compile_simulation(self):
        os.chdir(MODELSIM)
        comp_sim_cmd = 'vlog.exe -lint -f ../../'+TB+'/'+self.project+'_list.f'
        try:
            os.system(comp_sim_cmd)
        except:
            print_message('[ERROR] Failed to compile simulation of '+self.name)
        os.chdir(MODEL_ROOT)
    def _start_simulation(self):
        os.chdir(MODELSIM)
        sim_cmd = 'vsim.exe work.'+self.project+'_tb -c -do "run -all" +STRING='+self.name
        print(sim_cmd)
        try:
            subprocess.call(sim_cmd, shell=True)
        except:
            print_message('[ERROR] Failed to simulate '+self.name)
        os.chdir(MODEL_ROOT)
    def _gui(self):
        os.chdir(MODELSIM)
        gui_cmd = 'vsim.exe -gui work.'+self.project+'_tb'
        try:
            subprocess.call(gui_cmd, shell=True)
        except:
            print_message('[ERROR] Failed to run gui of '+self.name)
        os.chdir(MODEL_ROOT)
    def _no_debug(self):
        for test in os.listdir(TARGET):
            for file in os.listdir(TARGET+'/'+test):
                os.remove(file)

def print_message(msg):
    msg_type = msg.split()[0]
    color = 'red' if msg_type == '[ERROR]' else 'yellow' if msg_type == '[WARNING]' else 'green'
    print(colored(msg,color,attrs=['bold']))        

#####################################################################################################
#                                           main
#####################################################################################################       
def main():
    
    os.chdir(MODEL_ROOT)
    tests = []
    if args.all:
        test_list = os.listdir(APP_C)
        for test in test_list:
            tests.append(Test(test.split('.c')[0], args.proj_name))
    else:
        for test in args.tests.split():
            tests.append(Test(test))
        
    for test in tests:
        print_message('[INFO] ***********************************************************************')
        print_message('[INFO] Test - '+test.name)
        if args.app or args.full_run:
            test._test_compilation()
        if args.hw or args.full_run:
            test._compile_simulation()
        if args.sim or args.full_run:
            test._start_simulation()
        if not args.debug:
            test._no_debug()
        print_message('[INFO] ***********************************************************************')
    
if __name__ == "__main__" :
    main()      
