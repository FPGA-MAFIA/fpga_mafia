`timescale 1ns/1ps

module ifu_cache_tb;

    // Parameters (you need to define these values appropriately)
    parameter NUM_TAGS = 4;
    parameter NUM_LINES = 4;
    parameter TAG_WIDTH = 8;
    parameter OFFSET_WIDTH = 4;

    // Inputs
    logic Clock;
    logic Rst;
    logic [31:0] pc;
    logic [127:0] insLineIn;
    logic insLineValidIn;

    // Outputs
    logic [127:0] insLineOut;
    logic insLineValidOut;

    // DUT instance
    ifu_cache #(
        .NUM_TAGS(NUM_TAGS),
        .NUM_LINES(NUM_LINES),
        .TAG_WIDTH(TAG_WIDTH),
        .OFFSET_WIDTH(OFFSET_WIDTH)
    ) dut (
        .Clock(Clock),
        .Rst(Rst),
        .pc(pc),
        .insLineIn(insLineIn),
        .insLineValidIn(insLineValidIn),
        .insLineOut(insLineOut),
        .insLineValidOut(insLineValidOut)
    );

    // Clock generation
    initial begin
        Clock = 0;
        forever #5 Clock = ~Clock; // 10ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        Rst = 1;
        pc = 32'd0;
        insLineIn = 128'h0;
        insLineValidIn = 0;

        // Apply reset
        #10 Rst = 0;

        // Test Case 1: Add instruction line
        @(posedge Clock);
        pc = 32'h1000;
        insLineIn = 128'hDEADBEEFCAFEBABEDEADBEEFCAFEBABE;
        insLineValidIn = 1;

        @(posedge Clock);
        insLineValidIn = 0; // Stop inputting instructions

        // Wait for one cycle
        #10;

        // Test Case 2: Fetch instruction line
        @(posedge Clock);
        pc = 32'h1000; // Same PC to check if the data is valid

        // Wait for one cycle
        #10;

        // Test Case 3: Invalid PC
        @(posedge Clock);
        pc = 32'h2000; // PC not in cache

        // End simulation
        #50 $stop;
    end

    // Monitor outputs for debugging
    initial begin
        $monitor("Time: %0t | Clock: %b | Rst: %b | PC: %h | insLineIn: %h | insLineValidIn: %b | insLineOut: %h | insLineValidOut: %b",
                 $time, Clock, Rst, pc, insLineIn, insLineValidIn, insLineOut, insLineValidOut);
    end

endmodule
