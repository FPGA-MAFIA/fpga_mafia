

`include "macros.vh"
import mini_core_di_pkg::*;

module mini_core_di_idu (
    input  logic        Clock,
    input  logic        Rst,

    // jmp feedback
    input  var t_ctrl_if    Ctrl,

    input  logic        ReadyQ101H,
    input  logic        PreInstructionQ101H,

    input  logic        ReadyQ201H,
    input  logic        PreInstructionQ201H,

    output logic [31:0] PcQ101H,
    output logic [31:0] PreInstructionQ101H_issued,

    //output logic [31:0] PcQ200H, // we don't need it exposed, only used for memory request, we have that covered bu PcQ100H
    output logic [31:0] PcQ201H,
    output logic [31:0] PreInstructionQ201H_issued,

    output logic issue2ValidN
);

logic [31:0] PcQ200H;
logic [31:0] prePCQ101H;
logic [31:0] prePCQ201H;

idu idu (
        .PC1_in(PcQ101H),
        .PC2_in(PcQ201H),
        .instr1(PreInstructionQ101H),
        .instr2(PreInstructionQ201H),
        .issue_instr1(PreInstructionQ101H_issued),
        .issue_instr2(PreInstructionQ201H_issued),
        .PC1_out(prePCQ101H),
        .PC2_out(prePCQ201H),
        ,issue2ValidN(issue2ValidN)
);

// Q100H/Q200H to Q101H/Q201H Flip Flops. 
`MAFIA_EN_DFF(PcQ101H, prePCQ101H, Clock, ReadyQ101H)
`MAFIA_EN_DFF(PcQ201H, prePCQ201H, Clock, ReadyQ201H) // FIXME - Abd: should make sure this doesn't break when no using 2nd issue

endmodule
