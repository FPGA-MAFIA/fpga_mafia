.extern interrupt_handler

_start:
  .global _start
  .org 0x00
  nop                       
  nop                       
  nop                       
  nop                       
  nop                       

reset_handler:
  /* Initialize registers */
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

  j init_handler            # Jump to the initialization handler after NOPs

###############################################
# Trap handler for interrupts and exceptions 
###############################################
trap_handler:
  .org 0x100
    # save sp into csr_custom_sp for special needs
    csrw 0xBC2, sp
    # Save registers on the stack
    addi sp, sp, -128     # Allocate stack space for 31 registers
    sw ra, 124(sp)        
    sw sp, 120(sp)        
    sw gp, 116(sp)
    sw tp, 112(sp)
    sw t0, 108(sp)
    sw t1, 104(sp)         
    sw t2, 100(sp)
    sw s0, 96(sp)        
    sw s1, 92(sp)
    sw a0, 88(sp)
    sw a1, 84(sp)
    sw a2, 80(sp)         
    sw a3, 76(sp)
    sw a4, 72(sp)
    sw a5, 68(sp)
    sw a6, 64(sp)         
    sw a7, 60(sp)
    sw s2, 56(sp)        
    sw s3, 52(sp)
    sw s4, 48(sp)
    sw s5, 44(sp)
    sw s6, 40(sp)         
    sw s7, 36(sp)
    sw s8, 32(sp)
    sw s9, 28(sp)
    sw s10, 24(sp)         
    sw s11, 20(sp)
    sw t3, 16(sp)
    sw t4, 12(sp)
    sw t5, 8(sp)         
    sw t6, 4(sp)

call_interrupt_handler:
  call interrupt_handler

restore_and_return:
    # Restore registers from the stack
    lw ra, 124(sp)        
    lw sp, 120(sp)        
    lw gp, 116(sp)
    lw tp, 112(sp)
    lw t0, 108(sp)
    lw t1, 104(sp)         
    lw t2, 100(sp)
    lw s0, 96(sp)        
    lw s1, 92(sp)
    lw a0, 88(sp)
    lw a1, 84(sp)
    lw a2, 80(sp)         
    lw a3, 76(sp)
    lw a4, 72(sp)
    lw a5, 68(sp)
    lw a6, 64(sp)         
    lw a7, 60(sp)
    lw s2, 56(sp)        
    lw s3, 52(sp)
    lw s4, 48(sp)
    lw s5, 44(sp)
    lw s6, 40(sp)         
    lw s7, 36(sp)
    lw s8, 32(sp)
    lw s9, 28(sp)
    lw s10, 24(sp)         
    lw s11, 20(sp)
    lw t3, 16(sp)
    lw t4, 12(sp)
    lw t5, 8(sp)         
    lw t6, 4(sp)
    addi sp, sp, 128      # Deallocate stack space
    mret                  # Return from interrupt

# After the trap handler, initialize the system
# --------------------------------------------------

init_handler:

csr_init:
  li t0, 0x100      # Load the immediate value 0x100 of trap handler address
  csrw mtvec, t0    # Write the value in t0 to the mtvec CSR

  # Enable software and external interrupts. Set meie and msie to 1 and mtie to 0 as default values
  li t0, 0x808
  csrw	mie, t0     
  
  # Enable interrupts. Set MIE and MPIE bit to 1 and 0 respectively in mstatus register.
  li t0, 0x8
  csrw  mstatus, t0 
  
  # update custom csr at address 0xBC0 that serves as mtimecmp register
  li t0, 0x00000500
  csrw 0xBC0, t0    

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
