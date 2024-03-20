`include "macros.vh"

module mini_core_rrv_top
import mini_core_rrv_pkg::*;
(
    input logic Clock,
    input logic Rst
   
);

// Imem interface
logic [31:0] PreInstructionQ101H;
logic [31:0] PcQ100H;

mini_core_rrv mini_core_rrv 
(
    .Clock(Clock),
    .Rst(Rst),
    // I_MEM interface
    .PreInstructionQ101H(PreInstructionQ101H), // from I_MEM
    .PcQ100H(PcQ100H)

);

mini_core_rrv_mem_wrap mini_core_rrv_mem_wrap
(
    .Clock(Clock),
    .Rst(Rst),
    .PcQ100H(PcQ100H),
    .PreInstructionQ101H(PreInstructionQ101H) 

);

endmodule