//-----------------------------------------------------------------------------
// Title            : data memory - Behavioral
// Project          : gpc_4t
//-----------------------------------------------------------------------------
// File             : mini_mem_wrap.sv
// Original Author  : Amichai Ben-David
// Created          : 1/2020
//-----------------------------------------------------------------------------
// Description :
// Behavioral duel read dueal write memory
//------------------------------------------------------------------------------
// Modification history :
//------------------------------------------------------------------------------

`include "macros.sv"

//---------------------------------------------------
module mini_mem_wrap
import mini_core_pkg::*;
(
                input  logic        Clock  ,
                input  logic        Rst    ,
                //============================================
                //      core interface
                //============================================
                //     i_mem
                //============================================
                input  logic [31:0] PcQ100H,        //curr_pc    ,
                output logic [31:0] PreInstructionQ101H, //instruction,
                //============================================
                //     d_mem
                //============================================
                input  logic [31:0] DMemWrDataQ103H,     // To D_MEM
                input  logic [31:0] DMemAddressQ103H,    // To D_MEM
                input  logic [3:0]  DMemByteEnQ103H,     // To D_MEM
                input  logic        DMemWrEnQ103H,       // To D_MEM
                output logic [31:0] DMemRdRspQ104H,      // From D_MEM
                //============================================
                //      fabric interface
                //============================================
                input  logic        F2C_ReqValidQ503H     ,
                input  t_fab_op     F2C_ReqOpcodeQ503H    ,
                input  logic [31:0] F2C_ReqAddressQ503H   ,
                input  logic [31:0] F2C_ReqDataQ503H      ,
                output logic        F2C_RspValidQ504H     , 
                output logic [31:0] F2C_RspDataQ504H 
);

logic        F2C_IMemHitQ503H;
logic        F2C_IMemWrEnQ503H;
logic [31:0] F2C_IMemRspDataQ504H;

logic        F2C_DMemHitQ503H;
logic        F2C_DMemWrEnQ503H;
logic [31:0] F2C_DMemRspDataQ504H;
//===========================================
//    set F2C request 503 ( D_MEM )
//===========================================
assign F2C_IMemHitQ503H  = (F2C_ReqAddressQ503H[MSB_REGION:LSB_REGION] > I_MEM_REGION_FLOOR) && 
                           (F2C_ReqAddressQ503H[MSB_REGION:LSB_REGION] < I_MEM_REGION_ROOF) ;
assign F2C_IMemWrEnQ503H = F2C_ReqValidQ503H && (F2C_ReqOpcodeQ503H == WR_REQ) && F2C_IMemHitQ503H;

assign F2C_DMemHitQ503H  =(F2C_ReqAddressQ503H[MSB_REGION:LSB_REGION] > D_MEM_REGION_FLOOR) && 
                          (F2C_ReqAddressQ503H[MSB_REGION:LSB_REGION] < D_MEM_REGION_ROOF) ;
assign F2C_DMemWrEnQ503H = F2C_ReqValidQ503H && (F2C_ReqOpcodeQ503H == WR_REQ) && F2C_DMemHitQ503H;

assign F2C_RspDataQ504H   = F2C_IMemHitQ503H ? F2C_IMemRspDataQ504H :
                            F2C_DMemHitQ503H ? F2C_DMemRspDataQ504H :
                                                '0                  ;

`RVC_DFF(F2C_RspValidQ504H, F2C_ReqValidQ503H, Clock)

mem  #(
  .WORD_WIDTH(32),
  .ADRS_WIDTH(12)
) i_mem  (
    .clock    (Clock),
    //Core interface (instruction fitch)
    .address_a  (PcQ100H[13:2]),
    .data_a     ('0),
    .wren_a     (1'b0),
    .byteena_a  (4'b0),
    .q_a        (PreInstructionQ101H),
    //fabric interface
    .address_b  (F2C_ReqAddressQ503H[13:2]),
    .data_b     (F2C_ReqDataQ503H),              
    .wren_b     (F2C_IMemWrEnQ503H),                
    .byteena_b  (4'b1111),
    .q_b        (F2C_IMemRspDataQ504H)              
    );

mem   
#(.WORD_WIDTH(32),
  .ADRS_WIDTH(12)
)
d_mem  (
    .clock    (Clock),
    //Core interface (instruction fitch)
    .address_a  (DMemAddressQ103H[13:2]),
    .data_a     (DMemWrDataQ103H),
    .wren_a     (DMemWrEnQ103H),
    .byteena_a  (DMemByteEnQ103H),
    .q_a        (DMemRdRspQ104H),
    //fabric interface
    .address_b  (F2C_ReqAddressQ503H[13:2]),
    .data_b     (F2C_ReqDataQ503H),              
    .wren_b     (F2C_DMemWrEnQ503H),                
    .byteena_b  (4'b1111),
    .q_b        (F2C_DMemRspDataQ504H)              
    );
endmodule
