`include "macros.vh"

module ex_core_decoder
import ex_core_pkg::*;
(
    input logic clk,
    input logic [31:0] instruction,
    output t_opcode opcode,
    output t_ctrl_alu CtrlAlu,
    output t_ctrl_rf CtrlRf,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic [31:0] imm
);

    // Extract fields from the instruction
    assign opcode = t_opcode'(instruction[6:0]); // Explicit cast to t_opcode
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    // Immediate value extraction (assuming RISC-V encoding for simplicity)
    always_comb begin
        case (opcode)
            7'b0010011: imm = {{20{instruction[31]}}, instruction[31:20]};  // I-type (ADDI, ANDI, ORI, etc.)
            7'b0000011: imm = {{20{instruction[31]}}, instruction[31:20]};  // I-type (LW)
            7'b0100011: imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};  // S-type (SW)
            7'b1100011: imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};  // B-type (BEQ, BNE)
            default:    imm = 32'b0;
        endcase
    end

    // Decode the instruction for ALU control signals
    assign CtrlAlu.AluOp   = t_alu_op'(instruction[31:25]); // AluOp is based on funct7
    assign CtrlAlu.RegSrc1 = instruction[19:15];
    assign CtrlAlu.RegSrc2 = instruction[24:20];
    assign CtrlAlu.RegDst  = instruction[11:7];
    assign CtrlAlu.RegWrEn = (opcode == t_opcode'('b0110011)) || (opcode == t_opcode'('b0010011)) || (opcode == t_opcode'('b0000011)); // R-type and I-type

    // Decode the instruction for RF control signals
    assign CtrlRf.RegDst  = instruction[11:7];
    assign CtrlRf.RegWrEn = (opcode == t_opcode'('b0110011)) || (opcode == t_opcode'('b0010011)) || (opcode == t_opcode'('b0000011)); // R-type and I-type

endmodule
