//-----------------------------------------------------------------------------
// Title            : riscv as-fast-as-possible 
// Project          : rvc_asap
//-----------------------------------------------------------------------------
// File             : rvc_asap_5pl 
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Adviser          : Amichai Ben-David
// Created          : 10/2021
//-----------------------------------------------------------------------------
// Description :
// This module will comtain a complite RISCV Core supportint the RV32I
// Will be implemented in a single cycle microarchitecture.
// The I_MEM & D_MEM will support async memory read. (This will allow the single-cycle arch)
// ---- 5 Pipeline Stages -----
// 1) Q100H Instruction Fetch
// 2) Q101H Instruction Decode 
// 3) Q102H Execute 
// 4) Q103H Memory Access
// 5) Q104H Write back data from Memory/ALU to Registerfile

`include "macros.sv"

module router 
import router_pkg::*;
(
    input   logic                        clk,
    input   logic                        rst,
    // Tile interface
    input   logic        [MSB_TILE_IF:0] valid_tile_trans_in, 
    input   t_tile_trans [MSB_TILE_IF:0] tile_trans_in, 
    output  logic        [MSB_TILE_IF:0] valid_tile_trans_out, 
    output  t_tile_trans [MSB_TILE_IF:0] tile_trans_out, 
    // Tile ready
    output  logic        [MSB_TILE_IF:0] fifo_ready_out [MSB_TILE_IF:0],
    input   logic        [MSB_TILE_IF:0] fifo_ready_in  [MSB_TILE_IF:0],
    // Tile<->agent ready
    output  logic        [MSB_TILE_IF:0] tile_agent_ready_out ,
    input   logic        [MSB_TILE_IF:0] tile_agent_ready_in  ,
    // agent ready
    output  logic        [MSB_TILE_IF:0] agent_ready_out ,
    input   logic        [MSB_TILE_IF:0] agent_ready_in  ,
    // Agent interface
    input   t_tile_trans                 agent_trans_out,
    output  t_tile_trans                 agent_trans_in
);

logic [1:0] out_sel [MSB_TILE_IF:0];


//genvar NUM_TILE_IO;
//generate for ( NUM_TILE_IO =0; NUM_TILE_IO < MSB_TILE_IF+1; NUM_TILE_IO++) begin
assign tile_trans_out[0] = (out_sel[0] == 2'd0) ? fifo_from0_to[0] :
                           (out_sel[0] == 2'd1) ? fifo_from1_to[0] :
                           (out_sel[0] == 2'd2) ? fifo_from2_to[0] :
                           (out_sel[0] == 2'd3) ? fifo_from3_to[0] :
                                                  '0 ;
//endgenerate

logic [MSB_TILE_IF:0] rr_candidate_to [MSB_TILE_IF:0];

//Cant connect a valid fifo from i->i
assign valid_fifo_from0_to[0] = '0;
assign valid_fifo_from1_to[1] = '0;
assign valid_fifo_from2_to[2] = '0;
assign valid_fifo_from3_to[3] = '0;


always_comb begin
//for(int i = 0; i< 4, i++) begin
  rr_candidate_to[0] = {valid_fifo_from3_to[0], valid_fifo_from2_to[0], valid_fifo_from1_to[0], valid_fifo_from0_to[0]}
  rr_candidate_to[1] = {valid_fifo_from3_to[1], valid_fifo_from2_to[1], valid_fifo_from1_to[1], valid_fifo_from0_to[1]}
  rr_candidate_to[2] = {valid_fifo_from3_to[2], valid_fifo_from2_to[2], valid_fifo_from1_to[2], valid_fifo_from0_to[2]}
  rr_candidate_to[3] = {valid_fifo_from3_to[3], valid_fifo_from2_to[3], valid_fifo_from1_to[3], valid_fifo_from0_to[3]}
//end //for
end //always_comb

round_robin round_robin_to_0(
  clk       (clk               ),
  rst       (rst               ),
  candidate (rr_candidate_to[0]),
  winner    (rr_winner_to[0]   )
);

`ENCODER(out_sel[0], out_sel_valid[0], rr_winner_to[0])

//Sample a new request into FIFO only if a new valid request && the fifo is ready for new request
always_comb begin
   en_fifo_from0_to[1] = valid_tile_trans_in[0] && (ready_fifo_from0_to[1] || (rr_winner_to[1] == 0) );
   en_fifo_from1_to[1] = 0;
   en_fifo_from2_to[1] = valid_tile_trans_in[2] && (ready_fifo_from2_to[1];
   en_fifo_from3_to[1] = valid_tile_trans_in[3] && (ready_fifo_from3_to[1];
end

`RVC_EN_DFF    (fifo_from0_to[1],       tile_trans_in[0],       clk, en_fifo_from0_to[1])
`RVC_EN_RST_DFF(valid_fifo_from0_to[1], valid_tile_trans_in[0], clk, en_fifo_from0_to[1] , rst)

endmodule // Module rvc_asap_5pl
