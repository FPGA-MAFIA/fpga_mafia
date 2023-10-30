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

  # forward from Q103H to Q102H
  add   x9,  x1,  x2
  add   x10, x9,  x2

  # forward from Q104H to Q102H
  add   x11,  x1,  x2
  nop
  add   x12, x11,  x2

  # forward from Q105H to Q102H
  add   x13,  x1,  x2
  nop
  nop
  add   x14, x13,  x2

  # forward from Q105 to Q101 (Ctrl.RegSrc1Q101H == Ctrl.RegDstQ105H) && (Ctrl.RegWrEnQ105H)
  add   x15,  x1,  x2
  nop
  nop
  nop
  add   x16, x15,  x2

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
     