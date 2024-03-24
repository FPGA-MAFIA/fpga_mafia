# ./build.py -dut mini_core_rrv -test data_hazard_check -app -hw -sim -clean

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

  # forward from Q102H to Q101H
  add   x9,  x1,  x2
  add   x10, x9,  x2

  add   x11,  x1,  x2
  add   x12, x9,  x11


  # forward from Q102H to Q101H
  add   x3,  x1,  x2
  nop
  add   x10, x3,  x2

  add   x4,  x1,  x2
  nop
  add   x10, x3,  x4

  add   x12,  x1,  x2
  addi  x13,  x12,  0x100


   # no hazards
  li  x31, 65536
  sw	x1, 0(x31)
  lw	x2, 0(x31)
  sw	x1, 4(x31)
  lw	x3, 4(x31)
  sw	x1, 8(x31)
  lw	x4, 8(x31)
 
  # forwarding with load
  lw	x5, 0(x31)
  nop
  addi  x1, x5, 1 

  # forwarding with load
  lw	x6, 0(x31)
  addi  x1, x6, 1

  # forwarding with load 
  lw	x6, 0(x31)
  addi  x1, x6, 1
  addi  x2, x6, 1 
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
     