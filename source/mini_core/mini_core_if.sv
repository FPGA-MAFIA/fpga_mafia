//-----------------------------------------------------------------------------
// Title            : 
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : 
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Adviser          : Amichai Ben-David
// Created          : 7/2023
//-----------------------------------------------------------------------------

`include "macros.vh"

module mini_core_if 
import mini_core_pkg::*;
(
    input  logic        Clock,
    input  logic        Rst,
    input  var t_ctrl_if    Ctrl,
    input  logic        ReadyQ100H,
    input  logic        ReadyQ101H,
    input  logic [31:0] AluOutQ102H,
    output logic [31:0] PcQ100H,
    output logic [31:0] PcQ101H
);

logic [31:0] PcPlus4Q100H;
logic [31:0] NextPcQnnnH;
assign PcPlus4Q100H = PcQ100H + 3'h4;
assign NextPcQnnnH  = Ctrl.SelNextPcAluOutQ102H ? AluOutQ102H : PcPlus4Q100H;
`MAFIA_EN_RST_DFF(PcQ100H, NextPcQnnnH, Clock, ReadyQ100H, Rst)

// Q100H to Q101H Flip Flops. 
`MAFIA_EN_DFF(PcQ101H, PcQ100H, Clock, ReadyQ101H)

endmodule