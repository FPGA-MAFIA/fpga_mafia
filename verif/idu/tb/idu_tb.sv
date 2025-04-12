`timescale 1ns/1ps

module idu_tb;

    logic [31:0] instr1, instr2;
    logic [31:0] PC1_in, PC2_in;

    logic [31:0] PC1_out, PC2_out;
    logic [31:0] issue_instr1, issue_instr2;
    logic issue2ValidN;

    idu dut (
        .PC1_in(PC1_in),
        .PC2_in(PC2_in),
        .instr1(instr1),
        .instr2(instr2),
        .PC1_out(PC1_out),
        .PC2_out(PC2_out),
        .issue_instr1(issue_instr1),
        .issue_instr2(issue_instr2),
        .issue2ValidN(issue2ValidN)
    );

    task display_results;
        input [31:0] instr1, instr2;
        input [31:0] issue_instr1, issue_instr2;
        input [31:0] PC1_in, PC2_in;
        input [31:0] PC1_out, PC2_out;
        input logic issue2ValidN;
        begin
            $display("--------------------------------------------------");
            $display("Input PCs:       PC1_in = %h | PC2_in = %h", PC1_in, PC2_in);
            $display("Input Instrs:    instr1 = %h | instr2 = %h", instr1, instr2);
            $display("Output PCs:      PC1_out = %h | PC2_out = %h", PC1_out, PC2_out);
            $display("Issued Instrs:   issue_instr1 = %h | issue_instr2 = %h", issue_instr1, issue_instr2);
            $display("issue2ValidN:    %b", issue2ValidN);
            $display("--------------------------------------------------");
        end
    endtask

    initial begin

        // Test 1: No Dependency, Dual Issue Expected
        $display("Test 1: No Dependency");
        PC1_in = 32'h00000000; PC2_in = 32'h00000004;
        instr1 = 32'h00200093; instr2 = 32'h00300113;
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        PC1_in = 32'h00000008; PC2_in = 32'h0000000C;
        instr1 = 32'h00600213; instr2 = 32'h00700293;
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        // Test 2: RAW Dependency, Single Issue Expected
        $display("Test 2: RAW Dependency");
        PC1_in = 32'h00000010; PC2_in = 32'h00000014;
        instr1 = 32'h00100113; // addi x2, x0, 1
        instr2 = 32'h00210213; // addi x4, x2, 2
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        PC1_in = 32'h00000018; PC2_in = 32'h0000001C;
        instr1 = 32'h00500293; // addi x5, x0, 5
        instr2 = 32'h00628313; // addi x6, x5, 6
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        // Test 3: WAW Dependency, Single Issue Expected
        $display("Test 3: WAW Dependency");
        PC1_in = 32'h00000020; PC2_in = 32'h00000024;
        instr1 = 32'h00100093; // addi x1, x0, 1
        instr2 = 32'h00200093; // addi x1, x0, 2
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        PC1_in = 32'h00000028; PC2_in = 32'h0000002C;
        instr1 = 32'h00300113; // addi x2, x0, 3
        instr2 = 32'h00400113; // addi x2, x0, 4
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        // Test 4: Branch Hazard, Second Instruction Stalled
        $display("Test 4: Branch or Jump");
        PC1_in = 32'h00000030; PC2_in = 32'h00000034;
        instr1 = 32'h0000006F; // jal x0, 0
        instr2 = 32'h00300113; // addi x2, x0, 3
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        PC1_in = 32'h00000038; PC2_in = 32'h0000003C;
        instr1 = 32'h00028063; // beq x5, x0, offset
        instr2 = 32'h00200093; // addi x1, x0, 2
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        // Test 5: Memory Access Conflict
        $display("Test 5: Memory Access");
        PC1_in = 32'h00000040; PC2_in = 32'h00000044;
        instr1 = 32'h00002003; // lw x0, 0(x0)
        instr2 = 32'h00002283; // lw x5, 0(x0)
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        PC1_in = 32'h00000048; PC2_in = 32'h0000004C;
        instr1 = 32'h00402023; // sw x4, 0(x0)
        instr2 = 32'h00802023; // sw x8, 0(x0)
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        // Test 6: Instruction Swapping
        $display("Test 6: Swapping Memory to Primary Slot");
        PC1_in = 32'h00000050; PC2_in = 32'h00000054;
        instr1 = 32'h00300113; // addi x2, x0, 3
        instr2 = 32'h00002003; // lw x0, 0(x0)
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        PC1_in = 32'h00000058; PC2_in = 32'h0000005C;
        instr1 = 32'h00500293; // addi x5, x0, 5
        instr2 = 32'h00402003; // lw x0, 4(x0)
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        // Test 7: NOP/EBREAK handling
        $display("Test 7: NOP or EBREAK");
        PC1_in = 32'h00000060; PC2_in = 32'h00000064;
        instr1 = 32'h00000013; // NOP
        instr2 = 32'h00300113; // addi x2, x0, 3
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        PC1_in = 32'h00000068; PC2_in = 32'h0000006C;
        instr1 = 32'h00100073; // EBREAK
        instr2 = 32'h00200093; // addi x1, x0, 2
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        PC1_in = 32'h00000070; PC2_in = 32'h00000074;
        instr1 = 32'h00200093; // addi x1, x0, 2
        instr2 = 32'h00000013; // NOP
        #10; display_results(instr1, instr2, issue_instr1, issue_instr2, PC1_in, PC2_in, PC1_out, PC2_out, issue2ValidN);

        $finish;
    end
endmodule
