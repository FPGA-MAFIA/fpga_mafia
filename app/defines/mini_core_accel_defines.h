#ifndef MINI_CORE_ACCEL_DEFINES_H
#define MINI_CORE_ACCEL_DEFINES_H

// For detailed address mapping please refer to `big_core_defines.h`
// We use the same memory mapping as the big core for consistent implementation
// but its not obligatory.
// For example: we are using the same ref model for all the cores and we dont want to change addresses of CR's in that core
// cause this will cause us to make changes in thr ref model.
    
#define D_MEM_BASE      0x00010000
#define CR_MEM_BASE     0x00FE0000

//=============================================================================
// Offset: 0x0000_0000   |  Instruction Memory - 64KB :
//                       |    Also known as the "text" memory.
//                       |  
// Ends:   0x0000_FFFF   |  
//-----------------------------------------------------------------------------
// Offset: 0x0001_0000   |  Data Memory - 64KB :    .data   -> Initialized data
//                       |                          .bss    -> Uninitialized data
//                       |                          .heap   -> grows upwards (towards stack)
// Ends:   0x0001_EFFF   |                          .stack  -> grows downwards (towards heap)
//-----------------------------------------------------------------------------
// Offset: 0x0002_0000   |  Reserved - 16MB :  (Mega Bytes!!!!)
//                       |  This memory is reserved for future use 
//                       |  where we will utilize the FPGA off-die memory.
// Ends:   0x00FD_FFFF   |  Up to 64MB on the DE10-lite FPGA board. (TODO - see if we reserve 64MB instead of 16MB)
//-----------------------------------------------------------------------------
// Offset: 0x00FE_0000   |  CR Memory - 64KB :
//                       |  This memory is used as MMIO control registers
//                       |  TODO - there are only handful of registers defined here.
// Ends:   0x00FE_FFFF   |  should be moved to a different memory section.
//-----------------------------------------------------------------------------

/* Control registers addressed */
#define CR_MUL_0      ((volatile int *) (CR_MEM_BASE + 0xF000))
#define CR_MUL_1      ((volatile int *) (CR_MEM_BASE + 0xF001))
#define CR_MUL_2      ((volatile int *) (CR_MEM_BASE + 0xF002))
#define CR_MUL_3      ((volatile int *) (CR_MEM_BASE + 0xF003))
#define CR_MUL_4      ((volatile int *) (CR_MEM_BASE + 0xF004))
#define CR_MUL_5      ((volatile int *) (CR_MEM_BASE + 0xF005))
#define CR_MUL_6      ((volatile int *) (CR_MEM_BASE + 0xF006))
#define CR_MUL_7      ((volatile int *) (CR_MEM_BASE + 0xF007))

#define CR_MUL_CTRL   ((volatile int *) (CR_MEM_BASE + 0xF008))





#endif