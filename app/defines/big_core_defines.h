#define SCRATCH_OFFSET   0x0001F000
#define D_MEM_SCRATCH ((volatile int *) (SCRATCH_OFFSET))

#define D_MEM_BASE   0x00010000
#define CR_MEM_BASE  0x00100000
#define VGA_MEM_BASE 0x00200000

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