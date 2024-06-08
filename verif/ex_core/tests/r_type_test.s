# build hardware, application, and run the simulation: 
# ./build.py -hw -app -sim -dut ex_core -test r_type_test -clean
    .text
    .globl  main
    .type   main, @function

main:
    # Example R-Type Instructions (binary format):
    ADD x1, x2, x3    # -> 0000000 00101 00010 000 00001 0110011
    SUB x4, x5, x6    # -> 0100000 00110 00101 000 00100 0110011
    AND x7, x8, x9    # -> 0000000 01001 01000 111 00111 0110011
    OR  x10, x11, x12 # -> 0000000 01100 01011 110 01010 0110011
    XOR x13, x14, x15 # -> 0000000 01111 01110 100 01101 0110011
    
    # Initialize registers with values
    ADDI x1, x0, 10      # x1 = 10
    ADDI x2, x0, 20      # x2 = 20
    ADDI x3, x0, 30      # x3 = 30
    ADDI x4, x0, 40      # x4 = 40

    # Arithmetic Operations
    ADD x5, x1, x2       # x5 = x1 + x2 = 10 + 20 = 30
    SUB x6, x3, x1       # x6 = x3 - x1 = 30 - 10 = 20
    AND x7, x4, x3       # x7 = x4 & x3 = 40 & 30 = 8 (0x28 & 0x1E)
    OR x8, x1, x2        # x8 = x1 | x2 = 10 | 20 = 30 (0x0A | 0x14)

    # Memory Operations
    SW x5, 0(x0)         # Store x5 to address 0
    LW x9, 0(x0)         # Load from address 0 to x9 (x9 should be 30)

    # Simple Branch (no hazard, just a test)
    BEQ x1, x2, label    # If x1 == x2, branch (this should not branch)
    ADDI x10, x0, 50     # This should execute (x10 = 50)
    J end                # Jump to the end

label:
    ADDI x10, x0, 100    # This should not execute (x10 should remain 50)

end:
    # End of test
    NOP                  # No operation
    NOP                  # No operation
    NOP                  # No operation
    NOP                  # No operation
    NOP                  # No operation
    ebreak               # End the program
    NOP                  # No operation
    NOP                  # No operation
    NOP                  # No operation

    .size main, .-main
    .ident "GCC: (xPack GNU RISC-V Embedded GCC x86_64) 10.2.0"
