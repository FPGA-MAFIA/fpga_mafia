
`include "macros.vh"

// The goal of that model is to prevent from accepting new instruction on case of stall or back pressure
module i_mem_stall_bp
(
    input               Clock, 
    input logic         ReadyQ101H,
    input logic [31:0]  InstructionQ101H,
    output logic [31:0] PreInstructionQ101H
);

logic [31:0] LastInstructionFetchQ101H;
logic        SampleReadyQ101H;

assign PreInstructionQ101H = SampleReadyQ101H ? InstructionQ101H : LastInstructionFetchQ101H;


`MAFIA_DFF   (SampleReadyQ101H, ReadyQ101H , Clock)
`MAFIA_EN_DFF(LastInstructionFetchQ101H, InstructionQ101H, Clock , SampleReadyQ101H)

endmodule

// the following lines are responsible to keep the previous instruction when back pressure or stall is detected // FIXME - condider to add into specific module
