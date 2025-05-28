    .text
    .globl main
    .type main, @function
main:
    # Load immediate values
    li x1, 1             # Load 1 into x1
    li x2, 2             # Load 2 into x2
    li x3, 3             # Load 3 into x3
    li x4, 4             # Load 4 into x4
    li x5, 5             # Load 5 into x5
    li x6, 6             # Load 6 into x6
    li x7, 7             # Load 7 into x7
    li x8, 8             # Load 8 into x8

    # Arithmetic Operations
    add x9, x1, x2       # x9 = x1 + x2 (1 + 2 = 3)
    sub x10, x3, x2      # x10 = x3 - x2 (3 - 2 = 1)

    # Bitwise Operations
    and x13, x1, x7      # x13 = x1 & x7 (bitwise AND)
    or  x14, x2, x8      # x14 = x2 | x8 (bitwise OR)
    xor x15, x3, x4      # x15 = x3 ^ x4 (bitwise XOR)
    sll x16, x5, x1      # x16 = x5 << x1 (shift left)
    srl x17, x8, x2      # x17 = x8 >> x2 (logical shift right)
    sra x18, x6, x2      # x18 = x6 >> x2 (arithmetic shift right)

    # Load and Store Operations
    la x19, eot          # Load address of eot label into x19
    sw x9, 0(x19)        # Store value of x9 at address in x19
    lw x20, 0(x19)       # Load value at address in x19 into x20

    # Jump and Branch Instructions
    beq x1, x1, branch1  # If x1 == x1, jump to branch1
    nop                  # No operation (should not execute if branch works)
branch1:
    bne x1, x2, branch2  # If x1 != x2, jump to branch2
    nop                  # No operation (should not execute if branch works)
branch2:
    jal x21, eot         # Jump to eot and store return address in x21

    # Immediate Instructions
    addi x22, x1, 10     # x22 = x1 + 10 (1 + 10 = 11)
    andi x23, x2, 15     # x23 = x2 & 15 (bitwise AND with immediate)
    ori x24, x3, 0xFF    # x24 = x3 | 0xFF (bitwise OR with immediate)

    # EBREAK for Debugging

eot:
    nop                 # No operation
    nop                 # No operation
    nop                 # No operation
    ebreak              # Breakpoint for debugging
    nop                 # No operation
    nop                 # No operation
    nop                 # No operation

    .size main, .-main
    .ident "GCC: (xPack GNU RISC-V Embedded GCC x86_64) 10.2.0"