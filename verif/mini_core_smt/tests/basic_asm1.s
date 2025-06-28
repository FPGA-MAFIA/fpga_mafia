     .text
     .globl     main
     .type     main, @function
main:
  li    x1,  1
  li    x2,  2
  li    x3,  3
  li    x4,  4
  li    x5,  5
  li    x6,  6
  li    x7,  7
  li    x8,  8

 #sw   x3, 0(x13)
 #lw   x12, 0(x13)
 addi x5, x1, 0x7       # x5 = x1 + x3 (1 + 3 = 4)
 sub x4, x3, x2       # x5 = 10
 #add x6, x2, x4       # x6 = x4 + x2 (4 + 2 = 6)

eot:
    nop
    nop
    nop
    ebreak
    nop
    nop
    nop
     .size     main, .-main
     .ident     "GCC: (xPack GNU RISC-V Embedded GCC x86_64) 10.2.0"
