`include "macros.vh"
//------------------------------------------------------------------------------
// Performs naive re issue incase of dram not ready
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
    input  logic [31:0]     VGAMemRdDataQ104H,
    // cache interface
    input logic  [31:0]     Cache2coreRespDataQ105H,
    output logic [31:0]     ReIssueVGAMemRdDataQ104H,
    output logic [31:0]     ReIssuedCrMemRdDataQ104H,
    output logic [31:0]     ReissueCache2coreRespDataQ105H 

);


//====================================
// re-issue mechanism of cr region
//====================================
logic [31:0] LastDataFromCRmemQ104H;
logic [31:0] LastDataFromVgamemQ104H;
logic [31:0] LastCache2coreRespDataQ105H;
logic        SampleDMemReady;
`MAFIA_DFF   (SampleDMemReady , DMemReady      , Clock)

//====================================
// re-issue mechanism of cr region
//====================================
`MAFIA_EN_DFF(LastDataFromCRmemQ104H, CRMemRdDataQ104H, Clock , SampleDMemReady)
 assign ReIssuedCrMemRdDataQ104H = SampleDMemReady ? CRMemRdDataQ104H : LastDataFromCRmemQ104H;
//====================================
// re-issue mechanism of vga region
//====================================
`MAFIA_EN_DFF(LastDataFromVgamemQ104H, VGAMemRdDataQ104H, Clock , SampleDMemReady)
assign ReIssueVGAMemRdDataQ104H = SampleDMemReady ? VGAMemRdDataQ104H : LastDataFromVgamemQ104H;

//===============================================
// re-issue mechanism of Cache2coreRespDataQ105H
//==============================================
`MAFIA_EN_DFF(LastCache2coreRespDataQ105H, Cache2coreRespDataQ105H, Clock , SampleDMemReady)
assign ReissueCache2coreRespDataQ105H = SampleDMemReady ? Cache2coreRespDataQ105H : LastCache2coreRespDataQ105H;
//`MAFIA_EN_DFF(ReissueCache2coreRespDataQ105H, Cache2coreRespDataQ105H, Clock , 1'b1)


endmodule