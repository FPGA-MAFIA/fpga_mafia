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
    output t_fpga_out  fpga_out,          // CR_MEM output to FPGA
    output t_vga_out   vga_out            // VGA output to FPGA
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
//`assign PreVGAMemRdDataQ104H ='0;
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
// `ifdef SIM_ONLY
// i_mem i_mem (
//     .Clk            (Clk),
//     .address        (PcQ100H[31:2]),
//     .q              (InstructionQ101H)
// );
// `else 
i_mem	i_mem (
    .clock      ( Clk ),
    //Core interface
    .address_a  ( PcQ100H[31:2] ),
    .data_a     ( '0 ),
    .wren_a     ( '0 ),
    .q_a        ( InstructionQ101H ),
    //IO interface
    .address_b  ( '0 ),
    .data_b     ( '0),
    .wren_b     ( '0 ),
    .q_b        ( )
);
// `endif  


// Instantiating the mafia_asap_5pl_d_mem data memory

 d_mem d_mem (
    .clock            (Clk),
    //Core interface
    .data_a           (ShiftDMemWrDataQ103H),
    .address_a        (DMemAddressQ103H[31:2]),
    .byteena_a        (ShiftDMemByteEnQ103H),
    .wren_a           (DMemWrEnQ103H && MatchDMemRegionQ103H),
    .q_a              (PreShiftDMemRdDataQ104H),
    //Fabric access interface
    .data_b           ('0),
    .address_b        ('0),
    .byteena_b        ('0),
    .wren_b           ('0),
    .q_b              ()
);



// Instantiating the mafia_asap_5pl_cr_mem data memory
big_core_cr_mem big_core_cr_mem (
    .Clk              (Clk),
    .Rst              (Rst),
    .data             (DMemWrDataQ103H),
    .address          (DMemAddressQ103H),
    .wren             (DMemWrEnQ103H && MatchCRMemRegionQ103H),
    .rden             (DMemRdEnQ103H && MatchCRMemRegionQ103H),
    .q                (PreCRMemRdDataQ104H),
    .Button_0         (Button_0),
    .Button_1         (Button_1),
    .Switch           (Switch),
    .fpga_out         (fpga_out)
);


//assign vga_out = '0;// Instantiating the mafia_asap_5pl_vga_ctrl
logic [31:0] VgaAddressWithOffsetQ103H;
assign VgaAddressWithOffsetQ103H = DMemAddressQ103H - VGA_MEM_REGION_FLOOR;
big_core_vga_ctrl big_core_vga_ctrl (
   .CLK_50            (Clk),
   .Reset             (Rst),
   // Core interface
   // write
   .F2C_ReqDataQ503H   (DMemWrDataQ103H),
   .F2C_ReqAddressQ503H(VgaAddressWithOffsetQ103H),
   .CtrlVGAMemByteEn   (DMemByteEnQ103H),
   .CtrlVgaMemWrEnQ503 (DMemWrEnQ103H && MatchVGAMemRegionQ103H),
   // read
   .CtrlVgaMemRdEnQ503 (DMemRdEnQ103H && MatchVGAMemRegionQ103H),
   .VgaRspDataQ504H    (PreVGAMemRdDataQ104H),
   // VGA output
   .RED               (vga_out.VGA_R),
   .GREEN             (vga_out.VGA_G),
   .BLUE              (vga_out.VGA_B),
   .h_sync            (vga_out.VGA_HS),
   .v_sync            (vga_out.VGA_VS)
);

endmodule // Module mafia_asap_5pl_mem_wrap
