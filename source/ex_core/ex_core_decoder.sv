`include "macros.vh"

module ex_core_decoder
import ex_core_pkg::*;
(
    input logic clk,
    input logic [31:0] instruction,
    input logic [31:0] instr,
    output logic [6:0] opcode,
    output t_ctrl_alu CtrlAlu,
    output t_ctrl_rf CtrlRf,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic [31:0] imm
);

    // Extract fields from the instruction
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    // Immediate value extraction (assuming RISC-V encoding for simplicity)
    always_comb begin
        case (opcode)
            7'b0010011: imm = {{20{instr[31]}}, instr[31:20]};  // I-type (ADDI, ANDI, ORI, etc.)
            7'b0000011: imm = {{20{instr[31]}}, instr[31:20]};  // I-type (LW)
            7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};  // S-type (SW)
            7'b1100011: imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};  // B-type (BEQ, BNE)
            default:    imm = 32'b0;
        endcase
    end

    // Decode the instruction for ALU control signals
    assign CtrlAlu.AluOp   = t_alu_op'(instr[31:25]); // AluOp is based on funct7
    assign CtrlAlu.RegSrc1 = instr[19:15];
    assign CtrlAlu.RegSrc2 = instr[24:20];
    assign CtrlAlu.RegDst  = instr[11:7];
    assign CtrlAlu.RegWrEn = (opcode == 7'b0110011) || (opcode == 7'b0010011) || (opcode == 7'b0000011);

    // Decode the instruction for RF control signals
    assign CtrlRf.RegSrc1 = instr[19:15];
    assign CtrlRf.RegSrc2 = instr[24:20];
    assign CtrlRf.RegDst  = instr[11:7];
    assign CtrlRf.RegWrEn = (opcode == 7'b0110011) || (opcode == 7'b0010011) || (opcode == 7'b0000011);

endmodule