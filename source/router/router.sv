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


`include "macros.sv"

module router
import router_pkg::*;
(
    input   logic                               clk,
    input   logic                               rst,
    input   logic       [MSB_ROW_ID:LSB_ROW_ID] local_tile_id
    // Tile interface
    input   logic        [MSB_TILE_IF:0]        valid_tile_trans_in, 
    input   t_tile_trans [MSB_TILE_IF:0]        tile_trans_in, 
    output  logic        [MSB_TILE_IF:0]        valid_tile_trans_out, 
    output  t_tile_trans [MSB_TILE_IF:0]        tile_trans_out, 
    // Tile ready
    output  logic        [MSB_TILE_IF:0]        fifo_ready_out [MSB_TILE_IF:0],
    input   logic        [MSB_TILE_IF:0]        fifo_ready_in  [MSB_TILE_IF:0],
    // Tile<->agent ready
    output  logic        [MSB_TILE_IF:0]        tile_agent_ready_out ,
    input   logic        [MSB_TILE_IF:0]        tile_agent_ready_in  ,
    // agent ready
    output  logic        [MSB_TILE_IF:0]        agent_ready_out ,
    input   logic        [MSB_TILE_IF:0]        agent_ready_in  ,
    // Agent interface
    input   t_tile_trans                        agent_trans_out,
    output  t_tile_trans                        agent_trans_in
);




//interface assignment to internal naming - FIXME probebly want to be genral once we figure the micro architecture
//======================================
// input
//======================================
assign valid_alloc_req_from_east  = valid_tile_trans_in[0];
assign valid_alloc_req_from_west  = valid_tile_trans_in[1];
assign valid_alloc_req_from_north = valid_tile_trans_in[2];
assign valid_alloc_req_from_south = valid_tile_trans_in[3];

assign alloc_req_from_east        = tile_trans_in[0];
assign alloc_req_from_west        = tile_trans_in[1];
assign alloc_req_from_south       = tile_trans_in[2];
assign alloc_req_from_local       = tile_trans_in[3];

//======================================
// output
//======================================
assign valid_tile_trans_out[0]    =  valid_winner_req_to_north;
assign valid_tile_trans_out[1]    =  '0;//FIXME
assign valid_tile_trans_out[2]    =  '0;//FIXME
assign valid_tile_trans_out[3]    =  '0;//FIXME

assign valid_tile_trans_out[0]    =  winner_req_to_north;
assign valid_tile_trans_out[1]    =  '0;//FIXME
assign valid_tile_trans_out[2]    =  '0;//FIXME
assign valid_tile_trans_out[3]    =  '0;//FIXME

//======================================
// input
//======================================
assign ready_fifo_from_north_arb_north = fifo_ready_in[0][0];
assign ready_fifo_from_north_arb_east  = fifo_ready_in[1][0];
assign ready_fifo_from_north_arb_west  = fifo_ready_in[2][0];
assign ready_fifo_from_north_arb_south = fifo_ready_in[3][0]; //error - should add assertion


assign ready_fifo_from_east_arb_north = fifo_ready_in[0][1];
assign ready_fifo_from_east_arb_east  = fifo_ready_in[1][1];
assign ready_fifo_from_east_arb_west  = fifo_ready_in[2][1];
assign ready_fifo_from_east_arb_south = fifo_ready_in[3][1];



assign ready_fifo_from_north_local     = ;
...
...

//======================================
// output
//======================================




assign fifo_ready_out[0][0] = '0;
assign fifo_ready_out[0][1] = '0;
assign fifo_ready_out[0][2] = '0;
assign fifo_ready_out[0][3] = '0;

assign fifo_ready_out[1][0] = ready_north_arb_fifo_to_east_tile;
assign fifo_ready_out[1][1] = '0;
assign fifo_ready_out[1][2] = '0;
assign fifo_ready_out[1][3] = '0;

assign fifo_ready_out[2][0] = ready_north_arb_fifo_to_south_tile;
assign fifo_ready_out[2][1] = '0;
assign fifo_ready_out[2][2] = '0;
assign fifo_ready_out[2][3] = '0;

assign fifo_ready_out[3][0] = ready_north_arb_fifo_to_west_tile;
assign fifo_ready_out[3][1] = '0;
assign fifo_ready_out[3][2] = '0;
assign fifo_ready_out[3][3] = '0;

//assign valid_alloc_req_from_local = 
//ready_fifo_to_local_tile_from_north_arb

// To determane if the request from east need to allocate an entry in the north fifo_arb:
assign east_req_destinitaion_is_north = (alloc_req_from_east.address[MSB_ROW_ID:LSB_ROW_ID] >  local_tile_id[MSB_ROW_ID:LSB_ROW_ID]);
assign east_req_destinitaion_is_south = (alloc_req_from_east.address[MSB_ROW_ID:LSB_ROW_ID] <  local_tile_id[MSB_ROW_ID:LSB_ROW_ID]);
assign east_req_destinitaion_is_east  = (alloc_req_from_east.address[MSB_COL_ID:LSB_COL_ID] >  local_tile_id[MSB_COL_ID:LSB_COL_ID]);
assign east_req_destinitaion_is_west  = (alloc_req_from_east.address[MSB_COL_ID:LSB_COL_ID] <  local_tile_id[MSB_COL_ID:LSB_COL_ID]);
//
assign east_req_hit_row               = (alloc_req_from_east.address[MSB_ROW_ID:LSB_ROW_ID] == local_tile_id[MSB_ROW_ID:LSB_ROW_ID]);
assign east_req_hit_col               = (alloc_req_from_east.address[MSB_COL_ID:LSB_COL_ID] == local_tile_id[MSB_COL_ID:LSB_COL_ID]);
assign east_req_is_to_local = east_req_hit_row && east_req_hit_col;

//naive approch - TODO review , first get to row, then go to Col
assign valid_alloc_req_from_east_to_north = valid_alloc_req_from_east && east_req_destinitaion_is_north; // mutext from the south
assign valid_alloc_req_from_east_to_south = valid_alloc_req_from_east && east_req_destinitaion_is_south; //mutex from the north
assign valid_alloc_req_from_east_to_west  = valid_alloc_req_from_east && east_req_destinitaion_is_west  && east_req_hit_row;
assign valid_alloc_req_from_east_to_east  = valid_alloc_req_from_east && east_req_destinitaion_is_east  && east_req_hit_row; //should not acoure!
assign valid_alloc_req_from_east_to_local = valid_alloc_req_from_east && east_req_is_to_local;                     


fifo_arb fifo_arb_north (
//global IO
.clk       (clk),
.rst       (rst),
//==============================
//  New alloc from neighber Tiles
//==============================
// Input
.valid_alloc_req0(valid_alloc_req_from_east_to_north),  //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.valid_alloc_req1(valid_alloc_req_from_west_to_north),  //input
.valid_alloc_req2(valid_alloc_req_from_south_to_north), //input
.valid_alloc_req3(valid_alloc_req_from_local_to_north), //input
.alloc_req0      (alloc_req_from_east),  //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req1      (alloc_req_from_west),  //input
.alloc_req2      (alloc_req_from_south), //input
.alloc_req3      (alloc_req_from_local), //input
// Output
.out_ready_fifo0(ready_north_arb_fifo_to_east_tile), //output
.out_ready_fifo1(ready_north_arb_fifo_to_west_tile), //output
.out_ready_fifo2(ready_north_arb_fifo_to_south_tile),//output
.out_ready_fifo2(ready_north_arb_fifo_to_local_tile),//output
//==============================
//  Output to next north tile
//==============================
// Output
.valid_winner_req(valid_winner_req_to_north),
.winner_req      (winner_req_to_north),
// Input
.in_ready_arb_fifo0(ready_fifo_from_north_arb_east), //input
.in_ready_arb_fifo1(ready_fifo_from_north_arb_west), //input
.in_ready_arb_fifo2(ready_fifo_from_north_arb_north),//input
.in_ready_arb_fifo3(ready_fifo_from_north_local)     //input
);


//NOTE - Dont code the other arbiter yet!



endmodule // Module rvc_asap_5pl
