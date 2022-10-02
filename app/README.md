
// replace alive with my_file_name.c 
rv_gcc -S -ffreestanding -march=rv32i alive.c -o alive_rv32i.c.s
rv_gcc -O3 -march=rv32i -T./link.common.ld -nostartfiles -D__riscv__ crt0.S alive_rv32i.c.s -o alive_rv32i.elf
rv_objdump -gd alive_rv32i.elf > alive_rv32i_elf.txt
rv_objcopy --srec-len 1 --output-target=verilog alive_rv32i.elf inst_mem.sv



// This is an example for the 4th session
rv_gcc -O3 -march=rv32i -T./link.common.ld -ffreestanding -nostartfiles -D__riscv__ asm/basic_commands.s -o alive_rv32i.elf
rv_objdump -gd alive_rv32i.elf > alive_rv32i_elf.txt
rv_objcopy --srec-len 1 --output-target=verilog alive_rv32i.elf inst_mem.sv
