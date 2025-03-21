

`include "macros.vh"

module mini_core_dip_if 
import mini_core_pkg::*;
(
    input  logic        Clock,
    input  logic        Rst,
    input  var t_ctrl_if    Ctrl,
    
    input  logic [31:0] PreLastPcIssuedQ101, 

    input  logic        ReadyQ100H,
    input  logic        ReadyQ101H,
    input  logic [31:0] AluOutQ102H,

    output logic [31:0] PcQ100H,
);

logic [31:0] PcPlus4Q100H;
logic [31:0] NextPcQnnnH;
assign PcPlus4Q100H = PreLastPcIssuedQ101 + 3'h4;
assign NextPcQnnnH  = Ctrl.SelNextPcAluOutQ102H ? AluOutQ102H : PcPlus4Q100H;
`MAFIA_EN_RST_DFF(PcQ100H, NextPcQnnnH, Clock, ReadyQ100H, Rst)

endmodule