`include "macros.vh"
`include "ex_core_pkg.sv"

module ex_core_decoder
import ex_core_pkg::*;
(
    input logic clk,
    input logic [31:0] instruction,
    output t_ctrl_rf     CtrlRf,
    output logic [6:0] opcode,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic [31:0] imm,
    output logic reg_write,
    output logic branch,
    output logic jump,
    output logic [3:0] alu_op


    input  logic [31:0] instr,
    output logic [6:0] opcode,
    output t_ctrl_alu    CtrlAlu,
    output t_ctrl_rf     CtrlRf,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic [31:0] imm,

);

    // Decode the instruction
    assign CtrlAlu.AluOp   = instr[6:3];
    assign CtrlAlu.RegSrc1 = instr[11:7];
    assign CtrlAlu.RegSrc2 = instr[16:12];
    assign CtrlAlu.RegDst  = instr[21:17];
    assign CtrlAlu.RegWrEn = instr[22];

    assign CtrlRf.RegSrc1 = instr[11:7];
    assign CtrlRf.RegSrc2 = instr[16:12];
    assign CtrlRf.RegDst  = instr[21:17];
    assign CtrlRf.RegWrEn = instr[22];



endmodule