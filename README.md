[![mafia_sanity](https://github.com/amichai-bd/fpga_mafia/actions/workflows/mafia_sanity.yml/badge.svg)](https://github.com/amichai-bd/fpga_mafia/actions/workflows/mafia_sanity.yml)

## Current Development Status:
This project is currently a work in progress (WIP). We are in the process of enabling and integrating individual Intellectual Properties (IPs).  
Our team is working diligently to deliver a fully functional fabric by August 1, 2023.  
Stay tuned for updates and feel free to contribute!  

# FPGA Multi-Agent FabrIc Architecture (MAFIA)
Welcome to the MAFIA Project, a revolutionary initiative aimed at designing a System-on-a-Chip (SoC) Tile-based mesh fabric.  
Our architecture is designed to be highly adaptable and versatile, capable of incorporating a variety of functionalities.  

This includes, but is not limited to:  
- RISCV mini-cores and big-cores
- Hardware accelerators
- IO devices such as UART, keyboard, VGA, and DE10-Lite FPGA IO

By integrating these functionalities, we aim to create a robust, efficient, and flexible computing platform.   
We invite you to join us in this exciting venture!  

# Project Overview
The MAFIA Project is the culmination of rigorous study and development by final year Electrical Engineering and Computer Engineering students at Bar-Ilan University and the Technion in Israel. Our overarching goal is to design a System-on-a-Chip (SoC) tile-based mesh fabric capable of integrating a diverse range of IPs and functionalities.

## Technology Stack
- The project's RTL is written in SystemVerilog.
- We utilize the GNU GCC for the RISCV software stack, which includes linker, assembly, and C source files.
- Python is employed for build scripts, post-processing, GUI, and other utilities.

## Main Components:
Our architecture consists of the following key elements:
- A 4-way Router coupled with a local Endpoint.
- A 3-stage Mini Core that is RV32I compatible.
- A 7-stage Big Core, which is RV32IM CSR compatible and supports MMIO (VGA, UART, FPGA IO, PS2 Keyboard).
- A Memory Subsystem equipped with L1 Instruction and Data Cache, as well as a Memory Controller.

## Software Stack to run on SoC:
Our system runs on a simple RISCV embedded OS and includes:
- A software library for VGA graphical capabilities.
- A software library for accessing the FPGA MMIO and special control registers.
- Software examples demonstrating the utilization of many cores for distributed calculations and parallel computation.

The diagram below provides a visual representation of the project's hardware architecture.   
![image](https://user-images.githubusercontent.com/81047407/218485725-d4442e94-7129-48b9-92bb-8f2ce52a301c.png)


## Getting Started
For best exporence we recomended using a windows machin running vscode + gitbash.  
To see the build and run options, use the following command:
```python build.py -h ```  
For any issue please see here: [fpga_mafia/discussions](https://github.com/amichai-bd/fpga_mafia/discussions/101)  
Please add your question in the comment section of the discussion

## Prerequisite
Before you start, make sure you have the following tools and software installed:
- [RISCV gcc releases](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/) & [install](https://xpack.github.io/riscv-none-embed-gcc/install/), a Windows gcc for RISCV ISA.  
- [Intel design SW for windows](https://www.intel.com/content/www/us/en/software-kit/660907/intel-quartus-prime-lite-edition-design-software-version-20-1-1-for-windows.html) , modelsim + quartus + MAX10 (de10-lite). used to compile, simulate & load to FPGA the HW systemverilog design.  
### Recommendations
To make your experience smoother, we recommend installing the following tools:
- [GitBash](https://gitforwindows.org/), a Windows version of Git that includes a "Unix-like" shell.  
- [Visual Studio Code](https://code.visualstudio.com/download), a code editor that supports many programming languages.  

## Inspiration Behind the Project:  
This project draws inspiration from innovative players in the field of computing.  
These include:  
- [Tesla: DOJO](https://www.tesla.com/AI) | [Watch the video on Youtube](https://www.youtube.com/watch?v=DSw3IwsgNnc)  
- [Tenstorrent: Wormhole & more](https://tenstorrent.com/) | [Watch the video on Youtube](https://www.youtube.com/watch?v=32CRYenTcdw)  
- [Esperanto: ET-SoC-1](https://www.esperanto.ai/)  | [Watch the video on Youtube](https://www.youtube.com/watch?v=5foT3huJ_Gg)  
Similarly, this project offers a unique, highly-integratable mesh architecture that can support a wide range of agents, and execute parallel computing for distributed workflow.

## Troubleshooting Common Issues

### Issue: 'ModuleNotFoundError: No module named 'termcolor''
**Solution**: Run the following command to resolve this issue:  
> pip install termcolor


``` 'riscv-none-embed-gcc.exe' is not recognized as an internal or external command ```  
Solution: Add the following line to your ~/.bashrc file:  
> export PATH=$PATH:/c/Users/'user_name'/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin   
Then, reload the bashrc file with this command:  
> source ~/.bashrc  

``` 'quartus_map' is not recognized as an internal or external command, ```
Solution: Add the following line to your ~/.bashrc file:  
> export PATH=$PATH:/c/intelFPGA_lite/20.1/quartus/bin64/   
Then, reload the bashrc file with this command:  
> source ~/.bashrc    

### Quick Access Commands
For easy access, you can run the following commands in the GitBash shell for Windows:
./build.py -h  
./build.py -dut 'big_core' -debug -tests alive -app 
./build.py -dut 'sc_core' -debug -tests alive -full_run
