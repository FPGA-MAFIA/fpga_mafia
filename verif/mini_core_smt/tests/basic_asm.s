     .text
     .globl     main
     .type     main, @function
main:
  li    x1,  1
  li    x1,  10
  li    x2,  2
  li    x2,  20
  li    x3,  3
  li    x3,  30
  li    x4,  4
  li    x4,  40
  li    x5,  5
  li    x5,  50
  li    x6,  6
  li    x6,  60
  li    x7,  7
  li    x7,  70
  li    x8,  8
  li    x8,  80

 sw   x3, 0(x11)
 sw   x7, 0(x6)
 lw   x12, 0(x11)
 lw   x13, 0(x6)
 addi x5, x1, 0x7       # x5 = x1 + x3 (1 + 3 = 4)
 sub x5, x2, x1       # x5 = 10
 add x6, x2, x4       # x6 = x4 + x2 (4 + 2 = 6)
 add x6, x2, x4       # x6 = x4 + x2 (40 + 20 = 60)

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
