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
// Ends:   0x00FE_FFFF   |  should be moved to a different memory section
//-----------------------------------------------------------------------------

/* Control registers addressed */
//FIXME refactor to be more compact

//=====================================
//   define CR's for INT8 multiplier
//=====================================
#define CR_CORE2MUL_INT8_MULTIPLICAND_0     ((volatile int *) (CR_MEM_BASE + 0xF000))
#define CR_CORE2MUL_INT8_MULTIPLIER_0       ((volatile int *) (CR_MEM_BASE + 0xF001))
#define CR_CORE2MUL_INT8_MULTIPLICAND_1     ((volatile int *) (CR_MEM_BASE + 0xF002))
#define CR_CORE2MUL_INT8_MULTIPLIER_1       ((volatile int *) (CR_MEM_BASE + 0xF003))
#define CR_CORE2MUL_INT8_MULTIPLICAND_2     ((volatile int *) (CR_MEM_BASE + 0xF004))
#define CR_CORE2MUL_INT8_MULTIPLIER_2       ((volatile int *) (CR_MEM_BASE + 0xF005))
#define CR_CORE2MUL_INT8_MULTIPLICAND_3     ((volatile int *) (CR_MEM_BASE + 0xF006))
#define CR_CORE2MUL_INT8_MULTIPLIER_3       ((volatile int *) (CR_MEM_BASE + 0xF007))
#define CR_CORE2MUL_INT8_MULTIPLICAND_4     ((volatile int *) (CR_MEM_BASE + 0xF008))
#define CR_CORE2MUL_INT8_MULTIPLIER_4       ((volatile int *) (CR_MEM_BASE + 0xF009))
#define CR_CORE2MUL_INT8_MULTIPLICAND_5     ((volatile int *) (CR_MEM_BASE + 0xF00A))
#define CR_CORE2MUL_INT8_MULTIPLIER_5       ((volatile int *) (CR_MEM_BASE + 0xF00B))
#define CR_CORE2MUL_INT8_MULTIPLICAND_6     ((volatile int *) (CR_MEM_BASE + 0xF00C))
#define CR_CORE2MUL_INT8_MULTIPLIER_6       ((volatile int *) (CR_MEM_BASE + 0xF00D))
#define CR_CORE2MUL_INT8_MULTIPLICAND_7     ((volatile int *) (CR_MEM_BASE + 0xF00E))
#define CR_CORE2MUL_INT8_MULTIPLIER_7       ((volatile int *) (CR_MEM_BASE + 0xF00F))
#define CR_CORE2MUL_INT8_MULTIPLICAND_8     ((volatile int *) (CR_MEM_BASE + 0xF010))
#define CR_CORE2MUL_INT8_MULTIPLIER_8       ((volatile int *) (CR_MEM_BASE + 0xF011))
#define CR_CORE2MUL_INT8_MULTIPLICAND_9     ((volatile int *) (CR_MEM_BASE + 0xF012))
#define CR_CORE2MUL_INT8_MULTIPLIER_9       ((volatile int *) (CR_MEM_BASE + 0xF013))
#define CR_CORE2MUL_INT8_MULTIPLICAND_10    ((volatile int *) (CR_MEM_BASE + 0xF014))
#define CR_CORE2MUL_INT8_MULTIPLIER_10      ((volatile int *) (CR_MEM_BASE + 0xF015))
#define CR_CORE2MUL_INT8_MULTIPLICAND_11    ((volatile int *) (CR_MEM_BASE + 0xF016))
#define CR_CORE2MUL_INT8_MULTIPLIER_11      ((volatile int *) (CR_MEM_BASE + 0xF017))
#define CR_CORE2MUL_INT8_MULTIPLICAND_12    ((volatile int *) (CR_MEM_BASE + 0xF018))
#define CR_CORE2MUL_INT8_MULTIPLIER_12      ((volatile int *) (CR_MEM_BASE + 0xF019))
#define CR_CORE2MUL_INT8_MULTIPLICAND_13    ((volatile int *) (CR_MEM_BASE + 0xF01A))
#define CR_CORE2MUL_INT8_MULTIPLIER_13      ((volatile int *) (CR_MEM_BASE + 0xF01B))
#define CR_CORE2MUL_INT8_MULTIPLICAND_14    ((volatile int *) (CR_MEM_BASE + 0xF01C))
#define CR_CORE2MUL_INT8_MULTIPLIER_14      ((volatile int *) (CR_MEM_BASE + 0xF01D))
#define CR_CORE2MUL_INT8_MULTIPLICAND_15    ((volatile int *) (CR_MEM_BASE + 0xF01E))
#define CR_CORE2MUL_INT8_MULTIPLIER_15      ((volatile int *) (CR_MEM_BASE + 0xF01F))



#define CR_MUL2CORE_INT8_0          ((volatile int *) (CR_MEM_BASE + 0xF050))
#define CR_MUL2CORE_INT8_DONE_0     ((volatile int *) (CR_MEM_BASE + 0xF051))
#define CR_MUL2CORE_INT8_1          ((volatile int *) (CR_MEM_BASE + 0xF052))
#define CR_MUL2CORE_INT8_DONE_1     ((volatile int *) (CR_MEM_BASE + 0xF053))
#define CR_MUL2CORE_INT8_2          ((volatile int *) (CR_MEM_BASE + 0xF054))
#define CR_MUL2CORE_INT8_DONE_2     ((volatile int *) (CR_MEM_BASE + 0xF055))
#define CR_MUL2CORE_INT8_3          ((volatile int *) (CR_MEM_BASE + 0xF056))
#define CR_MUL2CORE_INT8_DONE_3     ((volatile int *) (CR_MEM_BASE + 0xF057))
#define CR_MUL2CORE_INT8_4          ((volatile int *) (CR_MEM_BASE + 0xF058))
#define CR_MUL2CORE_INT8_DONE_4     ((volatile int *) (CR_MEM_BASE + 0xF059))
#define CR_MUL2CORE_INT8_5          ((volatile int *) (CR_MEM_BASE + 0xF05A))
#define CR_MUL2CORE_INT8_DONE_5     ((volatile int *) (CR_MEM_BASE + 0xF05B))
#define CR_MUL2CORE_INT8_6          ((volatile int *) (CR_MEM_BASE + 0xF05C))
#define CR_MUL2CORE_INT8_DONE_6     ((volatile int *) (CR_MEM_BASE + 0xF05D))
#define CR_MUL2CORE_INT8_7          ((volatile int *) (CR_MEM_BASE + 0xF05E))
#define CR_MUL2CORE_INT8_DONE_7     ((volatile int *) (CR_MEM_BASE + 0xF05F))
#define CR_MUL2CORE_INT8_8          ((volatile int *) (CR_MEM_BASE + 0xF060))
#define CR_MUL2CORE_INT8_DONE_8     ((volatile int *) (CR_MEM_BASE + 0xF061))
#define CR_MUL2CORE_INT8_9          ((volatile int *) (CR_MEM_BASE + 0xF062))
#define CR_MUL2CORE_INT8_DONE_9     ((volatile int *) (CR_MEM_BASE + 0xF063))
#define CR_MUL2CORE_INT8_10         ((volatile int *) (CR_MEM_BASE + 0xF064))
#define CR_MUL2CORE_INT8_DONE_10    ((volatile int *) (CR_MEM_BASE + 0xF065))
#define CR_MUL2CORE_INT8_11         ((volatile int *) (CR_MEM_BASE + 0xF066))
#define CR_MUL2CORE_INT8_DONE_11    ((volatile int *) (CR_MEM_BASE + 0xF067))
#define CR_MUL2CORE_INT8_12         ((volatile int *) (CR_MEM_BASE + 0xF068))
#define CR_MUL2CORE_INT8_DONE_12    ((volatile int *) (CR_MEM_BASE + 0xF069))
#define CR_MUL2CORE_INT8_13         ((volatile int *) (CR_MEM_BASE + 0xF06A))
#define CR_MUL2CORE_INT8_DONE_13    ((volatile int *) (CR_MEM_BASE + 0xF06B))
#define CR_MUL2CORE_INT8_14         ((volatile int *) (CR_MEM_BASE + 0xF06C))
#define CR_MUL2CORE_INT8_DONE_14    ((volatile int *) (CR_MEM_BASE + 0xF06D))
#define CR_MUL2CORE_INT8_15         ((volatile int *) (CR_MEM_BASE + 0xF06E))
#define CR_MUL2CORE_INT8_DONE_15    ((volatile int *) (CR_MEM_BASE + 0xF06F))


//==================================
//  define CR's for neuron_mac
//==================================
#define NEURON_MAC_BIAS0           ((volatile int *) (CR_MEM_BASE + 0xF100))
#define NEURON_MAC_BIAS1           ((volatile int *) (CR_MEM_BASE + 0xF101))
#define NEURON_MAC_RESULT0         ((volatile int *) (CR_MEM_BASE + 0xF102))
#define NEURON_MAC_RESULT1         ((volatile int *) (CR_MEM_BASE + 0xF103))


//==================================
//  define CR's for systolic array
//==================================
#define SYSTOLIC_ARRAY_WEIGHTS    = ((volatile int *) (CR_MEM_BASE + 0xF200));
#define SYSTOLIC_ARRAY_ACTIVE     = ((volatile int *) (CR_MEM_BASE + 0xF201));
#define SYSTOLIC_ARRAY_START      = ((volatile int *) (CR_MEM_BASE + 0xF202));
#define SYSTOLIC_ARRAY_VALID      = ((volatile int *) (CR_MEM_BASE + 0xF203));

// used for debug purposes
#define CR_DEBUG_0 ((volatile int *) (CR_MEM_BASE + 0xFF00))
#define CR_DEBUG_1 ((volatile int *) (CR_MEM_BASE + 0xFF01))
#define CR_DEBUG_2 ((volatile int *) (CR_MEM_BASE + 0xFF02))
#define CR_DEBUG_3 ((volatile int *) (CR_MEM_BASE + 0xFF03))

#endif