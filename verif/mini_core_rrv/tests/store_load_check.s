#./build.py -dut mini_core_rrv -test store_load_check -app -hw -sim -clean
     .text
     .globl     main
     .type     main, @function
main:
  li    x1,  100   
  li    x2,  200

  
  # no hazards
  li  x31, 65536
  sw	x1, 0(x31)
  lw	x2, 0(x31)
  sw	x1, 4(x31)
  lw	x3, 4(x31)
  sw	x1, 8(x31)
  lw	x4, 8(x31)
 
  # hazards (insert 1 nop and stall 1 cycle)
  #lw	x5, 0(x31)
  #nop
  #addi  x1, x5, 1 

  # hazards (insert 2 nops and stall 2 cycles)
  lw	x6, 0(x31)
  addi  x1, x6, 1

   # hazards 
  #lw	x6, 0(x31)
  #addi  x1, x6, 1
    #addi  x2, x6, 1 
     
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
     