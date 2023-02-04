# The Many Core Project!!!
Designing a SOC Tile based mesh fabric.
Here is the general idea of the project

![image](https://user-images.githubusercontent.com/81047406/183295711-80f3fa18-a318-4523-8b5d-05764eb2fc40.png)



# riscv_manycore_mesh_fpga
Running Build:
> python build.py -h

Common Issus:
If you get this:
> ModuleNotFoundError: No module named 'termcolor'  

Run this:
> pip install termcolor

If you get this:
> ModuleNotFoundError: No module named 'colorama'   

Run this:  
> pip install colorama

If you get this:  
> 'riscv-none-embed-gcc.exe' is not recognized as an internal or external command  

Make sure you have this in your ~./bashrc  
> export PATH=$PATH:/c/Users/amich/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin


If the output has not color and you see this type of test:  
> ←[1m←[34m**  

try this:  
> pip install colorama   





intresting reference:
https://github.com/kura197/riscv-fpga/
