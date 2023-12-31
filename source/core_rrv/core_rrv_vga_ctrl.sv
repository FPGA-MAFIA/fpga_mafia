//-----------------------------------------------------------------------------
// Title            : riscv as-fast-as-possible 
// Project          : rvc_asap
//-----------------------------------------------------------------------------
// File             : rvc_asap_5pl_vga_ctrl
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Adviser          : Amichai Ben-David
// Created          : 06/2022
//-----------------------------------------------------------------------------
// Description :
// This module serves as the vga controller of the architecture.
// This module include the vga memory and the logic necessary for its management.

`include "macros.sv"

module core_rrv_vga_ctrl 
import core_rrv_pkg::*;
(
    input  logic        Clk_50,
    input  logic        Reset,
    // VGA memory Access
    input  logic [31:0] ReqDataQ503H,
    input  logic [31:0] ReqAddressQ503H,
    input  logic [3:0]  CtrlVGAMemByteEn,
    input  logic        CtrlVgaMemWrEnQ503,
    // Read core
    input  logic        CtrlVgaMemRdEnQ503,
    output logic [31:0] VgaRspDataQ504H,
    // VGA output
    output logic        inDisplayArea,
    output logic [3:0]  RED,
    output logic [3:0]  GREEN,
    output logic [3:0]  BLUE,
    output logic        h_sync,
    output logic        v_sync
);

// Only One or the other (FPGA_ON vs SIMULATION_ON )
`ifndef SIMULATION_ON
    `define FPGA_ON    
`endif

logic [9:0]  pixel_y;
logic        Clk_25;
//logic        inDisplayArea;
logic        next_h_sync;
logic        next_v_sync;
logic [3:0]  NextRED;
logic [3:0]  NextGREEN;
logic [3:0]  NextBLUE;
logic        CurentPixelQ2;
logic [8:0]  LineQ0, LineQ1;
logic [31:0] RdDataQ2;
logic [4:0]  SampleReset;
logic [6:0]  HEX; 
logic [13:0] WordOffsetQ1;
logic [2:0]  CountBitOffsetQ1, CountBitOffsetQ2 ;
logic [1:0]  CountByteOffsetQ1, CountByteOffsetQ2;
logic [7:0]  CountWordOffsetQ1;
logic        EnCountBitOffset,  EnCountByteOffset,  EnCountWordOffset ;
logic        RstCountBitOffset, RstCountByteOffset, RstCountWordOffset;

//=========================
//Reset For Clk Simulation 
//=========================
assign SampleReset[0] = Reset;
`MAFIA_DFF(SampleReset[4:1], SampleReset[3:0], Clk_50)

//=========================
//gen Clock 25Mhz
//=========================
`MAFIA_RST_DFF(Clk_25, !Clk_25, Clk_50, Reset)

//=========================
// VGA sync Machine
//=========================
core_rrv_vga_sync_gen vga_sync_inst (
    .Clk_25         (Clk_25),          // input
    .Reset          (SampleReset[4]),  // input
    .vga_h_sync     (next_h_sync),     // output
    .vga_v_sync     (next_v_sync),     // output
    .CounterX       (),                // output
    .CounterY       (pixel_y),         // output
    .inDisplayArea  (inDisplayArea)    // output
);

//=========================
// VGA Display Line #
//=========================
assign LineQ0   = pixel_y[8:0];
`MAFIA_DFF(LineQ1 , LineQ0 , Clk_25)

//=========================
// Read CurrentPixelQ2 using VGA Virtual Address -> Physical Address in RAM
//=========================
assign EnCountByteOffset  = ((CountWordOffsetQ1 == 79) && EnCountWordOffset);
assign EnCountWordOffset  = (CountBitOffsetQ1 == 3'b111);
assign RstCountBitOffset  = SampleReset[4] || (!inDisplayArea);
assign RstCountByteOffset = SampleReset[4];
assign RstCountWordOffset = SampleReset[4] || ((CountWordOffsetQ1 == 8'd79) && EnCountWordOffset);
`MAFIA_RST_DFF   (CountBitOffsetQ1 , (CountBitOffsetQ1 +3'b01), Clk_25, RstCountBitOffset )
`MAFIA_EN_RST_DFF(CountByteOffsetQ1, (CountByteOffsetQ1+2'b01), Clk_25, EnCountByteOffset, RstCountByteOffset)
`MAFIA_EN_RST_DFF(CountWordOffsetQ1, (CountWordOffsetQ1+8'b01), Clk_25, EnCountWordOffset, RstCountWordOffset)

assign WordOffsetQ1 = ((LineQ1[8:2])*8'd80 + CountWordOffsetQ1);

// Align latency
`MAFIA_DFF(CountBitOffsetQ2  , CountBitOffsetQ1  , Clk_25)
`MAFIA_DFF(CountByteOffsetQ2 , CountByteOffsetQ1 , Clk_25)

assign CurentPixelQ2 = RdDataQ2[{CountByteOffsetQ2,CountBitOffsetQ2}];

//=========================
// VGA memory
//=========================
vga_mem vga_mem (
    .clock_a        (Clk_50),
    .clock_b        (Clk_25),
    // Write
    .data_a         (ReqDataQ503H),
    .address_a      (ReqAddressQ503H[31:2]),
    .byteena_a      (CtrlVGAMemByteEn),
    .wren_a         (CtrlVgaMemWrEnQ503),
    // Read from core`
    //.rden_a         (CtrlVgaMemRdEnQ503),
    .q_a            (VgaRspDataQ504H),
    // Read from vga controller
    .wren_b         ('0),
    .data_b         ('0),
    .address_b      (WordOffsetQ1), // Word offset (not Byte)
    .q_b            (RdDataQ2)
);


assign NextRED   = (inDisplayArea) ? {4{CurentPixelQ2}} : '0;
assign NextGREEN = (inDisplayArea) ? {4{CurentPixelQ2}} : '0;
assign NextBLUE  = (inDisplayArea) ? {4{CurentPixelQ2}} : '0;
`MAFIA_DFF(RED    , NextRED     ,Clk_25)
`MAFIA_DFF(GREEN  , NextGREEN   , Clk_25)
`MAFIA_DFF(BLUE   , NextBLUE    , Clk_25)
`MAFIA_DFF(h_sync , next_h_sync , Clk_25)
`MAFIA_DFF(v_sync , next_v_sync , Clk_25)

endmodule // Module rvc_asap_5pl_vga_ctrl