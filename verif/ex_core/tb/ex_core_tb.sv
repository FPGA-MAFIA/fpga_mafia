`timescale 1ns / 1ps

module ex_core_tb;
    // Clock and reset signals
    logic Clk;
    logic Rst;

    // Instantiate the DUT (Device Under Test)
    ex_core dut (
        .Clk(Clk),
        .Rst(Rst)
    );

    // Clock generation
    always #5 Clk = ~Clk; // 10ns clock period

    initial begin
        // Initialize signals
        Clk = 0;
        Rst = 1;

        // Reset the CPU
        #20 Rst = 0;

        // Wait for a few clock cycles
        #1000;

        // Finish simulation
        $finish;
    end

    // Memory Initialization with R-Type instructions
    initial begin
        // Memory contents for R-Type instruction test
        // This part needs to be aligned with the actual memory implementation and loading mechanism
        // E.g., you might have an I_MEM file with assembly instructions

        // Example R-Type Instructions (binary format):
        // ADD x1, x2, x3   -> 0000000 00101 00010 000 00001 0110011
        // SUB x4, x5, x6   -> 0100000 00110 00101 000 00100 0110011
        // AND x7, x8, x9   -> 0000000 01001 01000 111 00111 0110011
        // OR  x10, x11, x12 -> 0000000 01100 01011 110 01010 0110011
        // XOR x13, x14, x15 -> 0000000 01111 01110 100 01101 0110011

        // Example: You might load these instructions into instruction memory
        // (e.g., using $readmemb or $readmemh to load from a file)
    end
endmodule
