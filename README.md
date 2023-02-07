# The Many Core Project
This project aims to design a SOC Tile based mesh fabric that can incorporate various functionalities, such as RISCV mini-cores, big-cores, hardware accelerators, and IO devices like UART, keyboard, VGA, DE10-Lite FPGA IO, and more.


## Getting Started
To see your build and run options, run the following command:  
```python build.py -h ```  

## Prerequisite
Before you start, make sure you have the following tools and software installed:
- [RISCV gcc releases](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/) & [install](https://xpack.github.io/riscv-none-embed-gcc/install/), a Windows gcc for RISCV ISA.  
- [Intel design SW for windows](https://www.intel.com/content/www/us/en/software-kit/660907/intel-quartus-prime-lite-edition-design-software-version-20-1-1-for-windows.html) , modelsim + quartus + MAX10 (de10-lite). used to compile, simulate & load to FPGA the HW systemverilog design.  
### Recommendations
To make your experience smoother, we recommend installing the following tools:
- [GitBash](https://gitforwindows.org/), a Windows version of Git that includes a "Unix-like" shell.  
- [Visual Studio Code](https://code.visualstudio.com/download), a code editor that supports many programming languages.  


# Project overview
This project is part of the final project for 4th year Electrical Engineering and Computer Engineering students at Bar-Ilan University and the Technion in Israel.   
The project contributors will be individually graded based on their contribution to the Many-Core project.  
  
The goal of this project is to design a System-on-a-Chip (SOC) tile-based mesh fabric that integrates various functionalities, such as RISCV mini-cores, big-cores, hardware accelerators, and I/O devices such as UART, keyboard, VGA, DE10-Lite FPGA I/O, and more.

The main components of the project include:  
- The Router: A 4-way router that connects the mesh tiles.  
- The Mini Core: A 3-stage RISCV RV32I compatible core.  
- The Big Core: A 7-stage RISCVRV32IM CSR compatible core with MMIO for VGA, keyboard, UART, LED, 7SEG, buttons, switches, Arduino digital and analog I/O.  
- The Memory Subsystem: L1 Instruction and Data Cache and a Memory Controller (MC).  
  
In addition to the hardware design, the project also includes a software stack necessary to run applications on the fabric, including:  
- A software library for VGA graphical capabilities, such as `draw_line()`, `draw_circle()`, `print_char()`, and `printf()`.  
- A software library for accessing the FPGA MMIO and special control registers of the SOC and cores.  
- Software examples demonstrating the utilization of the many cores for distributed calculations and parallel computation.  
  
The diagram below provides a general idea of the project's architecture.   
![image](https://user-images.githubusercontent.com/81047407/217345069-21aef258-084b-44b3-b776-e9740aad8e88.png)


## Common Issues:

``` ModuleNotFoundError: No module named 'termcolor' ```  
  To resolve this issue, run the following command:  
> pip install termcolor


``` 'riscv-none-embed-gcc.exe' is not recognized as an internal or external command ```  
To resolve this issue, make sure the following line is added to your `~/.bashrc` file:  
> export PATH=$PATH:/c/Users/amich/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin   
Then run ``` source ~/.bashrc ```   


Additionally, make sure the following aliases are present in your `~/.aliases` file:
> alias rv_gcc='/c/Users/amich/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin/riscv-none-embed-gcc.exe'  
> alias rv_objcopy='/c/Users/amich/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin/riscv-none-embed-objcopy.exe'  
> alias rv_objdump='/c/Users/amich/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin/riscv-none-embed-objdump.exe'    

Then run ``` source ~/.aliases ```    
