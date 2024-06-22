
`include "macros.vh"

// The goal of that model is to ,ake naive re-issue once we have back pressure or stall from the core
module i_mem_reissue
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
