     .text
     .globl     main
     .type     main, @function
main:
  li    x3,  1   
  li    x4,  2
  li    x5,  3
  li    x6,  4
  li    x7,  5
  li    x8,  6
  li    x9,  7

 add x9, x3, x4
 sub x10, x3, x4
 and x11, x5, x6
 or x12, x7, x8
 xor x13, x8, x9


eot:
    nop
    nop
    nop
    nop
    nop
    ebreak
    nop
    nop
    nop
     .size     main, .-main
     .ident     "GCC: (xPack GNU RISC-V Embedded GCC x86_64) 10.2.0"
     