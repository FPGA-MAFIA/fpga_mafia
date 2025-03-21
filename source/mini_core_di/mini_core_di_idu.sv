

`include "macros.vh"
import mini_core_pkg::*;

module mini_core_di_idu (
    input  logic        Clock,
    input  logic        Rst,

    // jmp feedback
    input  var t_ctrl_if    Ctrl,

    input  logic [31:0] AluOutQ102H,
    input  logic        ReadyQ100H,
    input  logic        ReadyQ101H,
    input  logic        PreInstructionQ101H,

    input  logic        ReadyQ201H,
    input  logic        ReadyQ200H,
    input  logic        PreInstructionQ201H,

    output logic [31:0] PcQ100H,
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

logic [31:0] NextPcQ1nnH;
logic [31:0] NextPcQ2nnH;=

assign PcPlus4Q100H = PcQ100H + 3'h4; 
assign PcPlus8Q100H = PcQ100H + 3'h8; 

idu idu (
        .PC1_in(PcQ100H),
        .PC2_in(PcQ200H),
        .instr1(PreInstructionQ101H),
        .instr2(PreInstructionQ201H),
        .issue_instr1(PreInstructionQ101H_issued),
        .issue_instr2(PreInstructionQ201H_issued),
        .PC1_out(prePCQ101H),
        .PC2_out(prePCQ201H),
        ,issue2ValidN(issue2ValidN)
);

assign NextPcQ1nnH = Ctrl.SelNextPcAluOutQ102H ? AluOutQ102H :     // jmp case
                      issue2ValidN ? PcPlus4Q100H : PcPlus8Q100H;   // issue 2 used or not 
`MAFIA_EN_RST_DFF(PcQ100H, NextPcQ1nnH, Clock, ReadyQ100H, Rst)

assign NextPcQ2nnH = NextPcQ1nnH + 3'h4;
`MAFIA_EN_RST_DFF(PcQ200H, NextPcQ2nnH, Clock, ReadyQ200H, Rst)

// Q100H/Q200H to Q101H/Q201H Flip Flops. 
`MAFIA_EN_DFF(PcQ101H, prePCQ101H, Clock, ReadyQ101H)
`MAFIA_EN_DFF(PcQ201H, prePCQ201H, Clock, ReadyQ201H)

endmodule
