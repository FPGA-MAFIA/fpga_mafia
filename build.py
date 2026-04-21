#! /usr/bin/env python
import time
import os
import shutil
import subprocess
import glob
import argparse
import sys
import json
import fileinput
import re

examples = '''
Examples:
python build.py -dut 'big_core' -all -full_run                      -> running full test (app, hw, sim) for all the tests and keeping the outputs 
python build.py -dut 'big_core' -all -full_run                      -> running full test (app, hw, sim) for all the tests and removing the outputs 
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
parser.add_argument('-cfg',       type=str,               help='Specify the JSON configuration file')
parser.add_argument('-dut',       default='big_core',     help='insert your project name (as mentioned in the dirs name')
parser.add_argument('-tests',     default='',             help='list of the tests for run the script on')
parser.add_argument('-regress',   default='',             help='insert a level of regression to run on')
parser.add_argument('-app',       action='store_true',    help='compile the RISCV SW into SV executables')
parser.add_argument('-hw',        action='store_true',    help='compile the RISCV HW into simulation')
parser.add_argument('-sim',       action='store_true',    help='start simulation')
parser.add_argument('-all',       action='store_true',    default=False, help='running all the tests')
parser.add_argument('-full_run',  action='store_true',    help='compile SW, HW of the test and simulate it')
parser.add_argument('-clean',     action='store_true',    help='clean target/dut/tests/ directory before starting running the build script')
parser.add_argument('-cmd',       action='store_true',    help='dont run the script, just print the commands')
parser.add_argument('-v', '--verbose', action='store_true', help='Increase output verbosity')
parser.add_argument('-pp',        action='store_true',    help='run post-process on the tests')
parser.add_argument('-no_debug',  action='store_true',    help='run simulation without debug flag')
parser.add_argument('-gui',       action='store_true',    help='run simulation with gui')
parser.add_argument('-fpga',      action='store_true',    help='Quartus full compile (Analysis/Synth+Fit+Asm+STA) for the DUT')
parser.add_argument('-fpga_project', default=None,         help='Override Quartus project name (default: auto-detect *.qsf under FPGA/<dut>/)')
parser.add_argument('-prog',      action='store_true',    help='Program the DE10-Lite with the produced .sof (requires -fpga or an existing .sof)')
parser.add_argument('-reload',    action='store_true',    help='Fast reload: regen MIFs + quartus_cdb --update_mif + quartus_asm (no Map/Fit). Needs prior full -fpga compile.')
parser.add_argument('-params',    default=' ',            help='used for overriding parameter values in simulation')
parser.add_argument('-keep_going',action='store_true',    help='keep going even if one test fails')
parser.add_argument('-mif'       ,action='store_true',    help='create the mif memory files for the FPGA load')
parser.add_argument('-top',       default=None,           help='insert your top module name for simulation (default is the <dut>+_tb name)')
args = parser.parse_args()
# if -top was not specified, use the dut name + the _tb suffix
if args.top is None:
    args.top = args.dut + '_tb'

# if the cmd is set, run with verbose
if args.cmd:
    args.verbose = True

MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
VERIF     = './verif/'+args.dut+'/'
TB        = './verif/'+args.dut+'/tb/'
FILE_LIST = '/verif/'+args.dut+'/file_list/'+args.dut+'_list.f'
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
    # SCRATCH_D_MEM_OFFSET = str(0x0001F000) # -> 0x0001FFFF
    # SCRATCH_D_MEM_LENGTH = str(0x00001000)
    # Total of 128KB of memory (64KB for I_MEM and 64KB for D_MEM+SCRATCH_D_MEM)
    def __init__(self, name, params, dut):
        self.name = name.split('.')[0]
        self.file_name = name
        self.assembly = True if self.file_name.endswith('s') else False
        self.dut = dut 
        self.target = TARGET+'tests/'+self.name+'/'
        self.path = TESTS + self.name + '.' + ('s' if self.file_name.endswith('s') else 'c')
        self.fail_flag = False
        self.app_flag = False
        self.mif_flag = False
        self.duration = 0
        self.top = args.top
        # the tests parameters
        self.params = params # FIXME ABD
        # Load configuration from JSON file or use defaults
        self.load_config()

    def load_json(self,json_file):
        #loading configuration from the specified JSON file
        with open(json_file) as config_file:
            config_data = json.load(config_file)
        Test.I_MEM_OFFSET = str(config_data['I_MEM_OFFSET'])
        Test.I_MEM_LENGTH = str(config_data['I_MEM_LENGTH'])
        Test.D_MEM_OFFSET = str(config_data['D_MEM_OFFSET'])
        Test.D_MEM_LENGTH = str(config_data['D_MEM_LENGTH'])
        Test.crt0_file    = config_data['crt0_file']
        Test.rv32_gcc     = config_data['rv32_gcc']
        Test.name         = config_data['name']
        #Only of the ovrd_params exist in the JSON file, we will use it
        if 'ovrd_params' in config_data:
            Test.ovrd_params  = config_data['ovrd_params']
        else:
            Test.ovrd_params  = None
        if 'gcc_optimize' in config_data:
            Test.gcc_optimize  = config_data['gcc_optimize']
        else:
            Test.gcc_optimize  = ' '

    def load_config(self):
        # Default JSON file location
        json_directory = 'app/cfg/'

        # Check if the -cfg flag is provided
        if args.cfg:
            json_file = os.path.join(json_directory, args.cfg +'.json')
            if not os.path.exists(json_file):
                print_message(f'[ERROR] There is no file \'{args.cfg}\'')
                exit(1)
            else:
                print_message(f'[INFO] Using configuration from \'{args.cfg}\'')
                 #loading configuration from the specified JSON file
                self.load_json(json_file)
        else:
            # Auto-pick a per-DUT config if present (e.g. app/cfg/lotr_rv32i.json),
            # otherwise fall back to default.json. Tries <dut>_rv32i, <dut>_rv32e,
            # then <dut>.json before default.
            candidates = [args.dut + '_rv32i', args.dut + '_rv32e', args.dut]
            picked = None
            for name in candidates:
                p = os.path.join(json_directory, name + '.json')
                if os.path.isfile(p):
                    picked = (name, p)
                    break
            if picked:
                print_message(f'[INFO] Auto-selected configuration \'{picked[0]}\' for dut={args.dut}')
                self.load_json(picked[1])
            else:
                print_message(f'[INFO] Using default configuration')
                json_file = os.path.join(json_directory, 'default.json')
                self.load_json(json_file)

    def _compile_sw(self):
        print_message('--------------------------------------------')
        print_message('[INFO] Starting to compile SW ...')
        if self.path:
            cs_path =  self.name+'_'+Test.name+'.c.s' if not self.assembly else '../../../../../'+self.path
            elf_path = self.name+'_'+Test.name+'.elf'
            txt_path = self.name+'_'+Test.name+'_elf.txt'
            txt_path_v2 = self.name+'_'+Test.name+'_elf_v2.txt'
            data_init_path = self.name+'_data_init.txt'
            search_path  = '-I ../../../../../app/defines '
            cs_interrupt_handler_name = ' interrupt_handler_rv32i.c.s'
            self.gcc_dir = TARGET+'tests/'+self.name+'/gcc_files'
            test_resources_path = '-I ../../../../../' + TESTS + self.name + '/'
            if not os.path.exists(self.gcc_dir):
                mkdir(self.gcc_dir)
            chdir(self.gcc_dir)
            try:
                if not self.assembly:
                    first_cmd = 'riscv-none-embed-gcc.exe ' + Test.gcc_optimize + ' -S -ffreestanding -march=' + Test.rv32_gcc + ' ' + search_path + test_resources_path + ' ' + '../../../../../' + self.path + ' -o ' + cs_path
                    run_cmd(first_cmd)
                else:
                    pass
            except:
                print_message(f'[ERROR] failed to gcc the test - {self.name}')
                self.fail_flag = True
            else:
                try:
                    rv32_gcc    = 'riscv-none-embed-gcc.exe -O3 -march=' +Test.rv32_gcc+ ' '
                    i_mem_offset = '-Wl,--defsym=I_MEM_OFFSET='+Test.I_MEM_OFFSET+' -Wl,--defsym=I_MEM_LENGTH='+Test.I_MEM_LENGTH+' '
                    d_mem_offset = '-Wl,--defsym=D_MEM_OFFSET='+Test.D_MEM_OFFSET+' -Wl,--defsym=D_MEM_LENGTH='+Test.D_MEM_LENGTH+' '
                    mem_offset   = i_mem_offset+d_mem_offset
                    crt0_file = '../../../../../app/crt0/' + Test.crt0_file+' '
                    mem_layout   = '-Wl,-Map='+self.name+'.map '
                    mem_layout   = '-Wl,-Map='+self.name+'.map '
                    second_cmd = rv32_gcc+'-T ../../../../../app/link.common.ld ' + search_path + test_resources_path +' ' +  mem_offset + '-nostartfiles -D__riscv__ '+ mem_layout + crt0_file + cs_path+ ' -o ' + elf_path
                    run_cmd(second_cmd)
                except:
                    print_message(f'[ERROR] failed to insert linker & crt0.S to the test - {self.name}')
                    self.fail_flag = True
                else:
                    try:
                        third_cmd  = 'riscv-none-embed-objdump.exe -gd {} > {}'.format(elf_path, txt_path)
                        run_cmd(third_cmd)
                        # clean version of the elf.txt file - using the -M numeric -M no-aliases flags so we get x0,x1,x2 instead of zero, ra, sp.
                        # also using the ISA instruction instead of the pseudo instruction (instead of nop we get addi x0, x0, 0)
                        third_cmd_v2  = 'riscv-none-embed-objdump.exe -M numeric -M no-aliases -gd {} > {}'.format(elf_path, txt_path_v2)
                        run_cmd(third_cmd_v2)
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
                print_message('[INFO] SW compilation finished with no errors')
                print_message('--------------------------------------------')
        else:
            print_message('[ERROR] Can\'t find the c files of '+self.name)
            self.fail_flag = True
        chdir(MODEL_ROOT)
        self.app_flag = True
    def _compile_hw(self):
        print_message('[INFO] Starting to compile HW ...')

        # check if the ovrd_params is not empty
        if Test.ovrd_params:
            #check that the file exist ./scripts/ovrd_params/<Test.ovrd_params>
            csv_param_file = Test.ovrd_params
            if not os.path.exists('./scripts/ovrd_params/'+csv_param_file+'.csv'):
                print_message(f'[ERROR] There is no file '+csv_param_file)
                exit(1)
            else:
                #run the script to override the parameters using the csv file
                cmd_param_script = 'python ./scripts/ovrd_params.py -dut big_core -ovrd_file '+csv_param_file
                if args.verbose:
                    cmd_param_script += ' -v'
                results = run_cmd_with_capture(cmd_param_script) 
                print_message(results.stdout)



        if not os.path.exists(MODELSIM):
            mkdir(MODELSIM)
        if not os.path.exists(MODELSIM+'work'):
            mkdir(MODELSIM+'work')
        chdir(MODELSIM)
        if not Test.hw_compilation:
            try:
                # +acc keeps signals visible for waveform/debug (Questa vopt otherwise strips hierarchy).
                comp_sim_cmd = 'vlog.exe -lint +acc -f ../../../'+FILE_LIST
                results = run_cmd_with_capture(comp_sim_cmd) 
            except:
                print_message('[ERROR] Failed to compile simulation of '+self.name)
                self.fail_flag = True
            else:
                Test.hw_compilation = True
                errors, warnings, summary = Test._summarize_vsim_output(results.stdout)
                if errors > 0 or summary is None:
                    self.fail_flag = True
                    print_message(results.stdout)
                    if summary is None:
                        print_message('[ERROR] HW compilation did not produce an Errors/Warnings summary.')
                    else:
                        print_message('[ERROR] HW compilation reported ' + summary)
                else:
                    with open("hw_compile.log", "w") as file:
                        file.write(results.stdout)
                    print_message('[INFO] hw compilation finished with - ' + summary)
                    print_message('=== Compile results >>>>> target/'+self.dut+'/modelsim/hw_compile.log')
                    print_message('--------------------------------------------')
        else:
            print_message(f'[INFO] HW compilation is already done\n')
        chdir(MODEL_ROOT)

    @staticmethod
    def _summarize_vsim_output(stdout):
        """Return (errors, warnings, summary_line) parsed from Questa output.

        Parses the final ``Errors: N, Warnings: M`` line; falls back to scanning
        for any ``** Error`` / ``** Fatal`` messages so we don't silently pass if
        Questa died before printing a summary.
        """
        summary_re = re.compile(r'^#?\s*Errors:\s*(\d+),\s*Warnings:\s*(\d+)', re.MULTILINE)
        matches = list(summary_re.finditer(stdout or ''))
        if matches:
            m = matches[-1]
            return int(m.group(1)), int(m.group(2)), m.group(0).lstrip('#').strip()
        hard_error_re = re.compile(r'^\s*#?\s*\*\*\s*(Error|Fatal)\b', re.MULTILINE)
        hard_errors = len(hard_error_re.findall(stdout or ''))
        return hard_errors, 0, None

    def _start_simulation(self):
        chdir(MODELSIM)
        print_message('[INFO] Now running simulation ...')
        try:
            if not os.path.exists('../tests/'+self.name):
                mkdir('../tests/'+self.name)
            sim_cmd = (
                'vsim.exe -voptargs=+acc work.' + self.top
                + ' -c -do "run -all" ' + self.params + ' +STRING=' + self.name
            )
            results = run_cmd_with_capture(sim_cmd)
        except:
            print_message('[ERROR] Failed to simulate '+self.name)
            self.fail_flag = True
        else:
            errors, warnings, summary = Test._summarize_vsim_output(results.stdout)
            if errors > 0 or summary is None:
                self.fail_flag = True
                print_message(results.stdout)
                if summary is None:
                    print_message('[ERROR] Simulation did not produce an Errors/Warnings summary (possible crash).')
                else:
                    print_message('[ERROR] Simulation reported ' + summary)
            else:
                summary_text = summary if summary else 'Errors: 0, Warnings: ' + str(warnings)
                print_message('[INFO] HW simulation finished with - ' + summary_text)
            print_message('=== Simulation results >>>>> target/'+self.dut+'/tests/'+self.name+'/'+self.name+'_transcript')
            print_message('--------------------------------------------')
        if os.path.exists('transcript'):  # copy transcript file to the test directory
            if not os.path.exists('../tests/'+self.name+'/'+self.name+'_transcript'):
                if not os.path.exists('../tests/'+self.name):
                    mkdir('../tests/'+self.name)
                shutil.copy('transcript', '../tests/'+self.name+'/'+self.name+'_transcript')
        chdir(MODEL_ROOT)
    def _gui(self):
        chdir(MODELSIM)
        try:
            wave_tcl = os.path.join(MODEL_ROOT, 'verif', self.dut, 'tb', 'wave.do')
            do_wave = ''
            if os.path.isfile(wave_tcl):
                do_wave = ' -do "do ../../../verif/' + self.dut + '/tb/wave.do"'
            gui_cmd = (
                'vsim.exe -gui -voptargs=+acc work.' + self.top + self.params
                + ' +STRING=' + self.name + do_wave + ' &'
            )
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
        print_message('[INFO] Starting post process ...')
        # Go to the verification directory
        chdir(VERIF+'/pp')
        # Run the post process command
        try:
            run_with_verbose = '-v' if args.verbose else ' '
            ##pp_cmd = 'python '+self.dut+'_pp.py ' +self.name + ' ' +self.dut + ' ' + run_with_verbose
            pp_cmd = 'python '+self.dut+'_pp.py ' +self.name + ' ' + run_with_verbose
            print_message(f'[INFO] Running post process command: {pp_cmd}')
            return_val = run_cmd_with_capture(pp_cmd)
            #remove \n from the end of the stdout (if it exists)
            if return_val.stdout and return_val.stdout[-1] == '\n':
                return_val.stdout = return_val.stdout[:-1]
            print(return_val.stdout, flush=True)
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

    @staticmethod
    def _detect_fpga_project(fpga_dir):
        """Return Quartus project name (without extension) to use under ``fpga_dir``.

        Order: CLI override, ``de10_lite_<dut>.qsf``, any ``*.qsf`` in the dir.
        """
        if args.fpga_project:
            return args.fpga_project
        preferred = os.path.join(fpga_dir, 'de10_lite_' + args.dut + '.qsf')
        if os.path.isfile(preferred):
            return 'de10_lite_' + args.dut
        qsfs = sorted(glob.glob(os.path.join(fpga_dir, '*.qsf')))
        if qsfs:
            return os.path.splitext(os.path.basename(qsfs[0]))[0]
        return None

    def _start_fpga(self):
        """Run the full Quartus flow: quartus_sh --flow compile <project>."""
        fpga_dir_abs = os.path.abspath(FPGA_ROOT)
        project = Test._detect_fpga_project(FPGA_ROOT)
        if project is None:
            print_message('[ERROR] No Quartus .qsf found under ' + FPGA_ROOT + ' (try -fpga_project <name>)')
            self.fail_flag = True
            return
        print_message('[INFO] Running Quartus full compile for project ' + project + ' in ' + FPGA_ROOT)
        chdir(FPGA_ROOT)
        if not self.fail_flag:
            try:
                fpga_cmd = 'quartus_sh --flow compile ' + project
                results = run_cmd_with_capture(fpga_cmd)
                log_path = os.path.join('output_files', project + '.flow.log')
                try:
                    os.makedirs('output_files', exist_ok=True)
                    with open(log_path, 'w') as fh:
                        fh.write(results.stdout or '')
                except Exception:
                    pass
                stdout = results.stdout or ''
                if 'Full Compilation was successful' in stdout:
                    print_message('[INFO] Quartus full compile succeeded.')
                else:
                    print_message(stdout[-4000:])
                    print_message('[ERROR] Quartus full compile did not report success. See output_files/*.rpt and ' + log_path)
                    self.fail_flag = True
            except Exception:
                print_message('[ERROR] Failed to run FPGA full compile of ' + self.name)
                self.fail_flag = True
        chdir(MODEL_ROOT)
        # Summary line with key "Info:" lines from report files.
        find_war_err_cmd = 'grep -Hi "Info.*error.*warning" ' + FPGA_ROOT + 'output_files/*.rpt'
        results = run_cmd_with_capture(find_war_err_cmd)
        if results.stdout:
            print_message('[INFO] ' + results.stdout)
        print_message('[INFO] FPGA results: - ' + FPGA_ROOT + 'output_files/  (project: ' + project + ')')
        self._fpga_project = project
        self._fpga_sof = os.path.join(fpga_dir_abs, 'output_files', project + '.sof')

    def _reload_fpga(self):
        """Fast reload: regen MIFs + quartus_cdb --update_mif + quartus_asm.

        Skips Analysis & Synthesis and Fitter; reuses the existing placement/routing
        database and only refreshes embedded memory ROM initialization (`altsyncram`
        init_file). Typical wall time ~10 s on a 10M50.
        """
        fpga_dir_abs = os.path.abspath(FPGA_ROOT)
        project = Test._detect_fpga_project(FPGA_ROOT)
        if project is None:
            print_message('[ERROR] No Quartus .qsf found under ' + FPGA_ROOT
                          + ' (try -fpga_project <name>)')
            self.fail_flag = True
            return

        # Locate mif_gen.py (per-DUT first, then fall back to big_core's copy).
        mif_gen = os.path.join(FPGA_ROOT, 'scripts', 'mif_gen.py')
        if not os.path.isfile(mif_gen):
            mif_gen = os.path.join('FPGA', 'big_core', 'scripts', 'mif_gen.py')
        if not os.path.isfile(mif_gen):
            print_message('[ERROR] mif_gen.py not found at FPGA/<dut>/scripts or FPGA/big_core/scripts')
            self.fail_flag = True
            return

        # Memory init dir varies by project: LOTR uses mem_hex/, big_core uses mif/.
        mif_dir = None
        for candidate in ('mem_hex', 'mif'):
            c_path = os.path.join(FPGA_ROOT, candidate)
            if os.path.isdir(c_path):
                mif_dir = c_path
                break
        if mif_dir is None:
            print_message('[ERROR] No mem_hex/ or mif/ directory under ' + FPGA_ROOT)
            self.fail_flag = True
            return

        inst_src = os.path.join(TARGET, 'tests', self.name, 'gcc_files', 'inst_mem.sv')
        data_src = os.path.join(TARGET, 'tests', self.name, 'gcc_files', 'data_mem.sv')
        if not os.path.isfile(inst_src):
            print_message('[ERROR] {} missing; run -app first.'.format(inst_src))
            self.fail_flag = True
            return

        d_mem_offset_hex = '{:x}'.format(int(Test.D_MEM_OFFSET))
        imem_mif = os.path.join(mif_dir, 'i_mem.mif')
        dmem_mif = os.path.join(mif_dir, 'd_mem.mif')

        print_message('[INFO] Regenerating MIFs under ' + mif_dir)
        try:
            run_cmd('python {} {} {} 0'.format(mif_gen, inst_src, imem_mif))
            if os.path.isfile(data_src):
                run_cmd('python {} {} {} {}'.format(
                    mif_gen, data_src, dmem_mif, d_mem_offset_hex))
            else:
                print_message('[INFO] No data_mem.sv; leaving d_mem.mif untouched.')
        except Exception:
            print_message('[ERROR] MIF regen failed')
            self.fail_flag = True
            return

        chdir(FPGA_ROOT)
        try:
            print_message('[INFO] quartus_cdb --update_mif ' + project)
            run_cmd('quartus_cdb --update_mif ' + project)
            print_message('[INFO] quartus_asm ' + project)
            run_cmd('quartus_asm ' + project + ' -c ' + project)
        except Exception:
            print_message('[ERROR] update_mif / assembler failed (run a full -fpga first?)')
            self.fail_flag = True
            chdir(MODEL_ROOT)
            return
        chdir(MODEL_ROOT)

        self._fpga_project = project
        self._fpga_sof = os.path.join(fpga_dir_abs, 'output_files', project + '.sof')
        print_message('[INFO] Reload done. SOF: ' + self._fpga_sof)

    def _program_fpga(self):
        """Load the latest .sof onto the DE10-Lite via quartus_pgm."""
        project = getattr(self, '_fpga_project', None) or Test._detect_fpga_project(FPGA_ROOT)
        if project is None:
            print_message('[ERROR] Cannot program: no Quartus project found under ' + FPGA_ROOT)
            self.fail_flag = True
            return
        sof = getattr(self, '_fpga_sof', None) or os.path.abspath(
            os.path.join(FPGA_ROOT, 'output_files', project + '.sof')
        )
        if not os.path.isfile(sof):
            print_message('[ERROR] SOF not found: ' + sof + ' (run with -fpga first)')
            self.fail_flag = True
            return
        print_message('[INFO] Programming DE10-Lite with ' + sof)
        try:
            run_cmd('quartus_pgm -m jtag -o "p;' + sof + '"')
            print_message('[INFO] Programming done.')
        except Exception:
            print_message('[ERROR] quartus_pgm failed. Check USB-Blaster connection and JTAG cable.')
            self.fail_flag = True

def print_message(msg):
    # Trim whitespace and check if the message is empty
    if not msg.strip():
        return  # Exit the function early if there's nothing to print

    msg_parts = msg.split()
    msg_type = msg_parts[0] if msg_parts else '[INFO]'

    if not args.cmd or msg_type == '[COMMAND]':
        print(msg, flush=True)


def run_cmd(cmd):
    if args.verbose:  # Check if the verbose flag is set
        print_message(f'[COMMAND] '+cmd)
    if(args.cmd == False):
        subprocess.check_output(cmd, shell=True)


def mkdir(dir):
    if args.verbose:  # Check if the verbose flag is set
        print_message(f'[COMMAND] mkdir '+dir)
    os.makedirs(dir)

def chdir(dir):
    if args.verbose:  # Check if the verbose flag is set
        print_message(f'[COMMAND] cd '+dir)
    os.chdir(dir)

def run_cmd_with_capture(cmd):
    if args.verbose:  # Check if the verbose flag is set
        print_message(f'[COMMAND] '+cmd)
    # default value for results so return value is not None
    results = subprocess.run("echo ", stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    if(args.cmd == False):
        results = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    return results


def ensure_inst_mem_for_test(test):
    """Compile SW when inst_mem.sv is missing (e.g. -hw -sim without -app)."""
    if test.fail_flag or args.cmd:
        return
    inst_mem = TARGET + 'tests/' + test.name + '/gcc_files/inst_mem.sv'
    if not os.path.isfile(inst_mem):
        print_message('[INFO] gcc_files/inst_mem.sv missing; compiling SW for this test.')
        test._compile_sw()


#####################################################################################################
#                                           main
#####################################################################################################       
def main():
    chdir(MODEL_ROOT)
    if not os.path.exists(VERIF):
        print_message(f'[ERROR] There is no dut \'{args.dut}\'')
        exit(1)
    # if args.clean  clean target/dut/tests/ directory before starting running the build script
    if args.clean:
        print_message('[INFO] Cleaning target/'+args.dut+'/tests/ directory')
        if os.path.exists('target/'+args.dut+'/tests/'):
            rm_target_cmd  = 'rm -rf target/'+args.dut+'/tests/'
            run_cmd(rm_target_cmd)
            #shutil.rmtree('target/'+args.dut+'/tests/')
        else:
            print_message('[INFO] nothing to clean - target/'+args.dut+'/tests/ directory does not exist')
    
    # create target/dut/tests/ directory if not exists
    if not os.path.exists('target/'+args.dut+'/tests/'):
        mkdir('target/'+args.dut+'/tests/')
    # log_file = "target/big_core/build_log.txt"
    
    # the tests list declared - will be filled using one of the arguments: all, regress, tests
    tests = []
    run_status = "PASSED" # default value for run status

    # make sure not using '-all', '-regress', 'tests' together
    if (args.all and args.regress) or (args.all and args.tests) or (args.regress and args.tests):
        print_message('[ERROR] can\'t use any combination of: -all, -regress, tests')
        exit(1)

    # Check if the '-app' flag is used without any of '-all', '-regress', or '-tests'
    if args.app and not (args.all or args.regress or args.tests):
        print_message('[ERROR] When using -app, must use at least one of: -all, -regress, or -tests')
        exit(1)
    
    # if there is no '-tests' argument, add a default test using the dut name "default_<dut>_test"
    if not args.tests:
        args.tests = 'default_'+args.dut+'_test'



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
            # if 'level' in test: continue
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
        for test_name in args.tests.split():
            if test_name == 'default_'+args.dut+'_test':
                print_message('[INFO] No specific test requested, using default null_test.')
                # Assuming your Test class can handle a 'null_test' in a meaningful way
                # You might need to adjust the Test class or provide specific handling here
                default_test = Test('test_name', parameter, args.dut)
                tests.append(default_test)
            else:
                try:
                    test_path = glob.glob(TESTS + test_name + '*')[0]
                except IndexError:  # No matching test file found
                    print_message(f'[ERROR] There is no test {test_name} in your tests directory')
                    exit(1)
                else:
                    test_file = test_path.replace('\\', '/').split('/')[-1]
                    tests.append(Test(test_file, parameter, args.dut))


    # Redirect stdout and stderr to log file
    # sys.stdout = open(log_file, "w", buffering=1)
    # sys.stderr = open(log_file, "w", buffering=1)   

    for test in tests:
        start_test_time = time.time()

        # check out the output has an directory with the test name and the *_transcript file, if so, copy the dir with a suffix _1, _2, etc.
        if os.path.exists('target/'+args.dut+'/tests/'+test.name):
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
                ensure_inst_mem_for_test(test)
                if not test.fail_flag:
                    test._start_simulation()
            if (args.fpga) and not test.fail_flag:
                if not test.app_flag:
                    test._compile_sw()
                if not test.mif_flag:
                    test._start_mif()
                test._start_fpga()
            if (args.reload) and not test.fail_flag:
                if not test.app_flag:
                    test._compile_sw()
                test._reload_fpga()
            if (args.prog) and not test.fail_flag:
                test._program_fpga()
            if (args.mif):
                if not test.app_flag:
                    test._compile_sw()
                test._start_mif()
            if (args.gui):
                ensure_inst_mem_for_test(test)
                if not test.fail_flag:
                    test._gui()
            if (args.pp) and not test.fail_flag:
                # print that we are running the post process
                if (test._post_process()):# if return value is 0, then the post process is done successfully
                    print_message(f'[ERROR] Failed post process run on test {test.name}')
                    test.fail_flag = True
                print_message('--------------------------------------------')
            if args.no_debug:
                test._no_debug()

            # print the test execution time
            end_test_time = time.time()
            test.duration = end_test_time - start_test_time
            print_message(f"[INFO] Test execution took {test.duration:.2f} seconds.")

            print_message(f'************************** End {test.name} **********************************')
            if(test.fail_flag):
                run_status = "FAILED"
    # sys.stdout.flush()
    # sys.stderr.flush()


#===================================================================================================
#       EOT - End Of Test section
#===================================================================================================
    print_message('\n=================================================================================')
    print_message('[INFO] ====================== Tests Final Status: ===============================')
    for test in tests:
        if(test.fail_flag==True):
            print_message(f'[ERROR] Test failed - {test.name} - target/{args.dut}/tests/{test.name}/ , execution time: {test.duration:.2f} seconds.')
        if(test.fail_flag==False):
            print_message(f'[INFO] Test Passed - {test.name} - target/{args.dut}/tests/{test.name}/ , execution time: {test.duration:.2f} seconds.')

    print_message('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^')
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
    print_message('=================================================================================')
    print_message('\n')

    sys.exit(exit_status)