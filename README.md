# The Many Core Project
This project aims to design a SOC (System-on-a-Chip) Tile based mesh fabric that can incorporate various functionalities, such as RISCV mini-cores, big-cores, hardware accelerators, and IO devices like UART, keyboard, VGA, DE10-Lite FPGA IO, and more.


## Getting Started
To see your build and run options, run the following command:
```python build.py -h ```  

## Prerequisite
Before you start, make sure you have the following tools and software installed:
- [RISCV gcc releases](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/) & [install](https://xpack.github.io/riscv-none-embed-gcc/install/), a Windows gcc for RISCV ISA.  
- [Intel design SW for windows](https://www.intel.com/content/www/us/en/software-kit/660907/intel-quartus-prime-lite-edition-design-software-version-20-1-1-for-windows.html) , modelsim + quartus + MAX10 (de10-lite). used to compile, simulate & load to FPGA the HW systemverilog design.  
### Recommendations
To make your experience smoother, we recommend installing the following tools:
- [GitBash](https://gitforwindows.org/), a Windows version of Git that includes a Unix shell.  
- [Visual Studio Code](https://code.visualstudio.com/download), a code editor that supports many programming languages.  


# Project overview
The diagram below provides a general idea of the project's architecture.  
![image](https://user-images.githubusercontent.com/81047407/216783815-4cb35990-2092-4b19-8a76-f564cca77023.png)


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
