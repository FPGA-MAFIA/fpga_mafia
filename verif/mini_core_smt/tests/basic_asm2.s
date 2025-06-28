     .text
     .globl     main
     .type     main, @function
main:
  li    x1,  10
  li    x2,  20
  li    x3,  30
  li    x4,  40
  li    x5,  50
  li    x6,  60
  li    x7,  70
  li    x8,  80

 #sw   x7, 0(x14)
 #lw   x15, 0(x14)
 addi x1, x3, 0x7       # x5 = x1 + x3 (1 + 3 = 4)
 sub x5, x4, x2       # x5 = 10
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
