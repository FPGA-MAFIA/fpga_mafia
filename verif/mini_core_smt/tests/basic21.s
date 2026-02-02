     .text
     .globl     main
     .type     main, @function
main:
  li    x9,  1
  li    x10,  2
  li    x11,  3
  li    x12,  4
  li    x13,  5
  li    x14,  6
  li    x15,  7
  li    x16,  8

 add x13, x9, x11       # x9 = x1 + x2 (1 + 2 = 3)
 add x14, x10, x12       # x9 = x1 + x2 (1 + 2 = 3)

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
