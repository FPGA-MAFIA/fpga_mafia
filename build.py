#! /usr/bin/env python
import time
import os
import shutil
import subprocess
import glob
import argparse
import sys
from termcolor import colored

examples = '''
Examples:
python build.py -dut 'big_core' -all -full_run                      -> running full test (app, hw, sim) for all the tests and keeping the outputs 
python build.py -dut 'big_core'        -all -full_run                      -> running full test (app, hw, sim) for all the tests and removing the outputs 
python build.py -dut 'big_core' -tests 'alive plus_test' -full_run  -> run full test (app, hw, sim) for alive & plus_test only 
python build.py -dut 'big_core' -tests 'alive' -app                 -> compiling the sw for 'alive' test only 
python build.py -dut 'big_core' -tests 'alive' -hw                  -> compiling the hw for 'alive' test only 
python build.py -dut 'big_core' -tests 'alive' -sim -gui            -> running simulation with gui for 'alive' test only 
python build.py -dut 'big_core' -tests 'alive' -app -hw -sim -fpga  -> running alive test + FPGA compilation & synthesis
python build.py -dut 'big_core' -tests 'alive' -app -cmd            -> get the command for compiling the sw for 'alive' test only 
python build.py -dut 'router'  -tests simple -hw -sim -params '\-gV_NUM_FIFO=4' -> using parameter override in simulation
python build.py -dut 'router'  -tests all_fifo_full_BW -hw -sim -params '\-gV_REQUESTS=4' -> using parameter override in simulation
python build.py -dut 'fabric -top fabric_mini_cors_tb -app -hw -sim -> Using the -top argument to specify the tb top module name for simulation
'''
parser = argparse.ArgumentParser(description='Build script for any project', formatter_class=argparse.RawDescriptionHelpFormatter, epilog=examples)
parser.add_argument('-dut',       default='big_core',     help='insert your project name (as mentioned in the dirs name')
parser.add_argument('-tests',     default='',             help='list of the tests for run the script on')
parser.add_argument('-regress',   default='',             help='insert a level of regression to run on')
parser.add_argument('-app',       action='store_true',    help='compile the RISCV SW into SV executables')
parser.add_argument('-hw',        action='store_true',    help='compile the RISCV HW into simulation')
parser.add_argument('-sim',       action='store_true',    help='start simulation')
parser.add_argument('-all',       action='store_true', default=False, help='running all the tests')
parser.add_argument('-full_run',  action='store_true',    help='compile SW, HW of the test and simulate it')
parser.add_argument('-clean',     action='store_true',    help='clean target/dut/tests/ directory before starting running the build script')
parser.add_argument('-cmd',       action='store_true',    help='dont run the script, just print the commands')
parser.add_argument('-pp',        action='store_true',    help='run post-process on the tests')
parser.add_argument('-no_debug',  action='store_true',    help='run simulation without debug flag')
parser.add_argument('-gui',       action='store_true',    help='run simulation with gui')
parser.add_argument('-fpga',      action='store_true',    help='run compile & synthesis for the fpga')
parser.add_argument('-params',    default=' ',            help='used for overriding parameter values in simulation')
parser.add_argument('-keep_going',action='store_true',    help='keep going even if one test fails')
parser.add_argument('-mif'       ,action='store_true',    help='create the mif memory files for the FPGA load')
parser.add_argument('-top',       default=None,           help='insert your top module name for simulation (default is the <dut>+_tb name)')
args = parser.parse_args()
# if -top was not specified, use the dut name + the _tb suffix
if args.top is None:
    args.top = args.dut + '_tb'

MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
VERIF     = './verif/'+args.dut+'/'
TB        = './verif/'+args.dut+'/tb/'
SOURCE    = './source/'+args.dut+'/'
TARGET    = './target/'+args.dut+'/'
MODELSIM  = './target/'+args.dut+'/modelsim/'
APP       = './app/'
TESTS     = './verif/'+args.dut+'/tests/'
REGRESS   = './verif/'+args.dut+'/regress/'
FPGA_ROOT = './FPGA/'+args.dut+'/'

#####################################################################################################
#                                           class Test
#####################################################################################################
# This class is used for creating a test object
# Each test object has the following attributes:
#   name:           name of the test
#   file_name:      name of the test file
#   assembly:       True if the test is written in assembly, False if it is written in C
#   project:        name of the project
#   target:         path to the test directory
#   gcc_dir:        path to the gcc directory
#   path:           path to the test file
#   fail_flag:      True if the test failed, False otherwise
#####################################################################################################
class Test:
    hw_compilation = False
    I_MEM_OFFSET = str(0x00000000) # -> 0x0000FFFF
    I_MEM_LENGTH = str(0x00010000)
    D_MEM_OFFSET = str(0x00010000) # -> 0x0001EFFF
    D_MEM_LENGTH = str(0x0000F000)
    # SCRATCH_D_MEM_OFFSET = str(0x0001F000) # -> 0x0001FFFF
    # SCRATCH_D_MEM_LENGTH = str(0x00001000)
    # Total of 128KB of memory (64KB for I_MEM and 64KB for D_MEM+SCRATCH_D_MEM)
    def __init__(self, name, params, dut):
        self.name = name.split('.')[0]
        self.file_name = name
        self.assembly = True if self.file_name[-1] == 's' else False
        self.dut = dut 
        self.target , self.gcc_dir = self._create_test_dir()
        self.path = TESTS+self.file_name
        self.fail_flag = False
        self.app_flag = False
        self.mif_flag = False
        self.duration = 0
        self.top = args.top
        # the tests parameters
        self.params = params # FIXME ABD
    def _create_test_dir(self):
        if not os.path.exists(TARGET):
            mkdir(TARGET)
        if not os.path.exists(TARGET+'tests'):
            mkdir(TARGET+'tests')
        if not os.path.exists(TARGET+'tests/'+self.name):
            mkdir(TARGET+'tests/'+self.name)
        if not os.path.exists(TARGET+'tests/'+self.name+'/gcc_files'):
            if(args.app or args.mif or args.fpga):
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
            data_init_path = self.name+'_data_init.txt'
            search_path  = '-I ../../../../../app/defines '
            chdir(self.gcc_dir)
            try:
                if not self.assembly:
                    first_cmd  = 'riscv-none-embed-gcc.exe -S -ffreestanding -march=rv32i '+search_path+'../../../../../'+self.path+' -o '+cs_path
                    run_cmd(first_cmd)
                else:
                    pass
            except:
                print_message(f'[ERROR] failed to gcc the test - {self.name}')
                self.fail_flag = True
            else:
                try:
                    rv32i_gcc    = 'riscv-none-embed-gcc.exe -O3 -march=rv32i '
                    rv32i_gcc    = 'riscv-none-embed-gcc.exe -O3 -march=rv32i '
                    i_mem_offset = '-Wl,--defsym=I_MEM_OFFSET='+Test.I_MEM_OFFSET+' -Wl,--defsym=I_MEM_LENGTH='+Test.I_MEM_LENGTH+' '
                    d_mem_offset = '-Wl,--defsym=D_MEM_OFFSET='+Test.D_MEM_OFFSET+' -Wl,--defsym=D_MEM_LENGTH='+Test.D_MEM_LENGTH+' '
                    mem_offset   = i_mem_offset+d_mem_offset
                    crt0_file    = '../../../../../app/crt0.S '
                    mem_layout   = '-Wl,-Map='+self.name+'.map '
                    second_cmd = rv32i_gcc+'-T ../../../../../app/link.common.ld ' + search_path + mem_offset + '-nostartfiles -D__riscv__ '+ mem_layout + crt0_file + cs_path+ ' -o ' + elf_path
                    crt0_file    = '../../../../../app/crt0.S '
                    mem_layout   = '-Wl,-Map='+self.name+'.map '
                    second_cmd = rv32i_gcc+'-T ../../../../../app/link.common.ld ' + search_path + mem_offset + '-nostartfiles -D__riscv__ '+ mem_layout + crt0_file + cs_path+ ' -o ' + elf_path
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
                                # copy the inst_mem to a new file, call it og_inst_mem.sv
                                os.system('cp inst_mem.sv og_inst_mem.sv')
                                # same the content of the inst_mem.sv to the variable "memories"
                                memories = open('inst_mem.sv', 'r').read()
                                #The string that we want to search for to check if the data memory is exist
                                # example: @00010000
                                dmem_string = '@{:08x}'.format(int(Test.D_MEM_OFFSET))
                                #print_message(dmem_string)
                                if dmem_string in memories:
                                    print_message('[INFO] Data memory exist')
                                    # save the content before D_MEM_OFFSET to inst_mem.sv
                                    # save the content after D_MEM_OFFSET to data_mem.sv
                                    # Split the memories string into two parts - before and after D_MEM_OFFSET
                                    inst_mem, data_mem = memories.split(dmem_string)
                                    # Save the content before D_MEM_OFFSET to inst_mem.sv
                                    with open('inst_mem.sv', 'w') as imem:
                                        imem.write(inst_mem)
                                    # Save the content after D_MEM_OFFSET to data_mem.sv
                                    with open('data_mem.sv', 'w') as dmem:
                                        dmem.write(dmem_string + data_mem)
                                else:
                                    print_message('[INFO] data memory dos not exist')
                                    # Leave the inst_mem.sv as it is - there is no D_MEM_OFFSET in the inst_mem.sv

            if not self.fail_flag:
                print_message('[INFO] SW compilation finished with no errors\n')
        else:
            print_message('[ERROR] Can\'t find the c files of '+self.name)
            self.fail_flag = True
        chdir(MODEL_ROOT)
        self.app_flag = True
    def _compile_hw(self):
        chdir(MODELSIM)
        print_message('[INFO] Starting to compile HW ...')
        if not Test.hw_compilation:
            try:
                comp_sim_cmd = 'vlog.exe -lint -f ../../../'+TB+'/'+self.dut+'_list.f'
                results = run_cmd_with_capture(comp_sim_cmd) 
            except:
                print_message('[ERROR] Failed to compile simulation of '+self.name)
                self.fail_flag = True
            else:
                Test.hw_compilation = True
                if len(results.stdout.split('Error')) > 2:
                    self.fail_flag = True
                    print_message(results.stdout)
                else:
                    with open("hw_compile.log", "w") as file:
                        file.write(results.stdout)
                    print_message('[INFO] hw compilation finished with - '+','.join(results.stdout.split('\n')[-2:-1]))
                    print_message('=== Compile results >>>>> target/'+self.dut+'/modelsim/hw_compile.log')
        else:
            print_message(f'[INFO] HW compilation is already done\n')
        chdir(MODEL_ROOT)
    def _start_simulation(self):
        chdir(MODELSIM)
        print_message('[INFO] Now running simulation ...')
        try:
            sim_cmd = 'vsim.exe work.' + self.top + ' -c -do "run -all" ' + self.params + ' +STRING=' + self.name
            results = run_cmd_with_capture(sim_cmd)
        except:
            print_message('[ERROR] Failed to simulate '+self.name)
            self.fail_flag = True
        else:
            if len(results.stdout.split('Error')) > 2:
                self.fail_flag = True
                print_message(results.stdout)
            else:
                print_message('[INFO] hw simulation finished with - '+','.join(results.stdout.split('\n')[-2:-1]))
            print_message('=== Simulation results >>>>> target/'+self.dut+'/tests/'+self.name+'/'+self.name+'_transcript')
        if os.path.exists('transcript'):  # copy transcript file to the test directory
            shutil.copy('transcript', '../tests/'+self.name+'/'+self.name+'_transcript')
        chdir(MODEL_ROOT)
    def _gui(self):
        chdir(MODELSIM)
        try:
            gui_cmd = 'vsim.exe -gui work.'+ self.top +  self.params + ' +STRING='+self.name+' &'
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
            print_message('[ERROR] failed to remove /target/'+self.dut+'/tests/'+self.name+' directory')
    def _post_process(self):
        # Go to the verification directory
        chdir(VERIF)
        # Run the post process command
        try:
            pp_cmd = 'python '+self.dut+'_pp.py ' +self.name
            return_val = run_cmd_with_capture(pp_cmd)
            print_message(colored(return_val.stdout,'yellow',attrs=['bold']))        
        except:
            print_message('[ERROR] Failed to run post process ')
            self.fail_flag = True
        # Go back to the model directory
        chdir(MODEL_ROOT)
        # Return the return code of the post process command
        return return_val.returncode

    def _start_mif(self):
        chdir(FPGA_ROOT)
        # generate mif files
        try:
            i_mem_mif_cmd = 'python scripts/mif_gen.py ../../'+TARGET+'tests/'+self.name+'/gcc_files/inst_mem.sv mif/i_mem.mif 0'
            results = run_cmd_with_capture(i_mem_mif_cmd)
        except:
            print_message('[ERROR] Failed to generate i_mem.mif file for test '+self.name)
            self.fail_flag = True
        else:
            try:
                if os.path.exists('../../'+TARGET+'tests/'+self.name+'/gcc_files/data_mem.sv'):
                    d_mem_mif_cmd = 'python scripts/mif_gen.py ../../'+TARGET+'tests/'+self.name+'/gcc_files/data_mem.sv mif/d_mem.mif 10000'
                else:
                    d_mem_mif_cmd = 'cp mif/defult_d_mem.mif mif/d_mem.mif'
                results = run_cmd_with_capture(d_mem_mif_cmd) if os.path.exists('../../'+TARGET+'tests/'+self.name+'/gcc_files/data_mem.sv') else True
            except:
                print_message('[ERROR] Failed to generate d_mem.mif file for test '+self.name)
                self.fail_flag = True
        chdir(MODEL_ROOT)       
        self.mif_flag = True

    def _start_fpga(self):
        chdir(FPGA_ROOT)
        if not self.fail_flag:
            try:
                fpga_cmd = 'quartus_map --read_settings_files=on --write_settings_files=off de10_lite_'+self.dut+' -c de10_lite_'+self.dut+' '
                results = run_cmd_with_capture(fpga_cmd)
            except:
                print_message('[ERROR] Failed to run FPGA compilation & synth of '+self.name)
                self.fail_flag = True
        chdir(MODEL_ROOT)       
        find_war_err_cmd = 'grep -ri --color "Info.*error.*warning" ./FPGA/'+args.dut+'/output_files/*'
        results = run_cmd_with_capture(find_war_err_cmd)
        print_message(f'[INFO]'+results.stdout)
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
    if not os.path.exists(VERIF):
        print_message(f'[ERROR] There is no dut \'{args.dut}\'')
        exit(1)

    # if args.clean  clean target/dut/tests/ directory before starting running the build script
    if args.clean:
        print_message('[INFO] cleaning target/'+args.dut+'/tests/ directory')
        if os.path.exists('target/'+args.dut+'/tests/'):
            rm_target_cmd  = 'rm -rf target/'+args.dut+'/tests/'
            run_cmd(rm_target_cmd)
            #shutil.rmtree('target/'+args.dut+'/tests/')
        else:
            print_message('[INFO] nothing to clean - target/'+args.dut+'/tests/ directory does not exist')
    
    # create target/dut/tests/ directory if not exists
    if not os.path.exists('target/'+args.dut+'/tests/'):
        os.makedirs('target/'+args.dut+'/tests/')
    # log_file = "target/big_core/build_log.txt"
    
    # the tests list declared - will be filled using one of the arguments: all, regress, tests
    tests = []
    run_status = "PASSED" # default value for run status

    # make sure not using '-all', '-regress', 'tests' together
    if (args.all and args.regress) or (args.all and args.tests) or (args.regress and args.tests):
        print_message('[ERROR] can\'t use any combination of: -all, -regress, tests')
        exit(1)
    # make sure using at least one of '-all', '-regress', 'tests'
    if not (args.all or args.regress or args.tests):
        print_message('[ERROR] must use at least one of: -all, -regress, tests')
        exit(1)


    # if args.params collect the parameters from the command and save them as a string
    if args.params:
        parameter = args.params # save the parameters as a string
        parameter = parameter.replace('\\','')# remove the backslash
    else:
        parameter = ''

    # get the tests list
    if args.all:
        test_list = os.listdir(TESTS)
        for test in test_list:
            if 'level' in test: continue
            tests.append(Test(test, parameter, args.dut))
    elif args.regress:
        try:
            #use the firs column of the regression file as the tests list
            level_list = [line.split()[0] for line in open(REGRESS+args.regress)]
            # trying to debug why this is not working printing level_list
            print_message(f'[INFO] level_list: {level_list}')
            # the rest of the columns are the tests parameters
            # if there is no parameters for a test, the default parameters will be used for that line
            params_list = [line.split()[1:] for line in open(REGRESS+args.regress)]
            print_message(f'[INFO] params_list: {params_list}')
        except:
            print_message(f'[ERROR] Failed to run regression file \'{args.regress}\' in your tests directory')
            exit(1)
        else:
            for idx, test in enumerate(level_list):
                if os.path.exists(TESTS+test+".sv") or os.path.exists(TESTS+test):
                    # add the test to the tests list with the corresponding parameters
                    # print for debug the test, the parameters and the dut
                    # test_params = params_list[level_list.index(test)][0] if params_list[level_list.index(test)] else ""
                    # print_message(f'[INFO] test: {test}, params: {test_params}, dut: {args.dut}')
                    test_params = ' '.join(params_list[idx]) if params_list[idx] else ""
                    print_message(f'[INFO] test: {test}, params: {test_params}, dut: {args.dut}')
                    tests.append(Test(test, test_params, args.dut))
                else:
                    print_message('[ERROR] can\'t find the test - '+test)
                    exit(1)
    elif args.tests:
        for test in args.tests.split():
            try:
                test = glob.glob(TESTS+test+'*')[0]
            except:
                print_message(f'[ERROR] There is no test {test} in your tests directory')
                exit(1)
            else:
                test = test.replace('\\', '/').split('/')[-1]
                tests.append(Test(test, parameter, args.dut))

    # Redirect stdout and stderr to log file
    # sys.stdout = open(log_file, "w", buffering=1)
    # sys.stderr = open(log_file, "w", buffering=1)   

    for test in tests:
        start_test_time = time.time()

        # check out the output has an directory with the test name and the *_transcript file, if so, copy the dir with a suffix _1, _2, etc.
        if os.path.exists('target/'+args.dut+'/tests/'+test.name+'/'+test.name+'_transcript'):
            i=1
            while os.path.exists('target/'+args.dut+'/tests/'+test.name+'_'+str(i)):
                i += 1
            shutil.copytree('target/'+args.dut+'/tests/'+test.name, 'target/'+args.dut+'/tests/'+test.name+'_'+str(i))
            # remove the test directory log files
            rm_test_log_cmd  = 'rm -rf target/'+args.dut+'/tests/'+test.name+'/*.log'
            run_cmd(rm_test_log_cmd)

        print_message('******************************************************************************')
        print_message('                               Test - '+test.name)
        print_message('******************************************************************************')
        if(run_status == "FAILED" and not args.keep_going):
            print_message('[ERROR] previous test failed, skipping test - '+test.name+'\n')
            test.fail_flag = True
        else:
            if (test.fail_flag and args.keep_going):
                print_message('[INFO] previous test failed, using -keep_going -> continuing test - '+test.name+'\n')
            if (args.app or args.full_run) and not test.fail_flag:
                test._compile_sw()
            if (args.hw or args.full_run) and not test.fail_flag:
                test._compile_hw()
            if (args.sim or args.full_run) and not test.fail_flag:
                test._start_simulation()
            if (args.fpga) and not test.fail_flag:
                if not test.app_flag:
                    test._compile_sw()
                if not test.mif_flag:
                    test._start_mif()
                test._start_fpga()
            if (args.mif):
                if not test.app_flag:
                    test._compile_sw()
                test._start_mif()
            if (args.gui):
                test._gui()
            if (args.pp) and not test.fail_flag:
                if (test._post_process()):# if return value is 0, then the post process is done successfully
                    test.fail_flag = True
            if args.no_debug:
                test._no_debug()

            # print the test execution time
            end_test_time = time.time()
            test.duration = end_test_time - start_test_time
            print_message(f"[INFO] test execution took {test.duration:.2f} seconds.")

            print_message(f'************************** End {test.name} **********************************')
            print()
            if(test.fail_flag):
                run_status = "FAILED"
    # sys.stdout.flush()
    # sys.stderr.flush()


#===================================================================================================
#       EOT - End Of Test section
#===================================================================================================
    print_message('=============================')
    print_message('[INFO] Tests Final Status:')
    print_message('=============================')
    for test in tests:
        if(test.fail_flag==True):
            print_message(f'[ERROR] test failed - {test.name} - target/{args.dut}/tests/{test.name}/ , execution time: {test.duration:.2f} seconds.')
        if(test.fail_flag==False):
            print_message(f'[INFO] test Passed - {test.name} - target/{args.dut}/tests/{test.name}/ , execution time: {test.duration:.2f} seconds.')

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
    start_time = time.time()
    exit_status = main()
    end_time = time.time()
    duration = end_time - start_time
    print_message(f"[INFO] Script execution took {duration:.2f} seconds.")

    sys.exit(exit_status)
