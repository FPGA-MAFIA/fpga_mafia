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

`include "macros.sv"

module `mini_core_if 
import common_pkg::*;
(
    input  logic        Clock,
    input  logic        Rst,
    input  t_ctrl_if    Ctrl,
    input  logic [31:0] AluOutQ102H,
    output logic [31:0] PcQ100H,
    output logic [31:0] PcQ101H
);

logic [31:0] PcQ101H;
assign PcPlus4Q100H = PcQ100H + 3'h4;
assign NextPcQ102H  = Ctrl.SelNextPcAluOutQ102H ? AluOutQ102H : PcPlus4Q100H;
`MAFIA_EN_RST_DFF(PcQ100H, NextPcQ102H, Clock, Ctrl.PcEnQ101H, Rst)

// Q100H to Q101H Flip Flops. 
`MAFIA_EN_DFF(PcQ101H     , PcQ100H     , Clock, Ctrl.PcEnQ101H)
`MAFIA_EN_DFF(PcPlus4Q101H, PcPlus4Q100H, Clock, Ctrl.PcEnQ101H)

endmodule