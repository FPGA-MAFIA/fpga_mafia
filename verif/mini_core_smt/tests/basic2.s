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

 add x5, x1, x3       # x9 = x1 + x2 (1 + 2 = 3)
 add x6, x2, x4       # x9 = x1 + x2 (1 + 2 = 3)

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
