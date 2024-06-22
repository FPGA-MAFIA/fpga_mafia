     .text
     .globl     main
     .type     main, @function
main:
  li    x1,  0xffffffff
  li    x2,  0xaaaaaaaa

  li  x31, 65536
  sw   x1, 0(x31)
  lbu  x4, 0(x31)
  lb   x5, 0(x31)
  sw   x2, 4(x31)
  lbu  x6, 4(x31)
  lb   x7, 4(x31)
  lh  x8, 4(x31)

        
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
     