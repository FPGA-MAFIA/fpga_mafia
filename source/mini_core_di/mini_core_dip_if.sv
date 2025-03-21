

`include "macros.vh"

module mini_core_dip_if 
import mini_core_pkg::*;
(
    input  logic        Clock,
    input  logic        Rst,
    input  logic        ReadyQ100H,
    input  logic        ReadyQ101H,
    input logic [31:0]  NextPcQ100H, // Instruction for primary issue
    
    output logic [31:0] PcQ100H,
    output logic [31:0] PcQ101H
);

logic [31:0] NextPcQnnnH;

assign NextPcQnnnH  = issue_instr1;
`MAFIA_EN_RST_DFF(PcQ100H, NextPcQnnnH, Clock, ReadyQ100H, Rst)

// Q100H to Q101H Flip Flops. 
`MAFIA_EN_DFF(PcQ101H, PcQ100H, Clock, ReadyQ101H)

endmodule