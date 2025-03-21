
`include "macros.vh"

module mini_core_dis_if 
import mini_core_pkg::*;
(
    input  logic        Clock,
    input  logic        Rst,    
    input  var t_ctrl_if    Ctrl,
    input  logic [31:0] PreLastPcIssuedQ101
    input  logic        ReadyQ200H,

    output logic [31:0] PcQ200H

);

logic [31:0] PcPlus4Q200H;
logic [31:0] NextPcQnnnH;
assign PcPlus8Q200H = PreLastPcIssuedQ101 + 3'h8;
assign AluOutQ102Plus4 = AluOutQ102H + 3'h4;
assign NextPcQnnnH  = Ctrl.SelNextPcAluOutQ102H ? AluOutQ102Plus4 : PcPlus4Q200H;
`MAFIA_EN_RST_DFF(PcQ200H, NextPcQnnnH, Clock, ReadyQ200H, Rst)

endmodule