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
import common_pkg::*;
(   input  logic        Clk,
    input  logic        Rst,
    input  t_tile_id    local_tile_id,
    //
    input  logic [31:0] PcQ100H,          // I_MEM
    output logic [31:0] InstructionQ101H, // I_MEM
    input  logic [31:0] DMemWrDataQ103H,  // D_MEM
    input  logic [31:0] DMemAddressQ103H, // D_MEM
    input  logic [3:0]  DMemByteEnQ103H,  // D_MEM
    input  logic        DMemWrEnQ103H,    // D_MEM
    input  logic        DMemRdEnQ103H,    // D_MEM
    output logic [31:0] DMemRdRspQ104H,   // D_MEM
    // Fabric interface
    input  logic            InFabricValidQ503H  ,
    input  var t_tile_trans InFabricQ503H       ,
    output logic            OutFabricValidQ505H ,
    output var t_tile_trans OutFabricQ505H      ,
    // FPGA interface inputs              
    input  var t_fpga_in   fpga_in,
    // FPGA interface outputs
    output t_fpga_out  fpga_out,          // CR_MEM output to FPGA
    output logic       inDisplayArea,
    output t_vga_out   vga_out            // VGA output to FPGA
);

//===========================================
//    set F2C request 503 ( D_MEM )
//===========================================
// Set the F2C IMEM hit indications
logic F2C_IMemHitQ503H, F2C_IMemWrEnQ503H, F2C_IMemHitQ504H;
logic F2C_DMemHitQ503H, F2C_DMemWrEnQ503H, F2C_DMemHitQ504H;
logic F2C_CrMemHitQ503H, F2C_CrMemWrEnQ503H, F2C_CrMemHitQ504H;
logic [31:0] F2C_IMemRspDataQ504H;
logic [31:0] F2C_DMemRspDataQ504H;
assign F2C_IMemHitQ503H  = (InFabricQ503H.address[MSB_REGION:LSB_REGION] >= I_MEM_REGION_FLOOR) && 
                           (InFabricQ503H.address[MSB_REGION:LSB_REGION] < I_MEM_REGION_ROOF) ;
assign F2C_IMemWrEnQ503H = F2C_IMemHitQ503H && InFabricValidQ503H && (InFabricQ503H.opcode == WR);
// Set the F2C DMEM hit indications
assign F2C_DMemHitQ503H  = (InFabricQ503H.address[MSB_REGION:LSB_REGION] >= D_MEM_REGION_FLOOR) && 
                           (InFabricQ503H.address[MSB_REGION:LSB_REGION] < D_MEM_REGION_ROOF) ;
assign F2C_DMemWrEnQ503H = F2C_DMemHitQ503H && InFabricValidQ503H && (InFabricQ503H.opcode == WR);
// Set the F2C CrMEM hit indications
assign F2C_CrMemHitQ503H  = (InFabricQ503H.address[MSB_REGION:LSB_REGION] >= CR_MEM_REGION_FLOOR) && 
                            (InFabricQ503H.address[MSB_REGION:LSB_REGION] < CR_MEM_REGION_ROOF) ;
assign F2C_CrMemWrEnQ503H = F2C_CrMemHitQ503H && InFabricValidQ503H && (InFabricQ503H.opcode == WR);





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

logic [31:0] F2C_RspDataQ504H;
logic [31:0] F2C_CrMemRspDataQ504H;
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


//===========================================
// Instruction Memory
//===========================================
i_mem     i_mem (
    .clock      ( Clk ),
    //Core interface
    .address_a  ( PcQ100H[31:2] ),
    .data_a     ( '0 ),
    .wren_a     ( '0 ),
    .q_a        ( InstructionQ101H ),
    //IO interface
    .address_b  (InFabricQ503H.address[31:2]),
    .data_b     (InFabricQ503H.data),
    .wren_b     (F2C_IMemWrEnQ503H),
    .q_b        (F2C_IMemRspDataQ504H)
);
// `endif  


//===========================================
// Data Memory
//===========================================
// Instantiating the mafia_asap_5pl_d_mem data memory
// Please note: from HW perspective, the offset is '0' (and not 64KB) so the data is aligned to the LSB
// currently in simulation we are actually using the 64KB offset, but in the FPGA we are using the '0' offset - which happens automatically due to the MSB cutoff
 d_mem d_mem (
    .clock            (Clk),
    //Core interface
    .data_a           (ShiftDMemWrDataQ103H),
    .address_a        (DMemAddressQ103H[31:2]), //The address cuts off the MSB in bit [15] when working in 64k - need to make sure we understand this correctly
    .byteena_a        (ShiftDMemByteEnQ103H),
    .wren_a           (DMemWrEnQ103H && MatchDMemRegionQ103H),
    .q_a              (PreShiftDMemRdDataQ104H),
    //Fabric access interface
    .data_b           (InFabricQ503H.data),
    .address_b        (InFabricQ503H.address[31:2]),
    .byteena_b        (4'b1111), //FIXME need to add byte enable from the fabric
    .wren_b           (F2C_DMemWrEnQ503H),
    .q_b              (F2C_DMemRspDataQ504H)
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
    //Fabric access interface
    .data_b           (InFabricQ503H.data),
    .address_b        (InFabricQ503H.address),
    .wren_b           (F2C_CrMemWrEnQ503H),
    .q_b              (F2C_CrMemRspDataQ504H),
    // FPGA interface
    .fpga_in          (fpga_in),  
    .fpga_out         (fpga_out)
);


//assign vga_out = '0;// Instantiating the mafia_asap_5pl_vga_ctrl
logic [31:0] VgaAddressWithOffsetQ103H;
logic [31:0] PreShiftVGAMemRdDataQ104H;

assign VgaAddressWithOffsetQ103H = DMemAddressQ103H - VGA_MEM_REGION_FLOOR;
logic [31:0]  VgaWrData;
logic [31:0]  VgaAdrsReq;
logic [3:0]   VgaWrBE;
logic         VgaWrEn;
assign VgaWrData    = ShiftDMemWrDataQ103H;
assign VgaAdrsReq   = VgaAddressWithOffsetQ103H;
assign VgaWrBE      = ShiftDMemByteEnQ103H;
assign VgaWrEn      = DMemWrEnQ103H && MatchVGAMemRegionQ103H;

big_core_vga_ctrl big_core_vga_ctrl (
   .CLK_50            (Clk),
   .Reset             (Rst),
   // Core interface
   // write
   .ReqDataQ503H       (VgaWrData),
   .ReqAddressQ503H    (VgaAdrsReq),
   .CtrlVGAMemByteEn   (VgaWrBE),
   .CtrlVgaMemWrEnQ503 (DMemWrEnQ103H && MatchVGAMemRegionQ103H),
   // read
   .CtrlVgaMemRdEnQ503 (VgaWrEn),
   .VgaRspDataQ504H    (PreShiftVGAMemRdDataQ104H),
   // VGA output
   .inDisplayArea     (inDisplayArea),
   .RED               (vga_out.VGA_R),
   .GREEN             (vga_out.VGA_G),
   .BLUE              (vga_out.VGA_B),
   .h_sync            (vga_out.VGA_HS),
   .v_sync            (vga_out.VGA_VS)
);

// Half & Byte READ
assign PreVGAMemRdDataQ104H = (DMemAddressQ104H[1:0] == 2'b01) ? { 8'b0,PreShiftVGAMemRdDataQ104H[31:8] } : 
                              (DMemAddressQ104H[1:0] == 2'b10) ? {16'b0,PreShiftVGAMemRdDataQ104H[31:16]} : 
                              (DMemAddressQ104H[1:0] == 2'b11) ? {24'b0,PreShiftVGAMemRdDataQ104H[31:24]} : 
                                                                        PreShiftVGAMemRdDataQ104H         ; 

//==================================
// F2C response 504 ( D_MEM/I_MEM )
//==================================
`MAFIA_DFF(F2C_IMemHitQ504H , F2C_IMemHitQ503H , Clk)
`MAFIA_DFF(F2C_DMemHitQ504H , F2C_DMemHitQ503H , Clk)
`MAFIA_DFF(F2C_CrMemHitQ504H, F2C_CrMemHitQ503H, Clk)
assign F2C_RspDataQ504H   = F2C_CrMemHitQ504H ? F2C_CrMemRspDataQ504H : //CR hit is the highest priority
                            F2C_IMemHitQ504H  ? F2C_IMemRspDataQ504H  :
                            F2C_DMemHitQ504H  ? F2C_DMemRspDataQ504H  :
                                               '0                     ;

logic F2C_OutFabricValidQ503H, F2C_OutFabricValidQ504H;
logic [31:0] F2C_RdRspAddressQ503H;
t_tile_trans F2C_InFabricQ503H;
assign F2C_OutFabricValidQ503H =  (InFabricValidQ503H && (InFabricQ503H.opcode == RD));
assign F2C_InFabricQ503H       = F2C_OutFabricValidQ503H   ?  InFabricQ503H  :  '0;
// Set the target address to the requestor id (This is the Read response address)
assign F2C_RdRspAddressQ503H = {F2C_InFabricQ503H.requestor_id[7:0],F2C_InFabricQ503H.address[23:0]};
`MAFIA_DFF(OutFabricValidQ505H                 , F2C_OutFabricValidQ503H , Clk)
`MAFIA_DFF(OutFabricQ505H.address              , F2C_RdRspAddressQ503H   , Clk) 
`MAFIA_DFF(OutFabricQ505H.opcode               , RD_RSP                  , Clk)
`MAFIA_DFF(OutFabricQ505H.data                 , F2C_RspDataQ504H        , Clk)
`MAFIA_DFF(OutFabricQ505H.requestor_id         , local_tile_id           , Clk) // The requestor id is the local tile id
`MAFIA_DFF(OutFabricQ505H.next_tile_fifo_arb_id, NULL_CARDINAL           , Clk) // will be overwritten in the tile
endmodule // Module mafia_asap_5pl_mem_wrap
