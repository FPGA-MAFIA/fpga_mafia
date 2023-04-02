//-----------------------------------------------------------------------------
// Title            : 4 way mesh router
// Project          : many_core_project
//-----------------------------------------------------------------------------
// File             : router.sv 
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Adviser          : Amichai Ben-David
// Created          : 2/2021
//-----------------------------------------------------------------------------


`include "macros.sv"
module router
import router_pkg::*;
(
    input   logic               clk,
    input   logic               rst,
    input   t_tile_id           local_tile_id,
    //========================================
    // North Interface
    //========================================
    // input request & output ready
    input   logic               in_north_req_valid,
    input   t_tile_trans            in_north_req,
    output  t_fab_ready         out_north_ready, // .east_arb, .west_arb, .south_arb
    // output request & input ready
    output  logic               out_north_req_valid,
    output  t_tile_trans            out_north_req,
    input   t_fab_ready         in_north_ready, // east_arb, west_arb, north_arb
    //========================================
    // East Interface
    //========================================
    // input request & output ready
    input   logic               in_east_req_valid,
    input   t_tile_trans            in_east_req,
    output  t_fab_ready         out_east_ready, // .north_arb, .west_arb, .south_arb
    // output request & input ready
    output  logic               out_east_req_valid,
    output  t_tile_trans            out_east_req,
    input   t_fab_ready         in_east_ready, // north_arb, east_arb, south_arb
    //========================================
    // West Interface
    //========================================
    // input request & output ready
    input   logic               in_west_req_valid,
    input   t_tile_trans            in_west_req,
    output  t_fab_ready         out_west_ready, // .north_arb, .east_arb, .south_arb
    // output request & input ready
    output  logic               out_west_req_valid,
    output  t_tile_trans            out_west_req,
    input   t_fab_ready         in_west_ready, // north_arb, west_arb, south_arb
    //========================================
    // South Interface
    //========================================
    // input request & output ready
    input   logic               in_south_req_valid,
    input   t_tile_trans            in_south_req,
    output  t_fab_ready         out_south_ready, // .north_arb, .east_arb, .west_arb
    // output request & input ready
    output  logic               out_south_req_valid,
    output  t_tile_trans            out_south_req,
    input   t_fab_ready         in_south_ready  // south_arb, east_arb, west_arb
);

//==============================
//  signals declaration
//==============================
logic in_north_req_valid_match_east;
logic in_north_req_valid_match_west;
logic in_north_req_valid_match_south;
logic in_east_req_valid_match_north;
logic in_east_req_valid_match_west;
logic in_east_req_valid_match_south;
logic in_west_req_valid_match_north;
logic in_west_req_valid_match_east;
logic in_west_req_valid_match_south;
logic in_south_req_valid_match_north;
logic in_south_req_valid_match_east;
logic in_south_req_valid_match_west;

//==============================
//  module content
//==============================

//==============================
//  The North FIFO Arbiter
//==============================
// Match request to North arbiter:
assign in_south_req_valid_match_north = in_south_req_valid && (in_south_req.next_tile_fifo_arb_id == NORTH);
assign in_east_req_valid_match_north  = in_east_req_valid  && (in_east_req.next_tile_fifo_arb_id  == NORTH);
assign in_west_req_valid_match_north  = in_west_req_valid  && (in_west_req.next_tile_fifo_arb_id  == NORTH);
fifo_arb fifo_arb_north (
//global IO
.clk       (clk),
.rst       (rst),
//==============================
//  New alloc from neighbor Tiles
//==============================
// Input
.valid_alloc_req0(in_south_req_valid_match_north),
.valid_alloc_req1(in_east_req_valid_match_north ),
.valid_alloc_req2(in_west_req_valid_match_north ),
.alloc_req0      (in_south_req), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req1      (in_east_req ), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req2      (in_west_req ), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
// Output
.out_ready_fifo0(out_south_ready.north_arb), //output
.out_ready_fifo1(out_east_ready.north_arb ), //output
.out_ready_fifo2(out_west_ready.north_arb ), //output
//==============================
//  Output to North tile
//==============================
// Output
.valid_winner_req(out_north_req_valid),
.winner_req      (out_north_req),
// Input
.in_ready_arb_fifo0(in_north_ready.north_arb),//input
.in_ready_arb_fifo1(in_north_ready.east_arb), //input
.in_ready_arb_fifo2(in_north_ready.west_arb), //input
);

//==============================
// The East FIFO Arbiter
//==============================
// Match request to East arbiter:
assign in_north_req_valid_match_east  = in_north_req_valid && (in_north_req.next_tile_fifo_arb_id == EAST);
assign in_south_req_valid_match_east  = in_south_req_valid && (in_south_req.next_tile_fifo_arb_id == EAST);
assign in_west_req_valid_match_east   = in_west_req_valid  && (in_west_req.next_tile_fifo_arb_id  == EAST);
fifo_arb fifo_arb_east (
//global IO
.clk       (clk),
.rst       (rst),
//==============================
//  New alloc from neighbor Tiles
//==============================
.valid_alloc_req0(in_north_req_valid_match_east),
.valid_alloc_req1(in_south_req_valid_match_east),
.valid_alloc_req2(in_west_req_valid_match_east),
.alloc_req0      (in_north_req), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req1      (in_south_req), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req2      (in_west_req),  //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
// Output
.out_ready_fifo0(out_north_ready.east_arb), //output
.out_ready_fifo1(out_south_ready.east_arb), //output
.out_ready_fifo2(out_west_ready.east_arb),  //output
//==============================
//  Output to East tile
//==============================
// Output
.valid_winner_req(out_east_req_valid),
.winner_req      (out_east_req),
// Input
.in_ready_arb_fifo0(in_east_ready.north_arb),//input
.in_ready_arb_fifo1(in_east_ready.south_arb),//input
.in_ready_arb_fifo2(in_east_ready.west_arb), //input
);


//==============================
//  The South FIFO Arbiter
//==============================
// Match request to South arbiter:
assign in_north_req_valid_match_south = in_north_req_valid && (in_north_req.next_tile_fifo_arb_id == SOUTH);
assign in_east_req_valid_match_south  = in_east_req_valid  && (in_east_req.next_tile_fifo_arb_id  == SOUTH);
assign in_west_req_valid_match_south  = in_west_req_valid  && (in_west_req.next_tile_fifo_arb_id  == SOUTH);
fifo_arb fifo_arb_south (
//global IO
.clk       (clk),
.rst       (rst),
//==============================
//  New alloc from neighbor Tiles
//==============================
.valid_alloc_req0(in_north_req_valid_match_south),
.valid_alloc_req1(in_east_req_valid_match_south ),
.valid_alloc_req2(in_west_req_valid_match_south ),
.alloc_req0      (in_north_req), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req1      (in_east_req ), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req2      (in_west_req ), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
// Output
.out_ready_fifo0(out_north_ready.south_arb), //output
.out_ready_fifo1(out_east_ready.south_arb ), //output
.out_ready_fifo2(out_west_ready.south_arb ), //output
//==============================
//  Output to South tile
//==============================
.valid_winner_req(out_south_req_valid),
.winner_req      (out_south_req),
// Input
.in_ready_arb_fifo0(in_south_ready.north_arb),//input
.in_ready_arb_fifo1(in_south_ready.east_arb), //input
.in_ready_arb_fifo2(in_south_ready.west_arb), //input
);

//==============================
//  The West FIFO Arbiter
//==============================
// Match request to West arbiter:
assign in_north_req_valid_match_west  = in_north_req_valid && (in_north_req.next_tile_fifo_arb_id == WEST);
assign in_east_req_valid_match_west   = in_east_req_valid  && (in_east_req.next_tile_fifo_arb_id  == WEST);
assign in_south_req_valid_match_west  = in_south_req_valid && (in_south_req.next_tile_fifo_arb_id == WEST);
fifo_arb fifo_arb_west (
//global IO
.clk       (clk),
.rst       (rst),
//==============================
//  New alloc from neighbor Tiles
//==============================
.valid_alloc_req0(in_north_req_valid_match_west),
.valid_alloc_req1(in_east_req_valid_match_west ),
.valid_alloc_req2(in_south_req_valid_match_west),
.alloc_req0      (in_north_req), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req1      (in_east_req ), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req2      (in_south_req), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
// Output
.out_ready_fifo0(out_north_ready.west_arb), //output
.out_ready_fifo1(out_east_ready.west_arb ), //output
.out_ready_fifo2(out_south_ready.west_arb), //output
//==============================
//  Output to West tile
//==============================
.valid_winner_req(out_west_req_valid),
.winner_req      (out_west_req),
// Input
.in_ready_arb_fifo0(in_west_ready.north_arb),//input
.in_ready_arb_fifo1(in_west_ready.east_arb), //input
.in_ready_arb_fifo2(in_west_ready.south_arb),//input
);


endmodule 
