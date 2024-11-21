`include "macros.vh"
//------------------------------------------------------------------------------
// Performs naive re issue incase of dram not ready
// That unit also responsible for shift Vga in and out data and 1 clk delay for
// CR and Vga read data for cycle alignment with the d_cache
//------------------------------------------------------------------------------

module d_mem_reissue
import big_core_pkg::*;
(
    input logic              Clock,
    input logic              Rst, 
    input logic              DMemReady,
    input var t_dmem_region  MatchDmemRegionQ103H,
    input var t_core2mem_req Core2DmemReqQ103H,
    // cr interface
    input  logic [31:0]      CRMemRdDataQ104H,
    // vga interface
    input  logic [31:0]     PreVGAMemRdDataQ104H,
    // cache interface
    input logic  [31:0]     Cache2coreRespDataQ105H,
    output logic [31:0]     ReIssueVGAMemRdDataQ105H ,
    output logic [31:0]     ReIssuedCrMemRdDataQ105H,
    output logic [31:0]     ReissueCache2coreRespDataQ105H 

);


//====================================
// re-issue mechanism of cr region
//====================================
logic [31:0] LastDataFromCRmemQ104H;
logic [31:0] ReIssuedCrMemRdDataQ104H;
logic [31:0] ReIssuePreShiftVGAMemRdDataQ104H;
logic        SampleCrmemReadyQ104H;
logic [31:0] LastDataFromVgamemQ104H;
logic        SampleVgamemReadyQ104H;
logic [31:0] LastCache2coreRespDataQ105H;
logic        SampleCache2coreRespDataQ105H;


 
 // re issue flops
`MAFIA_DFF   (SampleCrmemReadyQ104H, DMemReady      , Clock)
`MAFIA_EN_DFF(LastDataFromCRmemQ104H, CRMemRdDataQ104H, Clock , SampleCrmemReadyQ104H)

 assign ReIssuedCrMemRdDataQ104H = SampleCrmemReadyQ104H ? CRMemRdDataQ104H : LastDataFromCRmemQ104H;

// pass data as is the next stage, no enable signal is needed
`MAFIA_DFF(ReIssuedCrMemRdDataQ105H, ReIssuedCrMemRdDataQ104H, Clock)


//====================================
// re-issue mechanism of vga region
//====================================
// re issue flops
`MAFIA_DFF   (SampleVgamemReadyQ104H, DMemReady      , Clock)
`MAFIA_EN_DFF(LastDataFromVgamemQ104H, PreVGAMemRdDataQ104H, Clock , SampleVgamemReadyQ104H)

assign ReIssuePreShiftVGAMemRdDataQ104H = SampleVgamemReadyQ104H ? PreVGAMemRdDataQ104H : LastDataFromVgamemQ104H;

// pass data as is to next stage no enable signal is needed
`MAFIA_DFF(ReIssueVGAMemRdDataQ105H, ReIssuePreShiftVGAMemRdDataQ104H, Clock)
//===============================================
// re-issue mechanism of Cache2coreRespDataQ105H
//==============================================
// re issue flops
`MAFIA_DFF   (SampleCache2coreRespDataQ105H, DMemReady      , Clock)
`MAFIA_EN_DFF(LastCache2coreRespDataQ105H, Cache2coreRespDataQ105H, Clock , SampleCache2coreRespDataQ105H)
assign ReissueCache2coreRespDataQ105H = SampleCache2coreRespDataQ105H ? Cache2coreRespDataQ105H : LastCache2coreRespDataQ105H;


endmodule