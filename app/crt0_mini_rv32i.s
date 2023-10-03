_start:
  .global _start
  .org 0x00
  nop                       
  nop                       
  nop                       
  nop                       
  nop                       

  /* stack initialization */
  la   x2, _stack_start

  jal x1, main  //jump to main
  ebreak        //end
  .section .text
  
##################################################
# Interrupt handler for the counter in location 
##################################################
handle_interrupt:
  .org 0x100
    # Save registers on the stack
    addi sp, sp, -32     # Allocate stack space for 8 registers
    sw ra, 28(sp)        # Save return address
    sw a0, 24(sp)        # Save a0-a3
    sw a1, 20(sp)
    sw a2, 16(sp)
    sw a3, 12(sp)
    sw t0, 8(sp)         # Save t0-t1
    sw t1, 4(sp)

handle_exception:
    # increment the counter of CSR 0x9
    csrr t0, 0x9
    addi t0, t0, 1
    csrw 0x9, t0
    
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


