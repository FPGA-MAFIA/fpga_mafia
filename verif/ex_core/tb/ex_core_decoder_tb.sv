/* to run that TB:
 * ./build.py -sim -dut ex_core -top ex_core_decoder_tb -hw -clean
 */
`timescale 1ns/1ps

module ex_core_decoder_tb;
    import ex_core_pkg::*;

    // Declare testbench signals
    logic clk;
    logic [31:0] instruction;
    t_opcode opcode;
    t_ctrl_alu CtrlAlu;
    t_ctrl_rf CtrlRf;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [31:0] imm;

    // Instantiate the module under test (MUT)
    ex_core_decoder uut (
        .clk(clk),
        .instruction(instruction),
        .opcode(opcode),
        .CtrlAlu(CtrlAlu),
        .CtrlRf(CtrlRf),
        .funct3(funct3),
        .funct7(funct7),
        .imm(imm)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Helper task to apply test vectors and print results
    task apply_test_vector(input logic [31:0] test_instr, input string instr_type);
        begin
            instruction = test_instr;
            #10;
            $display("-----------------------------------------------------");
            $display("Instruction Type: %s", instr_type);
            $display("Instruction: 0x%h", test_instr);
            $display("Opcode: %b", opcode);
            $display("Funct3: %b", funct3);
            $display("Funct7: %b", funct7);
            $display("Immediate: 0x%h", imm);
            $display("CtrlAlu: AluOp=%b",
                     CtrlAlu.AluOp);
            $display("CtrlRf: RegDst=%d, RegWrEn=%b",
                     CtrlRf.RegDst, CtrlRf.RegWrEn);
            $display("-----------------------------------------------------");
        end
    endtask

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        instruction = 32'h00000000;

        // Apply test vectors
        apply_test_vector(32'b0000000_00011_00010_000_00001_0110011, "R-type (ADD x1, x2, x3)");
        apply_test_vector(32'b000000000101_00010_000_00001_0010011, "I-type (ADDI x1, x2, 10)");
        apply_test_vector(32'b0000000_00001_00010_010_01010_0100011, "S-type (SW x1, 10(x2))");
        apply_test_vector(32'b0000000_00001_00010_000_10000_1100011, "B-type (BEQ x1, x2, 16)");

        // Additional test vectors can be added here to cover other instructions

        // Finish the simulation
        #10 $finish;
    end

    // Monitor procedure
    initial begin
        $monitor("At time %t, instruction = %h, opcode = %b, CtrlAlu = %p, CtrlRf = %p, funct3 = %b, funct7 = %b, imm = %h",
                 $time, instruction, opcode, CtrlAlu, CtrlRf, funct3, funct7, imm);
    end

endmodule
