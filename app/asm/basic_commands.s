clear:
    nop
    nop
    nop
    nop
    addi x1, x0, 0  
    addi x2, x0, 0  
    addi x3, x0, 0  
    addi x4, x0, 0  
    addi x5, x0, 0  
    addi x6, x0, 0  
    addi x7, x0, 0  
    addi x8, x0, 0  
    addi x9, x0, 0  
    addi x10, x0, 0  
    addi x11, x0, 0  
    addi x12, x0, 0  
    addi x13, x0, 0  
    addi x14, x0, 0  
    addi x15, x0, 0  
    addi x16, x0, 0  
    addi x17, x0, 0  
    addi x18, x0, 0  
    addi x19, x0, 0  
    addi x20, x0, 0  
    addi x21, x0, 0  
    addi x22, x0, 0  
    addi x23, x0, 0  
    addi x24, x0, 0  
    addi x25, x0, 0  
    addi x26, x0, 0  
    addi x27, x0, 0  
    addi x28, x0, 0  
    addi x29, x0, 0  
    addi x30, x0, 0  
    addi x31, x0, 0  
main:
  li    x1,  1
  li    x2,  2
  li    x3,  3
  li    x4,  4
  li    x5,  5
  li    x6,  6
  li    x7,  7
  li    x8,  8
  slt   x9,  x2, x1 # x1>x2         -> 0
  sltu  x10, x1, x2 # x2>x1         -> 1
  srl   x11, x4, x1 # x4>>x1        -> 2
  and   x12, x3, x7 # 011 & 111     -> 3 (3'b011)
  sll   x13, x2, x1 # x2<<x1        -> 4
  add   x14, x1, x4 # x1+x4         -> 5
  xor   x15, x3, x5 # 011 ^ 101     -> 6 (3'b110)
  or    x16, x1, x6 # 001 | 110     -> 7 (3'b111)
store_to_memory:
    li   x31 , 0x1000       #D_MEM offset
    sw   x1  , 0x0(x31)
    sw   x2  , 0x4(x31)
    sw   x3  , 0x8(x31)
    sw   x4  , 0xc(x31)
    sw   x5  , 0x10(x31)
    sw   x6  , 0x14(x31)
    sw   x7  , 0x18(x31)
    sw   x8  , 0x1c(x31)
    sw   x9  , 0x20(x31)
    sw   x10 , 0x24(x31)
    sw   x11 , 0x28(x31)
    sw   x12 , 0x2c(x31)
    sw   x13 , 0x30(x31)
    sw   x14 , 0x34(x31)
    sw   x15 , 0x38(x31)
    sw   x16 , 0x3c(x31)
load_from_memory:
    lw   x17 , 0x20(x31)
    lw   x18 , 0x24(x31)
    lw   x19 , 0x28(x31)
    lw   x20 , 0x2c(x31)
    lw   x21 , 0x30(x31)
    lw   x22 , 0x34(x31)
    lw   x23 , 0x38(x31)
    lw   x24 , 0x3c(x31)
eot:
    nop
    nop
    nop
    nop
    ebreak
    nop
    nop
    nop
