This directory will have the RTL source files of th single cycle core


# Manually create a SW test: (without Build)
mkdir target/sc_core/modelsim/work
cd target/sc_core/modelsim
riscv-none-embed-gcc.exe  -O3 -march=rv32i -T ../../../app/link.common.ld  -Wl,--defsym=I_MEM_OFFSET=0  -Wl,--defsym=I_MEM_LENGTH=8192  -Wl,--defsym=D_MEM_OFFSET=8192  -Wl,--defsym=D_MEM_LENGTH=8192 -nostartfiles -D__riscv__ ../../../verif/sc_core/tests/basic.s -o basic_rv32i.elf
riscv-none-embed-objdump.exe -gd basic_rv32i.elf > basic_rv32i_elf.txt
riscv-none-embed-objcopy.exe --srec-len 1 --output-target=verilog basic_rv32i.elf inst_mem.sv


# Manually running a HW test: (without Build)
mkdir  ../tests/basic/gcc_files
cp inst_mem.sv ../tests/basic/gcc_files/
vlog -lint -f ../../.././verif/sc_core/tb//sc_core_list.f
vsim work.sc_core_tb -c -do "run -all" "+STRING=basic"
