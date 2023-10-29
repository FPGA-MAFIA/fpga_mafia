     .text
     .globl     main
     .type     main, @function
main:
  li    x1,  0x12345678
  li    x2,  0x1ee23
  li    x3,  0x9abcdef0
  li    x4,  4
  li    x5,  5
  li    x6,  6
  li    x7,  7
  li    x8,  8
  # example store byte
  sb    x1, 2(x2)
  sb    x3, 4(x2)
  # example load byte
  lb    x9, 2(x2)
  lb    x10, 4(x2)
  lbu    x11, 4(x2)


eot:
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
     