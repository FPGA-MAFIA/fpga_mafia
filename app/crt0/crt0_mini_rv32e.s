_start:
  .global _start
  .org 0x00
  nop                       
  nop                       
  nop                       
  nop                       
  nop                       
reset_handler:
  mv  x1, x0
  mv  x2, x1
  mv  x3, x1
  mv  x4, x1
  mv  x5, x1
  mv  x6, x1
  mv  x7, x1
  mv  x8, x1
  mv  x9, x1
  mv x10, x1
  mv x11, x1
  mv x12, x1
  mv x13, x1
  mv x14, x1
  mv x15, x1
  
  /* Stack initialization */
  la   x2, _stack_start

  /* Zero initialize .sbss section */
zero_sbss:
  la t0, __sbss_start   /* t0 = start of .sbss */
  la t1, __sbss_end     /* t1 = end of .sbss */
zero_sbss_loop:
  bge t0, t1, zero_bss  /* If t0 >= t1, proceed to zeroing .bss */
  sw x0, 0(t0)          /* Store zero in .sbss */
  addi t0, t0, 4        /* Increment t0 */
  j zero_sbss_loop      /* Repeat for next word */

  /* Zero initialize .bss section */
zero_bss:
  la t0, __bss_start    /* t0 = start of .bss */
  la t1, __bss_end      /* t1 = end of .bss */
zero_bss_loop:
  bge t0, t1, jump_main /* If t0 >= t1, proceed to main */
  sw x0, 0(t0)          /* Store zero in .bss */
  addi t0, t0, 4        /* Increment t0 */
  j zero_bss_loop       /* Repeat for next word */

jump_main:
  jal x1, main          /* Jump to main */
  nop
  ebreak                /* End */
  .section .text
 