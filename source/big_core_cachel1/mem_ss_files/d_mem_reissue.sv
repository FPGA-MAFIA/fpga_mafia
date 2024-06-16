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
    output logic [31:0]      ShiftVgaDMemWrDataQ103H,
    output logic [3:0]       ShiftVgaDMemByteEnQ103H,
    input  logic [31:0]      PreShiftVGAMemRdDataQ104H,
    // cache interface
    input logic  [31:0]      Cache2coreRespDataQ105,
    // response to core 
    output logic [31:0]      DMemRdRspQ105H
);


//====================================
// re-issue mechanism of cr region
//====================================
 logic [31:0] LastDataFromCRmemQ104H;
 logic [31:0] ReIssuedCrMemRdDataQ104H, ReIssuedCrMemRdDataQ105H;
 logic [31:0] ReIssuePreShiftVGAMemRdDataQ104H, ReIssuePreShiftVGAMemRdDataQ105H;
 logic        SampleCrmemReadyQ104H;
 
 // re issue flops
`MAFIA_DFF   (SampleCrmemReadyQ104H, DMemReady      , Clock)
`MAFIA_EN_DFF(LastDataFromCRmemQ104H, CRMemRdDataQ104H, Clock , SampleCrmemReadyQ104H)

 assign ReIssuedCrMemRdDataQ104H = SampleCrmemReadyQ104H ? CRMemRdDataQ104H : LastDataFromCRmemQ104H;

// pass data as is the next stage, no enable signal is needed
`MAFIA_DFF(ReIssuedCrMemRdDataQ105H, ReIssuedCrMemRdDataQ104H, Clock)


//====================================
// re-issue mechanism of vga region
//====================================

logic [31:0] LastDataFromVgamemQ104H;
logic        SampleVgamemReadyQ104H;

// re issue flops
`MAFIA_DFF   (SampleVgamemReadyQ104H, DMemReady      , Clock)
`MAFIA_EN_DFF(LastDataFromVgamemQ104H, PreShiftVGAMemRdDataQ104H, Clock , SampleVgamemReadyQ104H)

assign ReIssuePreShiftVGAMemRdDataQ104H = SampleVgamemReadyQ104H ? PreShiftVGAMemRdDataQ104H : LastDataFromVgamemQ104H;

// pass data as is to next stage no enable signal is needed
`MAFIA_DFF(ReIssuePreShiftVGAMemRdDataQ105H, ReIssuePreShiftVGAMemRdDataQ104H, Clock)



//====================================
// Shifting Vga Data and ByteEn
//====================================
// data goes to Vga must be shifted according to the alignment of 4bytes in a word
// Cr region do not need to be aligned cause we always write words (4 bytes)
// D_cache also need to be aligned but it has such unit inside the d_cache IP

t_core2mem_req Core2DmemReqQ104H, Core2DmemReqQ105H;

always_comb begin: shift_writen_data
ShiftVgaDMemWrDataQ103H = (Core2DmemReqQ103H.Address[1:0] == 2'b01 ) ? { Core2DmemReqQ103H.WrData[23:0],8'b0  } :
                          (Core2DmemReqQ103H.Address[1:0] == 2'b10 ) ? { Core2DmemReqQ103H.WrData[15:0],16'b0 } :
                          (Core2DmemReqQ103H.Address[1:0] == 2'b11 ) ? { Core2DmemReqQ103H.WrData[7:0] ,24'b0 } :
                                                                        Core2DmemReqQ103H.WrData;
ShiftVgaDMemByteEnQ103H = (Core2DmemReqQ103H.Address[1:0] == 2'b01 ) ? { Core2DmemReqQ103H.ByteEn[2:0],1'b0 } :
                          (Core2DmemReqQ103H.Address[1:0] == 2'b10 ) ? { Core2DmemReqQ103H.ByteEn[1:0],2'b0 } :
                          (Core2DmemReqQ103H.Address[1:0] == 2'b11 ) ? { Core2DmemReqQ103H.ByteEn[0]  ,3'b0 } :
                                                                        Core2DmemReqQ103H.ByteEn              ;
end


`MAFIA_EN_DFF(Core2DmemReqQ104H, Core2DmemReqQ103H, Clock ,  DMemReady)
`MAFIA_EN_DFF(Core2DmemReqQ105H, Core2DmemReqQ104H, Clock ,  DMemReady)

logic [31:0] ReIssueShiftVGAMemRdDataQ105H;
always_comb begin: shift_read_data
    ReIssueShiftVGAMemRdDataQ105H = ReIssuePreShiftVGAMemRdDataQ105H;
    if(MatchDmemRegionQ105H.MatchVgaRegion) begin
        ReIssueShiftVGAMemRdDataQ105H = (Core2DmemReqQ105H.Address[1:0] == 2'b01) ? { 8'b0,ReIssuePreShiftVGAMemRdDataQ105H[31:8] } : 
                                        (Core2DmemReqQ105H.Address[1:0] == 2'b10) ? {16'b0,ReIssuePreShiftVGAMemRdDataQ105H[31:16]} : 
                                        (Core2DmemReqQ105H.Address[1:0] == 2'b11) ? {24'b0,ReIssuePreShiftVGAMemRdDataQ105H[31:24]} : 
                                                                                     ReIssuePreShiftVGAMemRdDataQ105H               ;  
    end                       
end

//====================================
// Read Response to the core
//====================================
 
t_dmem_region MatchDmemRegionQ104H, MatchDmemRegionQ105H;
 
`MAFIA_EN_DFF(MatchDmemRegionQ104H.MatchCrRegion, MatchDmemRegionQ103H.MatchCrRegion, Clock, DMemReady) 
`MAFIA_EN_DFF(MatchDmemRegionQ105H.MatchCrRegion, MatchDmemRegionQ104H.MatchCrRegion, Clock, DMemReady)

`MAFIA_EN_DFF(MatchDmemRegionQ104H.MatchVgaRegion, MatchDmemRegionQ103H.MatchVgaRegion, Clock, DMemReady)
`MAFIA_EN_DFF(MatchDmemRegionQ105H.MatchVgaRegion, MatchDmemRegionQ104H.MatchVgaRegion, Clock, DMemReady)

assign DMemRdRspQ105H = MatchDmemRegionQ105H.MatchVgaRegion ? ReIssueShiftVGAMemRdDataQ105H :
                        MatchDmemRegionQ105H.MatchCrRegion  ? ReIssuedCrMemRdDataQ105H      :
                                                              Cache2coreRespDataQ105        ; 





endmodule