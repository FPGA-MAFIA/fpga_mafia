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
                input  logic [31:0] DMemWrDataQ103H , // To D_MEM
                input  logic [31:0] DMemAddressQ103H, // To D_MEM
                input  logic [3:0]  DMemByteEnQ103H , // To D_MEM
                input  logic        DMemWrEnQ103H   , // To D_MEM
                input  logic        DMemRdEnQ103H   , // To D_MEM
                output logic [31:0] DMemRdRspQ104H  , // From D_MEM
                //============================================
                //      fabric interface
                //============================================
                input  logic            InFabricValidQ503H  ,
                input  var t_tile_trans InFabricQ503H       ,
                output logic            OutFabricValidQ505H ,
                output var t_tile_trans OutFabricQ505H 
);

logic        F2C_IMemHitQ503H;
logic        F2C_IMemWrEnQ503H;
logic [31:0] F2C_IMemRspDataQ504H;

logic        F2C_DMemHitQ503H;
logic        F2C_DMemWrEnQ503H;
logic [31:0] F2C_DMemRspDataQ504H;

logic        F2C_CrMemHitQ503H;
logic        F2C_CrMemWrEnQ503H;

logic   F2C_CrMemHitQ504H;
logic   F2C_IMemHitQ504H ;
logic   F2C_DMemHitQ504H ;


t_tile_trans F2C_InFabricQ503H;

logic F2C_OutFabricValidQ505H;
t_tile_trans F2C_OutFabricQ505H;
//===========================================
//    set F2C request 503 ( D_MEM )
//===========================================
// Set the F2C IMEM hit indications
assign F2C_IMemHitQ503H  = (InFabricQ503H.address[MSB_REGION:LSB_REGION] > I_MEM_REGION_FLOOR) && 
                           (InFabricQ503H.address[MSB_REGION:LSB_REGION] < I_MEM_REGION_ROOF) ;
assign F2C_IMemWrEnQ503H = F2C_IMemHitQ503H && InFabricValidQ503H && (InFabricQ503H.opcode == WR);
// Set the F2C DMEM hit indications
assign F2C_DMemHitQ503H  = (InFabricQ503H.address[MSB_REGION:LSB_REGION] > D_MEM_REGION_FLOOR) && 
                           (InFabricQ503H.address[MSB_REGION:LSB_REGION] < D_MEM_REGION_ROOF) ;
assign F2C_DMemWrEnQ503H = F2C_DMemHitQ503H && InFabricValidQ503H && (InFabricQ503H.opcode == WR);
// Set the F2C CrMEM hit indications
assign F2C_CrMemHitQ503H  = 1'b0; //FIXME - Add CR_MEM offset hit indication
assign F2C_CrMemWrEnQ503H = 1'b0; //FIXME - Add CR_MEM offset hit indication

//==================================
// Instruction Memory
//==================================
//This is the instruction memory
mem  #(
  .WORD_WIDTH(32),                //FIXME - Parametrize!!
  .ADRS_WIDTH(I_MEM_ADRS_MSB+1)   //FIXME - Parametrize!!
) i_mem  (
    .clock    (Clock),
    //Core interface (instruction fitch)
    .address_a  (PcQ100H[I_MEM_ADRS_MSB:2]),           //FIXME - Parametrize!!
    .data_a     ('0),
    .wren_a     (1'b0),
    .byteena_a  (4'b0),
    .q_a        (PreInstructionQ101H),
    //fabric interface
    .address_b  (InFabricQ503H.address[I_MEM_ADRS_MSB:2]),//FIXME - Parametrize!!
    .data_b     (InFabricQ503H.data),              
    .wren_b     (F2C_IMemWrEnQ503H),                
    .byteena_b  (4'b1111), // NOTE no need to support byte enable for instruction memory
    .q_b        (F2C_IMemRspDataQ504H)              
    );

//==================================
// DATA Memory
//==================================
logic LocalDMemWrEnQ103H;
logic NonLocalDMemReqQ103H;
assign LocalDMemWrEnQ103H   = (DMemWrEnQ103H) && 
                              (DMemAddressQ103H[31:24] == local_tile_id) || (DMemAddressQ103H[31:24] == 8'b0);
// FIXME - need to "freeze" the core PC when reading a non local address
assign NonLocalDMemReqQ103H = (DMemWrEnQ103H || DMemRdEnQ103H) &&
                              (DMemAddressQ103H[31:24] != local_tile_id) && (DMemAddressQ103H[31:24] != 8'b0);
mem   
#(.WORD_WIDTH(32),//FIXME - Parametrize!!
  .ADRS_WIDTH(D_MEM_ADRS_MSB+1) //FIXME - Parametrize!!
) d_mem  (
    .clock    (Clock),
    //Core interface (instruction fitch)
    .address_a  (DMemAddressQ103H[D_MEM_ADRS_MSB:2]),//FIXME - Parametrize!!
    .data_a     (DMemWrDataQ103H),
    .wren_a     (LocalDMemWrEnQ103H),
    .byteena_a  (DMemByteEnQ103H),
    .q_a        (DMemRdRspQ104H),
    //fabric interface
    .address_b  (InFabricQ503H.address[D_MEM_ADRS_MSB:2]),//FIXME - Parametrize!!
    .data_b     (InFabricQ503H.data),              
    .wren_b     (F2C_DMemWrEnQ503H),                
    .byteena_b  (4'b1111),//FIXME - should accept the byte enable from the fabric
    .q_b        (F2C_DMemRspDataQ504H)              
    );

//==================================
// F2C response 504 ( D_MEM/I_MEM )
//==================================
logic [31:0] F2C_RspDataQ504H;
logic [31:0] F2C_CrMemRspDataQ504H;
assign F2C_CrMemRspDataQ504H = '0;
assign F2C_CrMemHitQ504H     = '0;
`MAFIA_DFF(F2C_IMemHitQ504H , F2C_IMemHitQ503H , Clock)
`MAFIA_DFF(F2C_DMemHitQ504H , F2C_DMemHitQ503H , Clock)

assign F2C_RspDataQ504H   = F2C_CrMemHitQ504H ? F2C_CrMemRspDataQ504H : //CR hit is the highest priority
                            F2C_IMemHitQ504H  ? F2C_IMemRspDataQ504H  :
                            F2C_DMemHitQ504H  ? F2C_DMemRspDataQ504H  :
                                               '0                     ;

logic F2C_OutFabricValidQ503H, F2C_OutFabricValidQ504H;
t_tile_trans F2C_OutFabricQ504H;
logic [31:0] F2C_RdRspAddressQ503H;
assign F2C_OutFabricValidQ503H =  (InFabricValidQ503H && (InFabricQ503H.opcode == RD));
assign F2C_InFabricQ503H       = F2C_OutFabricValidQ503H   ?  InFabricQ503H  :  '0;
// Set the target address to the requestor id (This is the Read response address)
assign F2C_RdRspAddressQ503H = {F2C_InFabricQ503H.requestor_id[7:0],F2C_InFabricQ503H.address[23:0]};
`MAFIA_DFF(F2C_OutFabricValidQ504H                 , F2C_OutFabricValidQ503H , Clock)
`MAFIA_DFF(F2C_OutFabricQ504H.address              , F2C_RdRspAddressQ503H   , Clock) 
`MAFIA_DFF(F2C_OutFabricQ504H.opcode               , RD_RSP                  , Clock)
`MAFIA_DFF(F2C_OutFabricQ504H.data                 , F2C_RspDataQ504H        , Clock)
`MAFIA_DFF(F2C_OutFabricQ504H.requestor_id         , local_tile_id           , Clock) // The requestor id is the local tile id
`MAFIA_DFF(F2C_OutFabricQ504H.next_tile_fifo_arb_id, NULL_CARDINAL           , Clock) //will be overwritten in the tile


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
logic F2C_RspFull, F2C_RspEmpty;
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
t_tile_trans  C2F_OutFabricQ104H;
t_tile_trans  C2F_ReqQ103H;
logic         C2F_ReqValidQ103H;
logic         C2F_OutFabricValidQ104H;
logic         C2F_ReqFull, C2F_ReqEmpty;
logic [1:0] winner_dec_id;
logic [1:0] valid_candidate;
assign C2F_ReqQ103H.address      = DMemAddressQ103H;
assign C2F_ReqQ103H.data         = DMemWrDataQ103H;
assign C2F_ReqQ103H.opcode       = DMemWrEnQ103H ? WR : RD;
assign C2F_ReqQ103H.requestor_id = local_tile_id;
assign C2F_ReqValidQ103H         = NonLocalDMemReqQ103H;

fifo #(.DATA_WIDTH($bits(t_tile_trans)),.FIFO_DEPTH(2))
c2f_req_fifo  (.clk       (Clock),
               .rst       (Rst),
               .push      (C2F_ReqValidQ103H),      //valid_alloc_req#
               .push_data (C2F_ReqQ103H),           //alloc_req#
               .pop       (C2F_OutFabricValidQ104H),//arbiter chose this fifo to pop.
               .pop_data  (C2F_OutFabricQ104H),     //arbiter input
               .full      (C2F_ReqFull),            //out_ready_fifo#
               .empty     (C2F_ReqEmpty)
               );// indication to arbiter that the fifo is empty


//==================================
// Arbiter - choose between the different transactions trying to access the fabric
//==================================
// The arbiter is a Round Robin arbiter 
assign valid_candidate[0] = !F2C_RspEmpty;  // add back pressure from the fabric
assign valid_candidate[1] = !C2F_ReqEmpty;  // add back pressure from the fabric
arbiter #(
    .NUM_CLIENTS        (2)
) u_arbiter (
    .clk                (Clock),
    .rst                (Rst),
    // ctrl path
    .valid_candidate    (valid_candidate),
    .winner_dec_id      (winner_dec_id)
);
assign F2C_OutFabricValidQ505H = winner_dec_id[0];
assign C2F_OutFabricValidQ104H = winner_dec_id[1];

assign OutFabricValidQ505H =  F2C_OutFabricValidQ505H | C2F_OutFabricValidQ104H;
assign OutFabricQ505H      =  F2C_OutFabricValidQ505H ? F2C_OutFabricQ505H :
                              C2F_OutFabricValidQ104H ? C2F_OutFabricQ104H :
                                                        '0;                 
endmodule
