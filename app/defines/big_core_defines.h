
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
#define CR_SEG7_0   (volatile int *) (CR_MEM_BASE + 0x0)
#define CR_SEG7_1   (volatile int *) (CR_MEM_BASE + 0x4)
#define CR_SEG7_2   (volatile int *) (CR_MEM_BASE + 0x8)
#define CR_SEG7_3   (volatile int *) (CR_MEM_BASE + 0xc)
#define CR_SEG7_4   (volatile int *) (CR_MEM_BASE + 0x10)
#define CR_SEG7_5   (volatile int *) (CR_MEM_BASE + 0x14)
#define CR_LED      (volatile int *) (CR_MEM_BASE + 0x18)
#define CR_Button_0 (volatile int *) (CR_MEM_BASE + 0x1c)
#define CR_Button_1 (volatile int *) (CR_MEM_BASE + 0x20)
#define CR_Switch   (volatile int *) (CR_MEM_BASE + 0x24)