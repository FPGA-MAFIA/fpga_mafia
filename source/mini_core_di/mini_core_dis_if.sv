
`include "macros.vh"

module mini_core_dis_if 
import mini_core_pkg::*;
(
    input  logic        Clock,
    input  logic        Rst,

    input logic [31:0]  NextPcQ200H  // Instruction for secondary issue
    input  logic        ReadyQ200H,
    input  logic        ReadyQ201H,
    
    output logic [31:0] PcQ200H,
    output logic [31:0] PcQ201H
);

logic [31:0] NextPcQnnnH;

assign NextPcQnnnH  =  issue_instr2;
`MAFIA_EN_RST_DFF(PcQ200H, NextPcQnnnH, Clock, ReadyQ200H, Rst)

// Q200H to Q201H Flip Flops. 
`MAFIA_EN_DFF(PcQ201H, PcQ200H, Clock, ReadyQ201H)

endmodule