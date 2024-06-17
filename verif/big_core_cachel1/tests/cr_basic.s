     .text
     .globl     main
     .type     main, @function
main:
  li    x1,  0xaa   
  li    x2,  0xbb
  li    x3,  0xcc
  
  li  x31, 0x00FE0000  #CR region
  
  sw	x1, 0(x31)     # store to CR with zero offset CR_SEG7_0
  lw	x4, 0(x31)
  sw	x2, 4(x31)
  lw	x5, 4(x31)
  sw	x3, 8(x31)
  lw	x6, 8(x31)
 

     
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
     