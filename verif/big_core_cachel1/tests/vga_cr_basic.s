     .text
     .globl     main
     .type     main, @function
main:
  li    x1,  0xaa   
  li    x2,  0xbb
  li    x3,  0xcc
  
  li  x31, 0x00FE0000  #CR region
  li  x30, 0x00FF0000  #VGA region
  
  sw x1, 0(x31)
  sw x1, 0(x30)
  lw x4, 0(x31)
  lw x5, 0(x30)
  sw x2, 4(x31)
  sw x3, 4(x30)
  lw x6, 4(x30)
  lw x7, 4(x31)

     
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
     