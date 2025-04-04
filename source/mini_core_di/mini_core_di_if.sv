`include "macros.vh"

module mini_core_di_if 
import mini_core_pkg::*;
(
    input  logic        Clock,
    input  logic        Rst,

    // jmp + issue feedback from Ctrl
    input  var t_ctrl_if    Ctrl,

    input  logic [31:0] AluOutQ102H,
    input  logic        ReadyQ100H,
    // input  logic        ReadyQ200H,

    output logic [31:0] PcQ100H,
    output logic [31:0] PcQ200H 

);

logic [31:0] PcQ200H;
logic [31:0] NextPcQ1nnH;
logic [31:0] NextPcQ2nnH;

// Pc Inc
assign PcPlus4Q100H = PcQ100H + 3'h4; 
assign PcPlus8Q100H = PcQ100H + 3'h8; 

// Q1
assign NextPcQ1nnH = Ctrl.SelNextPcAluOutQ102H ? AluOutQ102H :                 // jmp case
                     Ctrl.SelNextPcPlus4Q201H ? PcPlus4Q100H : PcPlus8Q100H;   // issue 2 used or not 
`MAFIA_EN_RST_DFF(PcQ100H, NextPcQ1nnH, Clock, ReadyQ100H, Rst)

// Q2
assign NextPcQ2nnH = NextPcQ1nnH + 3'h4;
`MAFIA_EN_RST_DFF(PcQ200H, NextPcQ2nnH, Clock, ReadyQ200H, Rst)

endmodule