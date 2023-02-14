This Directory contain the implementation of our big core.

This big core will based on the previous risc-v project call "RVC_ASAP".

The main purpose of the big core is being a controller for our SOC - 
 #) supports ISA extensions for RV (handling interrupts, nondeterministic RD/WR, etc)
 #) Communicating with the OS (hopefully) 
 #) Sending tasks for the fabric's cores, and manage the return data. 
 #) Dealing with the I/O of the system (keyboard, screen, etc).
 #) Managing the memory allocation for the whole devices (by the OS)

[Optional] this core will be the executing arms of the operating systems. it will execute the current process, calculating the next process that should be run on, and dealing with interrupts that should occur.
for this purpose this, core will support the extenuation ISA for OS.
