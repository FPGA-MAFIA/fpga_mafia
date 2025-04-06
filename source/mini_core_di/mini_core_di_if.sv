`include "macros.vh"

module mini_core_di_if 
import mini_core_di_pkg::*;
(
    input  logic        Clock,
    input  logic        Rst,

    // jmp + issue feedback from Ctrl
    input  var t_ctrl_if    Ctrl,

    input  logic [31:0] AluOutQ102H,
    input  logic        ReadyQ100H,
    input  logic        ReadyQ200H,
    input  logic        ReadyQ101H,
    input  logic        ReadyQ201H,

    // input  logic        ReadyQ200H,

    output logic [31:0] PcQ100H,
    output logic [31:0] PcQ200H,
    output logic [31:0] PcQ101H,
    output logic [31:0] PcQ201H
);

logic [31:0] NextPcQ1nnH;
logic [31:0] NextPcQ2nnH;
logic [31:0] PcPlus4Q100H;
logic [31:0] PcPlus8Q100H;

// Pc Inc
assign PcPlus4Q100H = PcQ100H + 3'h4; 
assign PcPlus8Q100H = PcQ100H + 3'h8; 

// Q1
assign NextPcQ1nnH = Ctrl.SelNextPcAluOutQ102H ? AluOutQ102H :                 // jmp case
                     Ctrl.SelNextPcPlus4Q201H ? PcPlus4Q100H :
                     PcPlus8Q100H;   // issue 2 used or not 
`MAFIA_EN_RST_DFF(PcQ100H, NextPcQ1nnH, Clock, ReadyQ100H, Rst)
`MAFIA_EN_RST_DFF(PcQ101H, PcQ100H, Clock, ReadyQ101H, Rst)

// Q2
assign NextPcQ2nnH = NextPcQ1nnH + 3'h4;
`MAFIA_EN_RST_DFF(PcQ200H, NextPcQ2nnH, Clock, ReadyQ200H, Rst)
`MAFIA_EN_RST_DFF(PcQ201H, PcQ200H, Clock, ReadyQ201H, Rst)




endmodule