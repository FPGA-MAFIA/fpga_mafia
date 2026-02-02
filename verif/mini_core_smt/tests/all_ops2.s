    .text
    .globl     main
    .type      main, @function

main:
    # Initialize registers
    li    x1,  1
    li    x2,  2
    li    x3,  3
    li    x4,  4
    li    x5,  5
    li    x6,  6
    li    x7,  7
    li    x8,  8

    # -------------------------------
    # Arithmetic
    # -------------------------------
    add   x9,  x1, x2      # x9  = 1 + 2 = 3
    sll   x8,  x2, x9      #read after write x8 = 2 << 3
    sub   x10, x3, x1      # x10 = 3 - 1 = 2
    addi  x11, x2, 5       # x11 = 2 + 5  = 7

    # -------------------------------
    # Memory operations
    # -------------------------------
    # Store word and Load word
    sw    x10, 0(x12)       # Store x10 at 0(x12)
    lw    x13, 0(x12)       # Load back into x13 → should be 2
    add   x5, x13, x13       # x5 = x13 + x13 → should be 4, forwarding

    # -------------------------------
    # Branches (make them predictable)
    # -------------------------------
    beq   x1, x1, label_eq      # Taken
    add   x5 , x5 , x1          # x5 = 5 + 1 = 6 should be flushed
    nop
label_eq:
    bne   x1, x2, label_ne      # Taken
    nop
label_ne:
    blt   x1, x2, label_lt      # Taken (10 < 20)
    nop
label_lt:
    bge   x2, x1, label_ge      # Taken (20 ≥ 10)
    nop
label_ge:
    bltu  x1, x2, label_ltu     # Taken (unsigned 10 < 20)
    nop
label_ltu:
    bgeu  x2, x1, label_geu     # Taken (unsigned 20 ≥ 10)
    nop
label_geu:

eot:
    nop
    nop
    nop
    ebreak
    nop
    nop
    nop

    .size     main, .-main
    .ident    "GCC: (xPack GNU RISC-V Embedded GCC x86_64) 10.2.0"
