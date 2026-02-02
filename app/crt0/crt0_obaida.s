 _start:
  .global _start
  .org 0x00
  nop                       
  nop                       
  nop                       
  nop                       
  nop                       

reset_handler:
  /* Initialize registers to zero (optional) */
  mv  x1, x0
  li  x2, 2
  li  x3, 3
  li  x4, 4
  li  x5, 5
  li  x6, 6
  li  x7, 7
  li  x8, 8
  li  x9, 9
  li x10, 10
  mv x11, x1
  mv x12, x1
  mv x13, x1
  mv x14, x1
  mv x15, x1
  mv x16, x1
  mv x17, x1
  mv x18, x1
  mv x19, x1
  mv x20, x1
  mv x21, x1
  mv x22, x1
  mv x23, x1
  mv x24, x1
  mv x25, x1
  mv x26, x1
  mv x27, x1
  mv x28, x1
  mv x29, x1
  mv x30, x1
  mv x31, x1

  /* Stack initialization */
  la   x2, _stack_start



jump_main:
  jal x1, main          /* Jump to main */
  nop
  ebreak                /* End */
  .section .text

    
restore_and_return:
    # Restore registers from the stack
    lw ra, 28(sp)
    lw a0, 24(sp)
    lw a1, 20(sp)
    lw a2, 16(sp)
    lw a3, 12(sp)
    lw t0, 8(sp)
    lw t1, 4(sp)
    addi sp, sp, 32      # Deallocate stack space
    mret                 # Return from interrupt