#ifndef BIG_CORE_DEFINES_H  // Check if GRAPHIC_VGA_H is not defined
#define BIG_CORE_DEFINES_H  // Define GRAPHIC_VGA_H



#define D_MEM_BASE      0x00010000
#define SCRATCH_OFFSET  0x0001F000
#define D_MEM_SCRATCH ((volatile int *) (SCRATCH_OFFSET))
#define CR_MEM_BASE     0x00FE0000
#define VGA_MEM_BASE    0x00FF0000


//=============================================================================
// Offset: 0x0000_0000   |  Instruction Memory - 64KB :
//                       |    Also known as the "text" memory.
//                       |  
// Offset: 0x0000_FFFF   |  
//-----------------------------------------------------------------------------
// Offset: 0x0001_0000   |  Data Memory - 64KB :    .data   -> Initialized data
//                       |                          .bss    -> Uninitialized data
//                       |                          .heap   -> grows upwards (towards stack)
// Offset: 0x0001_EFFF   |                          .stack  -> grows downwards (towards heap)
//-----------------------------------------------------------------------------
// Offset: 0x0001_F000   |  Scratch Pad - 4KB :
//                       |  This section is used as a scratch pad memory
//                       |  Preparatory programs can use this memory to store results or accept input.
// Offset: 0x0001_FFFF   |  
//-----------------------------------------------------------------------------
// Offset: 0x0002_0000   |  Reserved - 16MB :  (Mega Bytes!!!!)
//                       |  This memory is reserved for future use 
//                       |  where we will utilize the FPGA off-die memory.
// Offset: 0x00FD_FFFF   |  Up to 64MB on the DE10-lite FPGA board. (TODO - see if we reserve 64MB instead of 16MB)
//-----------------------------------------------------------------------------
// Offset: 0x00FE_0000   |  CR Memory - 64KB :
//                       |  This memory is used as MMIO control registers
//                       |  TODO - there are only handful of registers defined here.
// Offset: 0x00FE_FFFF   |  should be moved to a different memory section.
//-----------------------------------------------------------------------------
// Offset: 0x00FF_0000   |  VGA Memory - 38,400 Bytes : (38KB)
//                       |  This matches the VGA resolution of 640x480=307,200 pixels. 
//                       |  Monochrome mode - 1 bit per pixel -> 38,400 bytes
// Offset: 0x00FF_95FF   |  TODO Future - RGB mode - Byte per pixel utilizing the same 38KB-> (3,3,2 -> RGB)
//                       |  it is tricky to keep correct aspic ratio & have memory utilization of 38KB.
//                       |  simple solution is to under utilize the memory and have a 160x120 resolution. (160x120=19,200 pixels->bytes)
//-----------------------------------------------------------------------------









#define WRITE_REG(REG,VAL) (*REG) = VAL
#define READ_REG(VAL,REG)  VAL    = (*REG)
#define MEM_SCRATCH_PAD    ((volatile int *) (D_MEM_BASE))

/* Control registers addresses */
#define CR_SEG7_0      ((volatile int *) (CR_MEM_BASE + 0x0))
#define CR_SEG7_1      ((volatile int *) (CR_MEM_BASE + 0x4))
#define CR_SEG7_2      ((volatile int *) (CR_MEM_BASE + 0x8))
#define CR_SEG7_3      ((volatile int *) (CR_MEM_BASE + 0xc))
#define CR_SEG7_4      ((volatile int *) (CR_MEM_BASE + 0x10))
#define CR_SEG7_5      ((volatile int *) (CR_MEM_BASE + 0x14))
#define CR_LED         ((volatile int *) (CR_MEM_BASE + 0x18))
#define CR_Button_0    ((volatile int *) (CR_MEM_BASE + 0x1c))
#define CR_Button_1    ((volatile int *) (CR_MEM_BASE + 0x20))
#define CR_SWITCH      ((volatile int *) (CR_MEM_BASE + 0x24))
#define CR_JOYSTICK_X  ((volatile int *) (CR_MEM_BASE + 0x28))
#define CR_JOYSTICK_Y  ((volatile int *) (CR_MEM_BASE + 0x2C))
#define CR_VGA_COUNTER_X ((volatile int *) (CR_MEM_BASE + 0x50))
#define CR_VGA_COUNTER_Y ((volatile int *) (CR_MEM_BASE + 0x54))
#define CR_KBD_DATA    ((volatile int *) (CR_MEM_BASE + 0x100))
#define CR_KBD_READY   ((volatile int *) (CR_MEM_BASE + 0x104))
#define CR_KBD_SCANF_EN ((volatile int *) (CR_MEM_BASE + 0x108))





int hex7seg(int number){
    int hex7seg;
    switch (number){
        case 0: hex7seg = 0b11000000; break;
        case 1: hex7seg = 0b11111001; break;
        case 2: hex7seg = 0b10100100; break;
        case 3: hex7seg = 0b10110000; break;
        case 4: hex7seg = 0b10011001; break;
        case 5: hex7seg = 0b10010010; break;
        case 6: hex7seg = 0b10000010; break;
        case 7: hex7seg = 0b11111000; break;
        case 8: hex7seg = 0b10000000; break;
        case 9: hex7seg = 0b10010000; break;
        case 10: hex7seg = 0b10001000; break;
        case 11: hex7seg = 0b10000011; break;
        case 12: hex7seg = 0b11000110; break;
        case 13: hex7seg = 0b10100001; break;
        case 14: hex7seg = 0b10000110; break;
        default: hex7seg = 0b10000000; break;
    }
    return hex7seg;
}

void fpga_7seg_print(int number){
    WRITE_REG(CR_SEG7_0, hex7seg(number%10));
    WRITE_REG(CR_SEG7_1, hex7seg((number/10)%10));
    WRITE_REG(CR_SEG7_2, hex7seg((number/100)%10));
    WRITE_REG(CR_SEG7_3, hex7seg((number/1000)%10));
    WRITE_REG(CR_SEG7_4, hex7seg((number/10000)%10));
    WRITE_REG(CR_SEG7_5, hex7seg((number/100000)%10));
}

#endif /* BIG_CORE_DEFINES_H */