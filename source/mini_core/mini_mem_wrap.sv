//-----------------------------------------------------------------------------
// Title            : data memory - Behavioral
// Project          : gpc_4t
//-----------------------------------------------------------------------------
// File             : mini_mem_wrap.sv
// Original Author  : Amichai Ben-David
// Created          : 1/2020
//-----------------------------------------------------------------------------
// Description :
// Behavioral duel read duel write memory
//------------------------------------------------------------------------------
// Modification history :
//------------------------------------------------------------------------------

`include "macros.sv"

//---------------------------------------------------
module mini_mem_wrap
import mini_core_pkg::*;
import router_pkg::*;
import common_pkg::*;
(
                input  logic        Clock  ,
                input  logic        Rst    ,
                input  t_tile_id    local_tile_id,
                //============================================
                //      core interface
                //============================================
                //     i_mem
                //============================================
                input  logic [31:0] PcQ100H,             //cur_pc    ,
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
                input  logic        InFabricValidQ503H    ,
                input  t_tile_trans InFabricQ503H    ,
                output t_tile_trans OutFabricQ505H   ,
                output t_tile_trans OutFabricValidQ505H   ,
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
// Set the F2C IMEM hit indications
assign F2C_IMemHitQ503H  = (F2C_ReqAddressQ503H[MSB_REGION:LSB_REGION] > I_MEM_REGION_FLOOR) && 
                           (F2C_ReqAddressQ503H[MSB_REGION:LSB_REGION] < I_MEM_REGION_ROOF) ;
assign F2C_IMemWrEnQ503H = F2C_IMemHitQ503H && F2C_ReqValidQ503H && (F2C_ReqOpcodeQ503H == WR_REQ);
// Set the F2C DMEM hit indications
assign F2C_DMemHitQ503H  = (F2C_ReqAddressQ503H[MSB_REGION:LSB_REGION] > D_MEM_REGION_FLOOR) && 
                           (F2C_ReqAddressQ503H[MSB_REGION:LSB_REGION] < D_MEM_REGION_ROOF) ;
assign F2C_DMemWrEnQ503H = F2C_DMemHitQ503H && F2C_ReqValidQ503H && (F2C_ReqOpcodeQ503H == WR_REQ);
// Set the F2C CrMEM hit indications
assign F2C_CrMemHitQ503H  = 1'b0; //FIXME - Add CR_MEM offset hit indication
assign F2C_CrMemWrEnQ503H =  1'b0; //FIXME - Add CR_MEM offset hit indication

//==================================
// Instruction Memory
//==================================
//This is the instruction memory
mem  #(
  .WORD_WIDTH(32),  //FIXME - Parametrize!!
  .ADRS_WIDTH(13)   //FIXME - Parametrize!!
) i_mem  (
    .clock    (Clock),
    //Core interface (instruction fitch)
    .address_a  (PcQ100H[14:2]),           //FIXME - Parametrize!!
    .data_a     ('0),
    .wren_a     (1'b0),
    .byteena_a  (4'b0),
    .q_a        (PreInstructionQ101H),
    //fabric interface
    .address_b  (F2C_ReqAddressQ503H[14:2]),//FIXME - Parametrize!!
    .data_b     (F2C_ReqDataQ503H),              
    .wren_b     (F2C_IMemWrEnQ503H),                
    .byteena_b  (4'b1111),
    .q_b        (F2C_IMemRspDataQ504H)              
    );

//==================================
// DATA Memory
//==================================
mem   
#(.WORD_WIDTH(32),//FIXME - Parametrize!!
  .ADRS_WIDTH(14) //FIXME - Parametrize!!
) d_mem  (
    .clock    (Clock),
    //Core interface (instruction fitch)
    .address_a  (DMemAddressQ103H[15:2]),//FIXME - Parametrize!!
    .data_a     (DMemWrDataQ103H),
    .wren_a     (DMemWrEnQ103H),
    .byteena_a  (DMemByteEnQ103H),
    .q_a        (DMemRdRspQ104H),
    //fabric interface
    .address_b  (F2C_ReqAddressQ503H[15:2]),//FIXME - Parametrize!!
    .data_b     (F2C_ReqDataQ503H),              
    .wren_b     (F2C_DMemWrEnQ503H),                
    .byteena_b  (4'b1111),
    .q_b        (F2C_DMemRspDataQ504H)              
    );

//==================================
// F2C response 504 ( D_MEM/I_MEM )
//==================================
assign F2C_RspDataQ504H   = F2C_CrMemHitQ503H ? F2C_CrMemRspDataQ504H : //CR hit is the highest priority
                            F2C_IMemHitQ503H  ? F2C_IMemRspDataQ504H  :
                            F2C_DMemHitQ503H  ? F2C_DMemRspDataQ504H  :
                                               '0                     ;
`MAFIA_DFF(F2C_RspValidQ504H, F2C_ReqValidQ503H, Clock)

t_tile_trans OutFabricQ504H;
logic [31:0] F2C_RdRspAddressQ503H;
assign F2C_InFabricValidQ503H = InFabricValidQ503H && (InFabricQ503H.opcode == RD);
assign F2C_InFabricQ503H      = F2C_InFabricValidQ503H   ?  InFabricQ503H  :  '0;
// Set the target address to the requestor id (This is the Read response address)
assign F2C_RdRspAddressQ503H = {F2C_InFabricQ503H.requestor_id[7:0],F2C_InFabricQ503H.address[23:0]};
`MAFIA_DFF(F2C_OutFabricValidQ504H                 , F2C_InFabricValidQ503H  , Clock)
`MAFIA_DFF(F2C_OutFabricQ504H.address              , F2C_RdRspAddressQ503H   , Clock) 
`MAFIA_DFF(F2C_OutFabricQ504H.opcode               , RD_RSP                  , Clock)
`MAFIA_DFF(F2C_OutFabricQ504H.data                 , F2C_RspDataQ504H        , Clock)
`MAFIA_DFF(F2C_OutFabricQ504H.requestor_id         , local_tile_id           , Clock)// The requestor id is the local tile id
`MAFIA_DFF(F2C_OutFabricQ504H.next_tile_fifo_arb_id, '0                      , Clock)


//==================================
// Mux out Fabric Access Response/Request
//==================================
// We may have multiple transaction trying to access the fabric
// 1. A read response to fabric 
// 2. read/write request from the core the needs to access the fabric (a non local read/write)
// we solve this by using a fifo to accumulate the different transactions and use an arbiter to choose between them.
// and we can start back pressure the core/fabric if the corresponding fifo is full.
//==================================
// F2C FIFO - accumulate read responses to the fabric (A response to a Fabric 2 Core read request)
//==================================
// a FIFO to accumulate the read responses to the fabric
fifo #(.DATA_WIDTH($bits(t_tile_trans)),.FIFO_DEPTH(2))
f2c_rsp_fifo  (.clk       (Clock),
               .rst       (Rst),
               .push      (F2C_OutFabricValidQ504H),  // input
               .push_data (F2C_OutFabricQ504H),       // input
               .pop       (F2C_OutFabricValidQ505H),  // input
               .pop_data  (F2C_OutFabricQ505H),       // output
               .full      (F2C_RspFull),              // output
               .empty     (F2C_RspEmpty)              // output
               );// indication to arbiter that the fifo is empty

//==================================
// C2F FIFO - accumulate core 2 Fabric requests
//==================================
// a FIFO to accumulate the requests from the core to the fabric
fifo #(.DATA_WIDTH($bits(t_tile_trans)),.FIFO_DEPTH(2))
c2f_req_fifo  (.clk       (Clock),
               .rst       (Rst),
               .push      (), // valid_alloc_req#
               .push_data (),// alloc_req#
               .pop       (),//arbiter chose this fifo to pop.
               .pop_data  (), // arbiter input
               .full      (),//out_ready_fifo#
               .empty     ()
               );// indication to arbiter that the fifo is empty



endmodule
