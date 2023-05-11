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
    input   var t_tile_trans    in_north_req,
    output  t_fab_ready         out_north_ready, // .east_arb, .west_arb, .south_arb, .local_arb
    // output request & input ready
    output  logic               out_north_req_valid,
    output  t_tile_trans        out_north_req,
    input   var t_fab_ready     in_north_ready, // east_arb, west_arb, north_arb, local_arb
    //========================================
    // East Interface
    //========================================
    // input request & output ready
    input   logic               in_east_req_valid,
    input   var t_tile_trans    in_east_req,
    output  t_fab_ready         out_east_ready, // .north_arb, .west_arb, .south_arb, .local_arb
    // output request & input ready
    output  logic               out_east_req_valid,
    output  t_tile_trans        out_east_req,
    input   var t_fab_ready     in_east_ready, // north_arb, east_arb, south_arb, local_arb
    //========================================
    // West Interface
    //========================================
    // input request & output ready
    input   logic               in_west_req_valid,
    input   var t_tile_trans    in_west_req,
    output  t_fab_ready         out_west_ready, // .north_arb, .east_arb, .south_arb, .local_arb
    // output request & input ready
    output  logic               out_west_req_valid,
    output  t_tile_trans        out_west_req,
    input   var t_fab_ready     in_west_ready, // north_arb, west_arb, south_arb, local_arb
    //========================================
    // South Interface
    //========================================
    // input request & output ready
    input   logic               in_south_req_valid,
    input   var t_tile_trans    in_south_req,
    output  t_fab_ready         out_south_ready, // .north_arb, .east_arb, .west_arb, .local_arb
    // output request & input ready
    output  logic               out_south_req_valid,
    output  t_tile_trans        out_south_req,
    input   var t_fab_ready     in_south_ready,  // south_arb, east_arb, west_arb, local_arb
    //========================================
    // Local Interface
    //========================================
    // input request & output ready
    input   logic               in_local_req_valid,
    input   var t_tile_trans    in_local_req,
    output  t_fab_ready         out_local_ready, // .north_arb, .east_arb, .west_arb, .south_arb
    // output request & input ready
    output  logic               out_local_req_valid,
    output  t_tile_trans        out_local_req,
    input   var t_fab_ready     in_local_ready  // south_arb, east_arb, west_arb, local_arb
);

//==============================
//  signals declaration
//==============================
logic in_north_req_valid_match_east,  in_east_req_valid_match_north, in_west_req_valid_match_north, in_south_req_valid_match_north, in_local_req_valid_match_north;
logic in_north_req_valid_match_west,  in_east_req_valid_match_west,  in_west_req_valid_match_east,  in_south_req_valid_match_east,  in_local_req_valid_match_east;
logic in_north_req_valid_match_south, in_east_req_valid_match_south, in_west_req_valid_match_south, in_south_req_valid_match_west,  in_local_req_valid_match_west;
logic in_north_req_valid_match_local, in_east_req_valid_match_local, in_west_req_valid_match_local, in_south_req_valid_match_local, in_local_req_valid_match_south;


t_tile_trans in_north_new_req_south, in_west_new_req_south, in_south_new_req_local, in_east_new_req_local, in_local_new_req_north; 
t_tile_trans in_north_new_req_west,  in_west_new_req_east,  in_south_new_req_west,  in_east_new_req_south, in_local_new_req_east;  
t_tile_trans in_north_new_req_east,  in_west_new_req_north, in_south_new_req_east,  in_east_new_req_west,  in_local_new_req_west;  
t_tile_trans in_north_new_req_local, in_west_new_req_local, in_south_new_req_north, in_east_new_req_north, in_local_new_req_south; 

t_cardinal in_local_to_north_next_tile_fifo_arb_id;
t_cardinal in_local_to_south_next_tile_fifo_arb_id;
t_cardinal in_local_to_east_next_tile_fifo_arb_id;
t_cardinal in_local_to_west_next_tile_fifo_arb_id;
t_cardinal in_east_to_north_next_tile_fifo_arb_id;
t_cardinal in_east_to_south_next_tile_fifo_arb_id;
t_cardinal in_east_to_west_next_tile_fifo_arb_id;
t_cardinal in_south_to_east_next_tile_fifo_arb_id;
t_cardinal in_south_to_north_next_tile_fifo_arb_id;
t_cardinal in_south_to_west_next_tile_fifo_arb_id;
t_cardinal in_west_to_east_next_tile_fifo_arb_id;
t_cardinal in_west_to_south_next_tile_fifo_arb_id;
t_cardinal in_west_to_north_next_tile_fifo_arb_id;
t_cardinal in_north_to_west_next_tile_fifo_arb_id;
t_cardinal in_north_to_east_next_tile_fifo_arb_id;
t_cardinal in_north_to_south_next_tile_fifo_arb_id;

//==============================
//  module content
//==============================
//==============================
//  overriding next t_tile_ID
//|=======|=======|=======|
//| [1,1] | [2,1] | [3,1] |
//|=======|=======|=======|
//| [1,2] | [2,2] | [3,2] |
//|=======|=======|=======|
//| [1,3] | [2,3] | [3,3] |
//|=======|=======|=======|

//==============================
//  The North FIFO Arbiter
//==============================
// Match request to North arbiter:
assign in_south_req_valid_match_north  =  in_south_req_valid && (in_south_req.next_tile_fifo_arb_id == NORTH);
assign in_east_req_valid_match_north   =  in_east_req_valid  && (in_east_req.next_tile_fifo_arb_id  == NORTH);
assign in_west_req_valid_match_north   =  in_west_req_valid  && (in_west_req.next_tile_fifo_arb_id  == NORTH);
assign in_local_req_valid_match_north  =  in_local_req_valid && (in_local_req.next_tile_fifo_arb_id == NORTH);
// TODO we can probably remove this, testing the assertion
logic in_north_req_valid_match_north;
assign in_north_req_valid_match_north  =  in_north_req_valid && (in_north_req.next_tile_fifo_arb_id == NORTH);
//==============================
// override the next_tile_fifo_arb_id
//==============================
next_tile_fifo_arb
#(.NEXT_TILE_CARDINAL(NORTH))
north_next_tile_fifo_arb (
    .clk                    (clk                            ) ,
    .local_tile_id          (local_tile_id                  ) , //    input t_tile_id    
    .in_north_req_valid     (in_north_req_valid_match_north ) , //    input logic        
    .in_east_req_valid      (in_east_req_valid_match_north  ) , //    input logic        
    .in_south_req_valid     (in_south_req_valid_match_north ) , //    input logic        
    .in_west_req_valid      (in_west_req_valid_match_north  ) , //    input logic        
    .in_local_req_valid     (in_local_req_valid_match_north ) , //    input logic        
    .in_north_req_address   ('0                             ) , //    input logic [31:24]
    .in_east_req_address    (in_east_req.address [31:24]    ) , //    input logic [31:24]
    .in_south_req_address   (in_south_req.address[31:24]    ) , //    input logic [31:24]
    .in_west_req_address    (in_west_req.address [31:24]    ) , //    input logic [31:24]
    .in_local_req_address   (in_local_req.address[31:24]    ) , //    input logic [31:24]
    //output
    .in_north_next_tile_fifo_arb_card (                                         ) , //    output t_cardinal
    .in_east_next_tile_fifo_arb_card  (in_east_to_north_next_tile_fifo_arb_id   ) , //    output t_cardinal
    .in_south_next_tile_fifo_arb_card (in_south_to_north_next_tile_fifo_arb_id  ) , //    output t_cardinal
    .in_west_next_tile_fifo_arb_card  (in_west_to_north_next_tile_fifo_arb_id   ) , //    output t_cardinal
    .in_local_next_tile_fifo_arb_card (in_local_to_north_next_tile_fifo_arb_id  )   //    output t_cardinal
);

always_comb begin : override_the_north_next_tile_fifo_arb
    // default values
    in_south_new_req_north  = in_south_req;
    in_east_new_req_north   = in_east_req;
    in_west_new_req_north   = in_west_req;
    in_local_new_req_north  = in_local_req;
    // override the next_tile_fifo_arb_id
    in_south_new_req_north.next_tile_fifo_arb_id = in_south_to_north_next_tile_fifo_arb_id;
    in_east_new_req_north.next_tile_fifo_arb_id  = in_east_to_north_next_tile_fifo_arb_id;
    in_west_new_req_north.next_tile_fifo_arb_id  = in_west_to_north_next_tile_fifo_arb_id;
    in_local_new_req_north.next_tile_fifo_arb_id = in_local_to_north_next_tile_fifo_arb_id;
end

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
.valid_alloc_req3(in_local_req_valid_match_north),// placeholder for local mini_core
.alloc_req0      (in_south_new_req_north), // input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req1      (in_east_new_req_north ), // input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req2      (in_west_new_req_north ), // input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req3      (in_local_new_req_north), // 
// Output
.out_ready_fifo0(out_south_ready.north_arb), //output
.out_ready_fifo1(out_east_ready.north_arb ), //output
.out_ready_fifo2(out_west_ready.north_arb ), //output
.out_ready_fifo3(out_local_ready.north_arb), //output placeholder for local mini_core
//==============================
//  Output to North tile
//==============================
// Output
.winner_req_valid(out_north_req_valid),
.winner_req      (out_north_req),
// Input
.in_ready_arb_fifo0(in_north_ready.north_arb),//input
.in_ready_arb_fifo1(in_north_ready.east_arb), //input
.in_ready_arb_fifo2(in_north_ready.west_arb), //input
.in_ready_arb_fifo3(in_north_ready.local_arb)  //input placeholder for local mini_core
);


//==============================
// The East FIFO Arbiter
//==============================
// Match request to East arbiter:
assign in_north_req_valid_match_east  = in_north_req_valid && (in_north_req.next_tile_fifo_arb_id == EAST);
assign in_south_req_valid_match_east  = in_south_req_valid && (in_south_req.next_tile_fifo_arb_id == EAST);
assign in_west_req_valid_match_east   = in_west_req_valid  && (in_west_req.next_tile_fifo_arb_id  == EAST);
assign in_local_req_valid_match_east  = in_local_req_valid && (in_local_req.next_tile_fifo_arb_id == EAST);
//==============================
// override the next_tile_fifo_arb_id
//==============================
next_tile_fifo_arb
#(.NEXT_TILE_CARDINAL(EAST))
east_next_tile_fifo_arb (
    .clk                    (clk                            ) ,
    .local_tile_id          (local_tile_id                  ) , //    input t_tile_id
    .in_north_req_valid     (in_north_req_valid_match_east  ) , //    input logic
    .in_east_req_valid      ('0                             ) , //    input logic
    .in_south_req_valid     (in_south_req_valid_match_east  ) , //    input logic
    .in_west_req_valid      (in_west_req_valid_match_east   ) , //    input logic
    .in_local_req_valid     (in_local_req_valid_match_east  ) , //    input logic
    .in_north_req_address   (in_north_req.address[31:24]    ) , //    input logic [31:24]
    .in_east_req_address    ('0                             ) , //    input logic [31:24]
    .in_south_req_address   (in_south_req.address[31:24]    ) , //    input logic [31:24]
    .in_west_req_address    (in_west_req.address [31:24]    ) , //    input logic [31:24]
    .in_local_req_address   (in_local_req.address[31:24]    ) , //    input logic [31:24]
    //output
    .in_north_next_tile_fifo_arb_card (in_north_to_east_next_tile_fifo_arb_id  ) , //    output t_cardinal
    .in_east_next_tile_fifo_arb_card  (                                         ) , //    output t_cardinal
    .in_south_next_tile_fifo_arb_card (in_south_to_east_next_tile_fifo_arb_id  ) , //    output t_cardinal
    .in_west_next_tile_fifo_arb_card  (in_west_to_east_next_tile_fifo_arb_id   ) , //    output t_cardinal
    .in_local_next_tile_fifo_arb_card (in_local_to_east_next_tile_fifo_arb_id  )   //    output t_cardinal
);

always_comb begin : override_the_east_next_tile_fifo_arb
    // default values
    in_north_new_req_east  = in_north_req;
    in_south_new_req_east  = in_south_req;
    in_west_new_req_east   = in_west_req;
    in_local_new_req_east  = in_local_req;
    // override the next_tile_fifo_arb_id
    in_north_new_req_east.next_tile_fifo_arb_id = in_north_to_east_next_tile_fifo_arb_id;
    in_south_new_req_east.next_tile_fifo_arb_id = in_south_to_east_next_tile_fifo_arb_id;
    in_west_new_req_east.next_tile_fifo_arb_id  = in_west_to_east_next_tile_fifo_arb_id;
    in_local_new_req_east.next_tile_fifo_arb_id = in_local_to_east_next_tile_fifo_arb_id;
end



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
.valid_alloc_req3(in_local_req_valid_match_east),// placeholder for local mini_core
.alloc_req0      (in_north_new_req_east), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req1      (in_south_new_req_east), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req2      (in_west_new_req_east),  //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req3      (in_local_new_req_east),// placeholder for local mini_core
// Output
.out_ready_fifo0(out_north_ready.east_arb), //output
.out_ready_fifo1(out_south_ready.east_arb), //output
.out_ready_fifo2(out_west_ready.east_arb),  //output
.out_ready_fifo3(out_local_ready.east_arb), //output placeholder for local mini_core
//==============================
//  Output to East tile
//==============================
// Output
.winner_req_valid(out_east_req_valid),
.winner_req      (out_east_req),
// Input
.in_ready_arb_fifo0(in_east_ready.north_arb),//input
.in_ready_arb_fifo1(in_east_ready.south_arb),//input
.in_ready_arb_fifo2(in_east_ready.west_arb), //input
.in_ready_arb_fifo3(in_east_ready.local_arb)  //input placeholder for local mini_core
);


//==============================
//  The South FIFO Arbiter
//==============================
// Match request to South arbiter:
assign in_north_req_valid_match_south = in_north_req_valid && (in_north_req.next_tile_fifo_arb_id == SOUTH);
assign in_east_req_valid_match_south  = in_east_req_valid  && (in_east_req.next_tile_fifo_arb_id  == SOUTH);
assign in_west_req_valid_match_south  = in_west_req_valid  && (in_west_req.next_tile_fifo_arb_id  == SOUTH);
assign in_local_req_valid_match_south = in_local_req_valid && (in_local_req.next_tile_fifo_arb_id == SOUTH);

// override the next_tile_fifo_arb_id
next_tile_fifo_arb
#(.NEXT_TILE_CARDINAL(SOUTH))
south_next_tile_fifo_arb (
    .clk                    (clk                            ) ,
    .local_tile_id          (local_tile_id                  ) , //    input t_tile_id    
    .in_north_req_valid     (in_north_req_valid_match_south ) , //    input logic        
    .in_east_req_valid      (in_east_req_valid_match_south  ) , //    input logic        
    .in_south_req_valid     ('0                             ) , //    input logic        
    .in_west_req_valid      (in_west_req_valid_match_south  ) , //    input logic        
    .in_local_req_valid     (in_local_req_valid_match_south ) , //    input logic        
    .in_north_req_address   (in_north_req.address[31:24]    ) , //    input logic [31:24]
    .in_east_req_address    (in_east_req.address [31:24]    ) , //    input logic [31:24]
    .in_south_req_address   ('0   ) , //    input logic [31:24]
    .in_west_req_address    (in_west_req.address [31:24]    ) , //    input logic [31:24]
    .in_local_req_address   (in_local_req.address[31:24]    ) , //    input logic [31:24]
    //output
    .in_north_next_tile_fifo_arb_card (in_north_to_south_next_tile_fifo_arb_id  ) , //    output t_cardinal
    .in_east_next_tile_fifo_arb_card  (in_east_to_south_next_tile_fifo_arb_id   ) , //    output t_cardinal
    .in_south_next_tile_fifo_arb_card (                                         ) , //    output t_cardinal
    .in_west_next_tile_fifo_arb_card  (in_west_to_south_next_tile_fifo_arb_id   ) , //    output t_cardinal
    .in_local_next_tile_fifo_arb_card (in_local_to_south_next_tile_fifo_arb_id  )   //    output t_cardinal
);
always_comb begin : override_the_south_next_tile_fifo_arb
    // default values
    in_north_new_req_south  = in_north_req;
    in_east_new_req_south   = in_east_req;
    in_west_new_req_south   = in_west_req;
    in_local_new_req_south  = in_local_req;
    // override the next_tile_fifo_arb_id
    in_north_new_req_south.next_tile_fifo_arb_id = in_north_to_south_next_tile_fifo_arb_id;
    in_east_new_req_south.next_tile_fifo_arb_id  = in_east_to_south_next_tile_fifo_arb_id;
    in_west_new_req_south.next_tile_fifo_arb_id  = in_west_to_south_next_tile_fifo_arb_id;
    in_local_new_req_south.next_tile_fifo_arb_id = in_local_to_south_next_tile_fifo_arb_id;
end

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
.valid_alloc_req3(in_local_req_valid_match_south),// placeholder for local mini_core
.alloc_req0      (in_north_new_req_south), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req1      (in_east_new_req_south ), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req2      (in_west_new_req_south ), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req3      (in_local_new_req_south),// placeholder for local mini_core
// Output
.out_ready_fifo0(out_north_ready.south_arb), //output
.out_ready_fifo1(out_east_ready.south_arb ), //output
.out_ready_fifo2(out_west_ready.south_arb ), //output
.out_ready_fifo3(out_local_ready.south_arb), //output placeholder for local mini_core
//==============================
//  Output to South tile
//==============================
.winner_req_valid(out_south_req_valid),
.winner_req      (out_south_req),
// Input
.in_ready_arb_fifo0(in_south_ready.north_arb),//input
.in_ready_arb_fifo1(in_south_ready.east_arb), //input
.in_ready_arb_fifo2(in_south_ready.west_arb), //input
.in_ready_arb_fifo3(in_south_ready.local_arb)  //input placeholder for local mini_core
);

//==============================
//  The West FIFO Arbiter
//==============================
// Match request to West arbiter:
assign in_north_req_valid_match_west  = in_north_req_valid && (in_north_req.next_tile_fifo_arb_id == WEST);
assign in_east_req_valid_match_west   = in_east_req_valid  && (in_east_req.next_tile_fifo_arb_id  == WEST);
assign in_south_req_valid_match_west  = in_south_req_valid && (in_south_req.next_tile_fifo_arb_id == WEST);
assign in_local_req_valid_match_west  = in_local_req_valid && (in_local_req.next_tile_fifo_arb_id == WEST);

//==============================
// override the next_tile_fifo_arb_id
//==============================
next_tile_fifo_arb
#(.NEXT_TILE_CARDINAL(WEST))
west_next_tile_fifo_arb (
    .clk                    (clk                            ) ,
    .local_tile_id          (local_tile_id                  ) , //    input t_tile_id
    .in_north_req_valid     (in_north_req_valid_match_west  ) , //    input logic
    .in_east_req_valid      (in_east_req_valid_match_west   ) , //    input logic
    .in_south_req_valid     (in_south_req_valid_match_west  ) , //    input logic
    .in_west_req_valid      ('0                             ) , //    input logic
    .in_local_req_valid     (in_local_req_valid_match_west  ) , //    input logic
    .in_north_req_address   (in_north_req.address[31:24]    ) , //    input logic [31:24]
    .in_east_req_address    (in_east_req.address [31:24]    ) , //    input logic [31:24]
    .in_south_req_address   (in_south_req.address[31:24]    ) , //    input logic [31:24]
    .in_west_req_address    ('0                             ) , //    input logic [31:24]
    .in_local_req_address   (in_local_req.address[31:24]    ) , //    input logic [31:24]
    //output
    .in_north_next_tile_fifo_arb_card (in_north_to_west_next_tile_fifo_arb_id  ) , //    output t_cardinal
    .in_east_next_tile_fifo_arb_card  (in_east_to_west_next_tile_fifo_arb_id   ) , //    output t_cardinal
    .in_south_next_tile_fifo_arb_card (in_south_to_west_next_tile_fifo_arb_id  ) , //    output t_cardinal
    .in_west_next_tile_fifo_arb_card  (                                         ) , //    output t_cardinal
    .in_local_next_tile_fifo_arb_card (in_local_to_west_next_tile_fifo_arb_id  )   //    output t_cardinal
);


always_comb begin : override_the_west_next_tile_fifo_arb
    // default values
    in_north_new_req_west  = in_north_req;
    in_east_new_req_west   = in_east_req;
    in_south_new_req_west  = in_south_req;
    in_local_new_req_west  = in_local_req;
    // override the next_tile_fifo_arb_id
    in_north_new_req_west.next_tile_fifo_arb_id = in_north_to_west_next_tile_fifo_arb_id;
    in_east_new_req_west.next_tile_fifo_arb_id  = in_east_to_west_next_tile_fifo_arb_id;
    in_south_new_req_west.next_tile_fifo_arb_id = in_south_to_west_next_tile_fifo_arb_id;
    in_local_new_req_west.next_tile_fifo_arb_id = in_local_to_west_next_tile_fifo_arb_id;
end

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
.valid_alloc_req3(in_local_req_valid_match_west),// placeholder for local mini_core
.alloc_req0      (in_north_new_req_west), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req1      (in_east_new_req_west ), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req2      (in_south_new_req_west), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req3      (in_local_new_req_west),// placeholder for local mini_core
// Output
.out_ready_fifo0(out_north_ready.west_arb), //output
.out_ready_fifo1(out_east_ready.west_arb ), //output
.out_ready_fifo2(out_south_ready.west_arb), //output
.out_ready_fifo3(out_local_ready.west_arb), //output placeholder for local mini_core
//==============================
//  Output to West tile
//==============================
.winner_req_valid    (out_west_req_valid),
.winner_req      (out_west_req),
// Input
.in_ready_arb_fifo0(in_west_ready.north_arb),//input
.in_ready_arb_fifo1(in_west_ready.east_arb), //input
.in_ready_arb_fifo2(in_west_ready.south_arb),//input
.in_ready_arb_fifo3(in_west_ready.local_arb)  //input placeholder for local mini_core
);

//==============================
//  The Local FIFO Arbiter
//==============================
// Match request to West arbiter:
assign in_north_req_valid_match_local  = in_north_req_valid && (in_north_req.next_tile_fifo_arb_id == LOCAL);
assign in_east_req_valid_match_local   = in_east_req_valid  && (in_east_req.next_tile_fifo_arb_id  == LOCAL);
assign in_south_req_valid_match_local  = in_south_req_valid && (in_south_req.next_tile_fifo_arb_id == LOCAL);
assign in_west_req_valid_match_local   = in_west_req_valid  && (in_west_req.next_tile_fifo_arb_id  == LOCAL);

always_comb begin : override_the_local_next_tile_fifo_arb
  // no need to override the next_tile_fifo_arb_id incase of LOCAL
  in_north_new_req_local = in_north_req;
  in_east_new_req_local  = in_east_req;
  in_south_new_req_local = in_south_req;
  in_west_new_req_local  = in_west_req;
end

fifo_arb fifo_arb_local (
//global IO
.clk       (clk),
.rst       (rst),
//==============================
//  New alloc from neighbor Tiles
//==============================
.valid_alloc_req0(in_north_req_valid_match_local),
.valid_alloc_req1(in_east_req_valid_match_local ),
.valid_alloc_req2(in_south_req_valid_match_local),
.valid_alloc_req3(in_west_req_valid_match_local),
.alloc_req0      (in_north_new_req_local), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req1      (in_east_new_req_local ), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req2      (in_south_new_req_local), //input {VALID, ADDRESS, DATA, OPCODE, REQUESTOR_ID}
.alloc_req3      (in_west_new_req_local),// placeholder for local mini_core
// Output
.out_ready_fifo0(out_north_ready.local_arb), //output
.out_ready_fifo1(out_east_ready.local_arb ), //output
.out_ready_fifo2(out_south_ready.local_arb), //output
.out_ready_fifo3(out_west_ready.local_arb), //output
//==============================
//  Output to Local tile
//==============================
.winner_req_valid  (out_local_req_valid),
.winner_req        (out_local_req),
// Input
.in_ready_arb_fifo0(in_local_ready.north_arb),//input
.in_ready_arb_fifo1(in_local_ready.east_arb), //input
.in_ready_arb_fifo2(in_local_ready.south_arb),//input
.in_ready_arb_fifo3(in_local_ready.west_arb)  //input
);


endmodule 
