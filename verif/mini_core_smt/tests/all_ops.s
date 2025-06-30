    .text
    .globl     main
    .type      main, @function

main:
    # Initialize registers
    li    x1,  10
    li    x2,  20
    li    x3,  30
    li    x4,  40
    li    x5,  50
    li    x6,  60
    li    x7,  70
    li    x8,  80

    # -------------------------------
    # Arithmetic
    # -------------------------------
    add   x9,  x1, x2      # x9  = 10 + 20 = 30
    sub   x10, x3, x1      # x10 = 30 - 10 = 20
    addi  x11, x2, 5       # x11 = 20 + 5  = 25

    # -------------------------------
    # Memory operations
    # -------------------------------
    # Store word and Load word
    sw    x11, 0(x12)       # Store x11 at 0(x12)
    lw    x13, 0(x12)       # Load back into x13 → should be 25

    # -------------------------------
    # Branches (make them predictable)
    # -------------------------------
    beq   x1, x1, label_eq      # Taken
    nop
label_eq:
    addi  x10 , x10 , 0x4       # x10 = 20 + 4 = 24
    bne   x1, x2, label_ne      # Taken
    nop
label_ne:
    blt   x2, x1, label_lt      # Not Taken (20 < 10)
    add   x4 , x2 , x3          # x4 = 20 + 30 = 50 
    jal   x0, label_lt
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
