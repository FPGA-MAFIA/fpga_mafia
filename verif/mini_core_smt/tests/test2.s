     .text
     .globl     main
     .type     main, @function
main:
  li    x5,  10
  li    x6,  20
  li    x7,  30
  li    x8,  40

  add x7, x6, x5 
  ebreak
