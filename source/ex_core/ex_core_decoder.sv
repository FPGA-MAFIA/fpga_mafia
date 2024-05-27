`include "macros.vh"
`include "ex_core_pkg.sv"

module ex_core_decoder
import ex_core_pkg::*;
(
    input  logic [31:0] instr,
    output t_ctrl_alu    CtrlAlu,
    output t_ctrl_rf     CtrlRf
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