#! /usr/bin/env python
import os
import shutil
import subprocess
import glob
import argparse
import sys
from termcolor import colored



examples = '''
Examples:
python build.py -dut 'big_core' -debug -all -full_run                      -> running full test (app, hw, sim) for all the tests and keeping the outputs 
python build.py -dut 'big_core'        -all -full_run                      -> running full test (app, hw, sim) for all the tests and removing the outputs 
python build.py -dut 'big_core' -debug -tests 'alive plus_test' -full_run  -> run full test (app, hw, sim) for alive & plus_test only 
python build.py -dut 'big_core' -debug -tests 'alive' -app                 -> compiling the sw for 'alive' test only 
python build.py -dut 'big_core' -debug -tests 'alive' -hw                  -> compiling the hw for 'alive' test only 
python build.py -dut 'big_core' -debug -tests 'alive' -sim -gui            -> running simulation with gui for 'alive' test only 
python build.py -dut 'big_core' -debug -tests 'alive' -app -hw -sim -fpga  -> running alive test + FPGA compilation & synthesis
python build.py -dut 'big_core' -debug -tests 'alive' -app -cmd            -> get the command for compiling the sw for 'alive' test only 
'''
parser = argparse.ArgumentParser(description='Build script for any project', formatter_class=argparse.RawDescriptionHelpFormatter, epilog=examples)
parser.add_argument('-all',       action='store_true', default=False, help='running all the tests')
parser.add_argument('-tests',     default='',             help='list of the tests for run the script on')
parser.add_argument('-debug',     action='store_true',    help='run simulation with debug flag')
parser.add_argument('-gui',       action='store_true',    help='run simulation with gui')
parser.add_argument('-app',       action='store_true',    help='compile the RISCV SW into SV executables')
parser.add_argument('-hw',        action='store_true',    help='compile the RISCV HW into simulation')
parser.add_argument('-sim',       action='store_true',    help='start simulation')
parser.add_argument('-full_run',  action='store_true',    help='compile SW, HW of the test and simulate it')
parser.add_argument('-dut',       default='big_core',     help='insert your project name (as mentioned in the dirs name')
parser.add_argument('-pp',        action='store_true',    help='run post-process on the tests')
parser.add_argument('-fpga',      action='store_true',    help='run compile & synthesis for the fpga')
parser.add_argument('-regress',   default='',             help='insert a level of regression to run on')
parser.add_argument('-cmd',       action='store_true',   help='dont run the script, just print the commands')
args = parser.parse_args()

MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
VERIF     = './verif/'+args.dut+'/'
TB        = './verif/'+args.dut+'/tb/'
SOURCE    = './source/'+args.dut+'/'
TARGET    = './target/'+args.dut+'/'
MODELSIM  = './target/'+args.dut+'/modelsim/'
APP       = './app/'
TESTS     = './verif/'+args.dut+'/tests/'
FPGA_ROOT = './FPGA/'+args.dut+'/'

#####################################################################################################
#                                           class Test
#####################################################################################################
class Test:
    hw_compilation = False
    I_MEM_OFFSET = str(0x00000000)
    I_MEM_LENGTH = str(0x00010000)
    D_MEM_OFFSET = str(0x00010000)
    D_MEM_LENGTH = str(0x0000F000)
    def __init__(self, name, project):
        self.name = name.split('.')[0]
        self.file_name = name
        self.assembly = True if self.file_name[-1] == 's' else False
        self.project = project 
        self.target , self.gcc_dir = self._create_test_dir()
        self.path = TESTS+self.file_name
        self.fail_flag = False
    def _create_test_dir(self):
        if not os.path.exists(TARGET):
            mkdir(TARGET)
        if not os.path.exists(TARGET+'tests'):
            mkdir(TARGET+'tests')
        if not os.path.exists(TARGET+'tests/'+self.name):
            mkdir(TARGET+'tests/'+self.name)
        if not os.path.exists(TARGET+'tests/'+self.name+'/gcc_files'):
            mkdir(TARGET+'tests/'+self.name+'/gcc_files')
        if not os.path.exists(MODELSIM):
            mkdir(MODELSIM)
        if not os.path.exists(MODELSIM+'work'):
            mkdir(MODELSIM+'work')
        return TARGET+'tests/'+self.name+'/', TARGET+'tests/'+self.name+'/gcc_files'
    def _compile_sw(self):
        print_message('[INFO] Starting to compile SW ...')
        if self.path:
            cs_path =  self.name+'_rv32i.c.s' if not self.assembly else '../../../../../'+self.path
            elf_path = self.name+'_rv32i.elf'
            txt_path = self.name+'_rv32i_elf.txt'
            chdir(self.gcc_dir)
            try:
                if not self.assembly:
                    first_cmd  = 'riscv-none-embed-gcc.exe -S -ffreestanding -march=rv32i ../../../../../'+self.path+' -o '+cs_path
                    run_cmd(first_cmd)
                else:
                    pass
            except:
                print_message(f'[ERROR] failed to gcc the test - {self.name}')
                self.fail_flag = True
            else:
                try:
                    rv32i_gcc    = 'riscv-none-embed-gcc.exe  -O3 -march=rv32i '
                    i_mem_offset = '-Wl,--defsym=I_MEM_OFFSET='+Test.I_MEM_OFFSET+' -Wl,--defsym=I_MEM_LENGTH='+Test.I_MEM_LENGTH+' '
                    d_mem_offset = '-Wl,--defsym=D_MEM_OFFSET='+Test.D_MEM_OFFSET+' -Wl,--defsym=D_MEM_LENGTH='+Test.D_MEM_LENGTH+' '
                    mem_offset   = i_mem_offset+d_mem_offset
                    second_cmd = rv32i_gcc+'-T ../../../../../app/link.common.ld '+mem_offset+'-nostartfiles -D__riscv__ ../../../../../app/crt0.S '+cs_path+' -o '+elf_path
                    run_cmd(second_cmd)
                except:
                    print_message(f'[ERROR] failed to insert linker & crt0.S to the test - {self.name}')
                    self.fail_flag = True
                else:
                    try:
                        third_cmd  = 'riscv-none-embed-objdump.exe -gd {} > {}'.format(elf_path, txt_path)
                        run_cmd(third_cmd)
                    except:
                        print_message(f'[ERROR] failed to create "elf.txt" to the test - {self.name}')
                        self.fail_flag = True
                    else:
                        try:
                            forth_cmd  = 'riscv-none-embed-objcopy.exe --srec-len 1 --output-target=verilog '+elf_path+' inst_mem.sv' 
                            run_cmd(forth_cmd)
                        except:
                            print_message(f'[ERROR] failed to create "inst_mem.sv" to the test - {self.name}')
                            self.fail_flag = True
                        else:
                            if(args.cmd==False):
                                memories = open('inst_mem.sv', 'r').read()
                                with open('data_mem.sv', 'w') as dmem:
                                    if (len(memories.split('@'))>2):
                                        dmem.write('@'+memories.split('@')[-1])
                                    else:
                                        pass
                                with open('inst_mem.sv', 'w') as imem:
                                    imem.write('@'+memories.split('@')[1])
            if not self.fail_flag:
                print_message('[INFO] SW compilation finished with no errors\n')
        else:
            print_message('[ERROR] Can\'t find the c files of '+self.name)
            self.fail_flag = True
        chdir(MODEL_ROOT)
    def _compile_hw(self):
        chdir(MODELSIM)
        print_message('[INFO] Starting to compile HW ...')
        if not Test.hw_compilation:
            try:
                comp_sim_cmd = 'vlog.exe -lint -f ../../../'+TB+'/'+self.project+'_list.f'
                results = run_cmd_with_capture(comp_sim_cmd) 
            except:
                print_message('[ERROR] Failed to compile simulation of '+self.name)
                self.fail_flag = True
            else:
                Test.hw_compilation = True
                if len(results.stdout.split('Error')) > 2:
                    self.fail_flag = True
                    print(results.stdout)
                else:
                    #print(results.stdout)
                    with open("hw_compile.log", "w") as file:
                        file.write(results.stdout)
                    print_message('[INFO] hw compilation finished with - '+','.join(results.stdout.split('\n')[-2:-1]))
                    print_message('=== Compile results >>>>> target/'+self.project+'/modelsim/hw_compile.log')
        else:
            print_message(f'[INFO] HW compilation is already done\n')
        chdir(MODEL_ROOT)
    def _start_simulation(self):
        chdir(MODELSIM)
        print_message('[INFO] Now running simulation ...')
        try:
            sim_cmd = 'vsim.exe work.'+self.project+'_tb -c -do "run -all" +STRING='+self.name
            results = run_cmd_with_capture(sim_cmd)
        except:
            print_message('[ERROR] Failed to simulate '+self.name)
            self.fail_flag = True
        else:
            if len(results.stdout.split('Error')) > 2:
                self.fail_flag = True
                print(results.stdout)
            else:
                print_message('[INFO] hw simulation finished with - '+','.join(results.stdout.split('\n')[-2:-1]))
            print_message('=== Simulation results >>>>> target/'+self.project+'/tests/'+self.name+'/'+self.name+'_transcript')
        if os.path.exists('transcript'):  # copy transcript file to the test directory
            shutil.copy('transcript', '../tests/'+self.name+'/'+self.name+'_transcript')
        chdir(MODEL_ROOT)
    def _gui(self):
        chdir(MODELSIM)
        try:
            gui_cmd = 'vsim.exe -gui work.'+self.project+'_tb +STRING='+self.name+' &'
            run_cmd(gui_cmd)
        except:
            print_message('[ERROR] Failed to run gui of '+self.name)
            self.fail_flag = True
        chdir(MODEL_ROOT)
    def _no_debug(self):
        try:
            delete_cmd = 'rm -rf '+TARGET+'tests/'+self.name
            run_cmd(delete_cmd)
        except:
            print_message('[ERROR] failed to remove /target/'+self.project+'/tests/'+self.name+' directory')
    def _post_process(self):
        # Go to the verification directory
        chdir(VERIF)
        # Run the post process command
        try:
            pp_cmd = 'python '+self.project+'_pp.py ' +self.name
            return_val = run_cmd_with_capture(pp_cmd)
            print(colored(return_val.stdout,'yellow',attrs=['bold']))        
        except:
            print_message('[ERROR] Failed to run post process ')
            self.fail_flag = True
        # Go back to the model directory
        chdir(MODEL_ROOT)
        # Return the return code of the post process command
        return return_val.returncode

    def _start_fpga(self):
        chdir(FPGA_ROOT)
        try:
            fpga_cmd = 'quartus_map --read_settings_files=on --write_settings_files=off de10_lite_'+self.project+' -c de10_lite_'+self.project+' '
            results = run_cmd_with_capture(fpga_cmd)
        except:
            print_message('[ERROR] Failed to run FPGA compilation & synth of '+self.name)
            self.fail_flag = True
        chdir(MODEL_ROOT)       
        find_war_err_cmd = 'grep -ri --color "Info.*error.*warning" ./FPGA/'+args.dut+'/output_files/*'
        results = run_cmd_with_capture(find_war_err_cmd)
        print(results.stdout)
        print_message(f'[INFO] FPGA results: - FPGA/'+args.dut+'/output_files/')

        
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
    if(args.cmd == False) or ( msg_type == '[COMMAND]'):
        print(colored(msg,color,attrs=['bold']))        

def run_cmd(cmd):
    print_message(f'[COMMAND] '+cmd)
    if(args.cmd == False):
        subprocess.check_output(cmd, shell=True)


def mkdir(dir):
    print_message(f'[COMMAND] mkdir '+dir)
    os.mkdir(dir)

def chdir(dir):
    print_message(f'[COMMAND] cd '+dir)
    os.chdir(dir)

def run_cmd_with_capture(cmd):
    print_message(f'[COMMAND] '+cmd)
    # default value for results so return value is not None
    results = subprocess.run("echo ", stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    if(args.cmd == False):
        results = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    return results
#####################################################################################################
#                                           main
#####################################################################################################       
def main():
    os.chdir(MODEL_ROOT)
    if not os.path.exists('target/'+args.dut+'/tests/'):
        os.makedirs('target/'+args.dut+'/tests/')
    # log_file = "target/big_core/build_log.txt"
    
    tests = []
    if args.all:
        test_list = os.listdir(TESTS)
        for test in test_list:
            if 'level' in test: continue
            tests.append(Test(test, args.dut))
    elif args.regress:
        level_list = open(TESTS+args.regress, 'r').read().split('\n')
        for test in level_list:
            if os.path.exists(TESTS+test):
                tests.append(Test(test, args.dut))
            else:
                print_message('[ERROR] can\'t find the test - '+test)
    else:
        for test in args.tests.split():
            test = glob.glob(TESTS+test+'*')[0]
            test = test.replace('\\', '/').split('/')[-1]
            tests.append(Test(test, args.dut))

     # Redirect stdout and stderr to log file
    # sys.stdout = open(log_file, "w", buffering=1)
    # sys.stderr = open(log_file, "w", buffering=1)   
    run_status = "PASSED"
    for test in tests:
        print_message('******************************************************************************')
        print_message('                               Test - '+test.name)
        print_message('******************************************************************************')
        if (args.app or args.full_run) and not test.fail_flag:
            test._compile_sw()
        if (args.hw or args.full_run) and not test.fail_flag:
            test._compile_hw()
        if (args.sim or args.full_run) and not test.fail_flag:
            test._start_simulation()
        if (args.fpga) and not test.fail_flag:
            test._start_fpga()
        if (args.gui):
            test._gui()
        if (args.pp) and not test.fail_flag:
            if (test._post_process()):# if return value is 0, then the post process is done successfully
                test.fail_flag = True
        if not args.debug:
            test._no_debug()
        print_message(f'************************** End {test.name} **********************************')
        print()
        if(test.fail_flag):
            run_status = "FAILED"
    # sys.stdout.flush()
    # sys.stderr.flush()

    if(run_status == "FAILED"):
        print_message('The failed tests are:')
    for test in tests:
        if(test.fail_flag==True):
            print_message(f'[ERROR] test failed - {test.name}  - target/'+args.dut+'/tests/'+test.name+'/')
        if(test.fail_flag==False):
            print_message(f'[INFO] test Passed- {test.name}  - target/'+args.dut+'/tests/'+test.name+'/')
    print_message('=================================================================================')
    print_message('---------------------------------------------------------------------------------')
    print_message('=================================================================================')
    print_message(f'[INFO] Run final status: {run_status}')
    print_message('=================================================================================')
    print_message('---------------------------------------------------------------------------------')
    print_message('=================================================================================')
    if(run_status == "FAILED"):
        return 1
    else:
        return 0

if __name__ == "__main__" :
    sys.exit(main())
