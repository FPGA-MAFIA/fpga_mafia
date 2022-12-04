# Welcome to RVC_ASAP tool-chain tutorial!! 
## (0) Download a text editor  
- vscode: https://code.visualstudio.com/download  
- add usefully extensions (vim, powershell, git-bash, Systemverilog, venus Terminal)  

## (1) Download gitbash for Windows  
https://gitforwindows.org/  
  
## (2) Set gitbash in the vscode  
- you may configure the ~/.bashrc & ~/.aliases with your preferences.
  
## (3) Download modelsim  - a system verilog compiler & simulator (lite free version)  
- https://www.intel.com/content/www/us/en/software-kit/660907/intel-quartus-prime-lite-edition-design-software-version-20-1-1-for-windows.html  
Download indevidual files: modelsim, quartus, "Intel MAX 10 Device Support".  
  - Note: after all three programs were downloaded, run the Quartus instullation which will automatecly install modelsim & MAX10.  

## (4) Download the RISCV ToolChain:  
- https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/ -> File name: "xpack-riscv-none-embed-gcc-10.1.0-1.1-win32-x64.zip")  
- https://xpack.github.io/riscv-none-embed-gcc/install/  -> follow "Manual install" (Only extract in correct location)  
  
## (5) Gitbash shell - Set aliases for the copmile & link commands: (add to:  "~/.aliases" or C:\Program Files\Git\etc\profile.d\aliases.sh)  
alias rv_gcc='/c/Users/amich/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin/riscv-none-embed-gcc.exe'  
alias rv_objcopy='/c/Users/amich/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin/riscv-none-embed-objcopy.exe'  
alias rv_objdump='/c/Users/amich/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin/riscv-none-embed-objdump.exe'  


## (6) Test the RISCV toolchain:  
### 1. Create a simple c program. - "alive.c"  
```
int main()  {  
    int x,y,z;  
    x = 2;  
    y = 3;  
    z = x+y;  
}  // main()
```
### 2. Create a simple linker - "link.common.ld"  
```
    MEMORY {  
        i_mem          : ORIGIN = 0x00000000 , LENGTH = 0x4000  
        global_data    : ORIGIN = 0x00004000 , LENGTH = 0x4000  
    }  
    SECTIONS {  
        .text : {  
        . = ALIGN(4);  
        *(.start);  
        *(.text);  
        . = ORIGIN(i_mem) + LENGTH(i_mem) - 1;  
        BYTE(0);  
    }  > i_mem  
        .data : {  
        . = ALIGN(4);  
        *(.rodata);  
        *(.sdata);  
        *(.sbss);  
        } > global_data  
        .bss : {} > global_data  
    }  
```  
### 3. Create a simple crt0 file - "crt0.S"  
```
_start:
  .global _start
  .org 0x00
  nop                       
  nop                       
  nop                       
  nop                       
  nop                       
reset_handler:
  mv  x1, x0
  mv  x2, x1
  mv  x3, x1
  mv  x4, x1
  mv  x5, x1
  mv  x6, x1
  mv  x7, x1
  mv  x8, x1
  mv  x9, x1
  mv x10, x1
  mv x11, x1
  mv x12, x1
  mv x13, x1
  mv x14, x1
  mv x15, x1
  mv x16, x1
  mv x17, x1
  mv x18, x1
  mv x19, x1
  mv x20, x1
  mv x21, x1
  mv x22, x1
  mv x23, x1
  mv x24, x1
  mv x25, x1
  mv x26, x1
  mv x27, x1
  mv x28, x1
  mv x29, x1
  mv x30, x1
  mv x31, x1
  /* stack initialization */
  li   x2, 0x8000
  jal x1, main  //jump to main
  ebreak        //end
  .section .text
```
### 4. Compile -> Link -> assembler -> machine code:  
create assembly file from c file  
link new ams file with gpc initializer and creates elf file  
creates readable elf file  
creates the instruction file   
>  rv_gcc -S -ffreestanding -march=rv32i `<file>`.c -o `<file>`_rv32i.c.s  
>  rv_gcc -O3 -march=rv32i -T./link.common.ld -nostartfiles -D__riscv__ crt0.S `<file>`_rv32i.c.s -o `<file>`_rv32i.elf  
>  rv_objdump -gd `<file>`_rv32i.elf > `<file>`_rv32i_elf.txt  
>  rv_objcopy --srec-len 1 --output-target=verilog `<file>`_rv32i.elf `<file>`_inst_mem_rv32i.sv  
#### Example:  
>  rv_gcc -S -ffreestanding -march=rv32i `alive`.c -o alive_rv32i.c.s  
>  rv_gcc -O3 -march=rv32i -T./link.common.ld -nostartfiles -D__riscv__ crt0.S `alive`_rv32i.c.s -o `alive`_rv32i.elf   
>  rv_objdump -gd `alive`_rv32i.elf > `alive`_rv32i_elf.txt    
>  rv_objcopy --srec-len 1 --output-target=verilog `alive`_rv32i.elf `alive`_inst_mem_rv32i.sv   
### 5. Run ls -l in shell to see all the generated toolchain files. 
>   ls -l

make sure you have the files:
- crt0.S  
- link.common.ld  
- alive.c  
- alive_rv32i.c.s  
- alive_rv32i.elf  
- alive_rv32i_elf.txt  
- alive_inst_mem_rv32i.sv  

## (7)	MODELSIM - systemverilog toolchain 
1. write a simple systemverilog module: `test.sv` 
    ```
    module test (
        input  logic in_0,
        input  logic in_1,
        output logic out
    );
    assign out = in_0 & in_1;
    endmodule
    ```  
1. write a simple systemverilog test bench module: `test_tb.sv`
    ```  
    module test_tb ();
    logic in_0;
    logic in_1;
    logic  out;
    initial begin : assign_input
        in_0 = 1'b0;
        in_1 = 1'b0; // 0&0
    #4 $display("out = in_0 & in_1:\n    > %b = %b & %b",out ,in_0, in_1);
    #4 in_1 = 1'b1; // 0&1
    #4 $display("out = in_0 & in_1:\n    > %b = %b & %b",out ,in_0, in_1);
    #4 in_0 = 1'b1; // 1&1
    #4 $display("out = in_0 & in_1:\n    > %b = %b & %b",out ,in_0, in_1);
    #4 $finish;
    end// initial
    test test_and (
        .in_0(in_0),
        .in_1(in_1),
        .out(out)
    );
    endmodule // test_tb
    ```  
1. List the files & include dirs for model: `test_list.f`
    ```
    test.sv
    test_tb.sv
    ```
1. Make directory called `"work"`
    > `mkdir work`
1. Compile systemverilog from `"dotf"` file list.
    > `vlog.exe -f test_list.f`
1. Elaboration & simulation  
    - Simulate the Design without gui:  
    > `vsim.exe work.test_tb -c -do 'run -all'`  
    - Simulate the Design with gui 
    > `vsim.exe -gui work.test_tb`   

1. Make sure you see the wave form of your code when running with `-gui`:
![image](https://user-images.githubusercontent.com/81047407/137597659-b4465e6f-3d8d-4fd6-867a-c63df68b89e7.png)


## (8) Now you have everything you need to start designing a RISCV core in systemverilog!!
Good place to start:
A single cycle RV32I core:
![image](https://user-images.githubusercontent.com/81047407/170105460-3ea25fe6-b71a-451c-a75f-c8f6696e6713.png)Good luck!  
Please contact me with any issue. `amichai-bd`
