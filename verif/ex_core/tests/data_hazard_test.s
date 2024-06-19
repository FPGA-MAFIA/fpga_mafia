# build hardware, application, and run the simulation: 
# ./build.py -hw -app -sim -dut ex_core -test r_type_test -cfg ex_core -gui -clean
    .text
    .globl  main
    .type   main, @function

main:
    # Initialize registers with values
    ADDI x1, x0, 1      # x1 = 1
    ADDI x2, x0, 2      # x2 = 2
    ADDI x3, x0, 3      # x3 = 3
    ADDI x4, x0, 4      # x4 = 4
    ADD  x5, x0, x0     # x5 = 0
    ADD  x6, x0, x0     # x6 = 0
    ADD  x7, x0, x0     # x7 = 0
    ADD  x8, x0, x0     # x8 = 0
    

    # Example for RAW hazards:
    ADD x7, x2, x1    # -> 0000000 00101 00010 000 00001 0110011  
    SUB x8, x7, x2    # -> 0100000 00110 00101 000 00100 0110011  
    


    # Example for WAR hazards:
    ADD x7, x2, x1    # -> 0000000 00101 00010 000 00001 0110011  
    SUB x2, x7, x1    # -> 0100000 00110 00101 000 00100 0110011  


    # Example for RAR hazards:
    ADD x7, x2, x1    # -> 0000000 00101 00010 000 00001 0110011
    SUB x8, x2, x7    # -> 0100000 00110 00101 000 00100 0110011


    # Example for WAW hazards:
    ADD x7, x2, x1    # -> 0000000 00101 00010 000 00001 0110011
    SUB x7, x4, x2    # -> 0100000 00110 00101 000 00100 0110011


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
