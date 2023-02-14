//-----------------------------------------------------------------------------
// Title            : Risc-V Many Core mesh FPGA
// Project          : fpga_mafia
//-----------------------------------------------------------------------------
// File             : big_core_mem_wrap
// Original Author  : Daniel Kaufman
// Code Owner       : 
// Adviser          : Amichai Ben-David
// Created          : 12/2022
//-----------------------------------------------------------------------------
// Description :
// This module serves as the memory of the core. This module contains data memory,
// instruction memory and control registers memory.
// I_MEM, D_MEM and CR_MEM will support sync memory read.
`include "macros.sv"
module big_core_mem_wrap 
    import big_core_pkg::*;
(   input  logic        Clk,
    input  logic        Rst,
    input  logic [31:0] PcQ100H,          // I_MEM
    output logic [31:0] InstructionQ101H, // I_MEM
    input  logic [31:0] DMemWrDataQ103H,  // D_MEM
    input  logic [31:0] DMemAddressQ103H, // D_MEM
    input  logic [3:0]  DMemByteEnQ103H,  // D_MEM
    input  logic        DMemWrEnQ103H,    // D_MEM
    input  logic        DMemRdEnQ103H,    // D_MEM
    output logic [31:0] DMemRdRspQ104H,   // D_MEM
    // FPGA interface inputs              
    input  logic       Button_0,          // CR_MEM
    input  logic       Button_1,          // CR_MEM
    input  logic [9:0] Switch,            // CR_MEM
    // FPGA interface outputs
    output logic [7:0] SEG7_0,            // CR_MEM
    output logic [7:0] SEG7_1,            // CR_MEM
    output logic [7:0] SEG7_2,            // CR_MEM
    output logic [7:0] SEG7_3,            // CR_MEM
    output logic [7:0] SEG7_4,            // CR_MEM
    output logic [7:0] SEG7_5,            // CR_MEM
    output logic [9:0] LED,               // CR_MEM
    // VGA output
    output logic [3:0]  RED,
    output logic [3:0]  GREEN,
    output logic [3:0]  BLUE,
    output logic        h_sync,
    output logic        v_sync
);

// Control signals
logic MatchDMemRegionQ103H,   MatchDMemRegionQ104H;
logic MatchCRMemRegionQ103H,  MatchCRMemRegionQ104H;
logic MatchVGAMemRegionQ103H, MatchVGAMemRegionQ104H;
logic [31:0] DMemAddressQ104H;
logic [31:0] PreDMemRdDataQ104H;
logic [31:0] PreShiftDMemRdDataQ104H;
logic [31:0] DMemRdDataQ104H;
logic [31:0] ShiftDMemWrDataQ103H;
logic [3:0]  ShiftDMemByteEnQ103H;
logic [31:0] PreCRMemRdDataQ104H;
logic [31:0] PreVGAMemRdDataQ104H;

always_comb begin
    MatchVGAMemRegionQ103H = ((DMemAddressQ103H[VGA_MSB_REGION:LSB_REGION] >= VGA_MEM_REGION_FLOOR) && (DMemAddressQ103H[VGA_MSB_REGION:LSB_REGION] <= VGA_MEM_REGION_ROOF));
    MatchDMemRegionQ103H   = MatchVGAMemRegionQ103H ? 1'b0 : ((DMemAddressQ103H[MSB_REGION:LSB_REGION] >= D_MEM_REGION_FLOOR) && (DMemAddressQ103H[MSB_REGION:LSB_REGION] <= D_MEM_REGION_ROOF));
    MatchCRMemRegionQ103H  = MatchVGAMemRegionQ103H ? 1'b0 : ((DMemAddressQ103H[MSB_REGION:LSB_REGION] >= CR_MEM_REGION_FLOOR) && (DMemAddressQ103H[MSB_REGION:LSB_REGION] <= CR_MEM_REGION_ROOF));
end

// Q103H to Q104H Flip Flops
`MAFIA_DFF(MatchDMemRegionQ104H   , MatchDMemRegionQ103H    , Clk)
`MAFIA_DFF(MatchCRMemRegionQ104H  , MatchCRMemRegionQ103H   , Clk)
`MAFIA_DFF(MatchVGAMemRegionQ104H , MatchVGAMemRegionQ103H  , Clk)
`MAFIA_DFF(DMemAddressQ104H       , DMemAddressQ103H        , Clk)

// Mux between CR ,data and vga memory
assign DMemRdRspQ104H= MatchCRMemRegionQ104H  ? PreCRMemRdDataQ104H  :
                       MatchDMemRegionQ104H   ? PreDMemRdDataQ104H   :
                       MatchVGAMemRegionQ104H ? PreVGAMemRdDataQ104H :
                                                32'b0                ;
// Half & Byte Write
always_comb begin
ShiftDMemWrDataQ103H = (DMemAddressQ103H[1:0] == 2'b01 ) ? { DMemWrDataQ103H[23:0],8'b0  } :
                       (DMemAddressQ103H[1:0] == 2'b10 ) ? { DMemWrDataQ103H[15:0],16'b0 } :
                       (DMemAddressQ103H[1:0] == 2'b11 ) ? { DMemWrDataQ103H[7:0] ,24'b0 } :
                                                             DMemWrDataQ103H;
ShiftDMemByteEnQ103H = (DMemAddressQ103H[1:0] == 2'b01 ) ? { DMemByteEnQ103H[2:0],1'b0 } :
                       (DMemAddressQ103H[1:0] == 2'b10 ) ? { DMemByteEnQ103H[1:0],2'b0 } :
                       (DMemAddressQ103H[1:0] == 2'b11 ) ? { DMemByteEnQ103H[0]  ,3'b0 } :
                                                             DMemByteEnQ103H;
end               

// Half & Byte READ
assign PreDMemRdDataQ104H = (DMemAddressQ104H[1:0] == 2'b01) ? { 8'b0,PreShiftDMemRdDataQ104H[31:8] } : 
                            (DMemAddressQ104H[1:0] == 2'b10) ? {16'b0,PreShiftDMemRdDataQ104H[31:16]} : 
                            (DMemAddressQ104H[1:0] == 2'b11) ? {24'b0,PreShiftDMemRdDataQ104H[31:24]} : 
                                                                      PreShiftDMemRdDataQ104H         ; 

// Instantiating the mafia_asap_5pl_i_mem instruction memory
i_mem i_mem (
    .Clk            (Clk),
    .address        (PcQ100H[31:2]),
    .q              (InstructionQ101H)
);

// Instantiating the mafia_asap_5pl_d_mem data memory

 d_mem d_mem (
    .Clk            (Clk),
    .data           (ShiftDMemWrDataQ103H),
    .address        (DMemAddressQ103H[31:2]),
    .byteena        (ShiftDMemByteEnQ103H),
    .wren           (DMemWrEnQ103H && MatchDMemRegionQ103H),
    .rden           (DMemRdEnQ103H && MatchDMemRegionQ103H),
    .q              (PreShiftDMemRdDataQ104H)
);


// Instantiating the mafia_asap_5pl_cr_mem data memory
//mafia_asap_5pl_cr_mem mafia_asap_5pl_cr_mem (
//    .Clk            (Clk),
//    .Rst              (Rst),
//    .data             (DMemWrDataQ103H),
//    .address          (DMemAddressQ103H),
//    .wren             (DMemWrEnQ103H && MatchCRMemRegionQ103H),
//    .rden             (DMemRdEnQ103H && MatchCRMemRegionQ103H),
//    .q                (PreCRMemRdDataQ104H),
//    .Button_0         (Button_0),
//    .Button_1         (Button_1),
//    .Switch           (Switch),
//    .SEG7_0           (SEG7_0),
//    .SEG7_1           (SEG7_1),
//    .SEG7_2           (SEG7_2),
//    .SEG7_3           (SEG7_3),
//    .SEG7_4           (SEG7_4),
//    .SEG7_5           (SEG7_5),
//    .LED              (LED)
//);

// Instantiating the mafia_asap_5pl_vga_ctrl
//mafia_asap_5pl_vga_ctrl mafia_asap_5pl_vga_ctrl (
//    .CLK_50            (Clk),
//    .Reset             (Rst),
//    .data              (DMemWrDataQ103H),
//    .address           (DMemAddressQ103H),
//    .byteena           (DMemByteEnQ103H),
//    .wren              (DMemWrEnQ103H && MatchVGAMemRegionQ103H),
//    .rden              (DMemRdEnQ103H && MatchVGAMemRegionQ103H),
//    .q                 (PreVGAMemRdDataQ104H),
//    .RED               (RED),
//    .GREEN             (GREEN),
//    .BLUE              (BLUE),
//    .h_sync            (h_sync),
//    .v_sync            (v_sync)
//);

endmodule // Module mafia_asap_5pl_mem_wrap
