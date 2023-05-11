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
module next_tile_fifo_arb
import router_pkg::*;
#(parameter NEXT_TILE_CARDINAL=NULL_CARDINAL)
(
    input logic         clk,
    input t_tile_id     local_tile_id,
    input logic         in_north_req_valid,
    input logic         in_east_req_valid,
    input logic         in_south_req_valid,
    input logic         in_west_req_valid,
    input logic         in_local_req_valid,
    input logic [31:24] in_north_req_address,
    input logic [31:24] in_east_req_address,
    input logic [31:24] in_south_req_address,
    input logic [31:24] in_west_req_address,
    input logic [31:24] in_local_req_address,
    //output
    output t_cardinal in_north_next_tile_fifo_arb_card,
    output t_cardinal in_south_next_tile_fifo_arb_card,
    output t_cardinal in_east_next_tile_fifo_arb_card,
    output t_cardinal in_west_next_tile_fifo_arb_card,
    output t_cardinal in_local_next_tile_fifo_arb_card
);

logic [4:0] next_tile_is_target;
logic [4:0] next_tile_need_north;
logic [4:0] next_tile_need_west;
logic [4:0] next_tile_need_south;
logic [4:0] next_tile_need_east;
logic [4:0] next_tile_final_col;
logic [4:0] next_tile_final_row;

logic      [4:0][7:0] req_address;
logic      [4:0]      req_valid;
t_cardinal [4:0]      next_tile_fifo_arb_card;

//==============================
//  overriding next t_tile_ID
//==============================
//|=======|=======|=======|
//| [1,1] | [2,1] | [3,1] |
//|=======|=======|=======|
//| [1,2] | [2,2] | [3,2] |
//|=======|=======|=======|
//| [1,3] | [2,3] | [3,3] |
//|=======|=======|=======|

//======================================
// Calculate the next tile id based on the current tile id and the cardinal direction
//======================================
t_tile_id next_tile_id;
generate if (NEXT_TILE_CARDINAL == NORTH) begin : assign_next_tile_id
    assign next_tile_id[7:4] =  local_tile_id[7:4];
    assign next_tile_id[3:0] =  local_tile_id[3:0]-1;
end else if (NEXT_TILE_CARDINAL == SOUTH) begin
    assign next_tile_id[7:4] =  local_tile_id[7:4];
    assign next_tile_id[3:0] =  local_tile_id[3:0]+1;
end else if (NEXT_TILE_CARDINAL == EAST) begin
    assign next_tile_id[7:4] =  local_tile_id[7:4]+1;
    assign next_tile_id[3:0] =  local_tile_id[3:0];
end else if (NEXT_TILE_CARDINAL == WEST) begin
    assign next_tile_id[7:4] =  local_tile_id[7:4]-1;
    assign next_tile_id[3:0] =  local_tile_id[3:0];
end else begin // (NEXT_TILE_CARDINAL == LOCAL)
    assign next_tile_id[7:0] =  local_tile_id[7:0];
end endgenerate

//=================================================
//  set the terms used for calc next cardinal - using a for loop
//=================================================
assign req_address[0] = in_north_req_address;
assign req_address[1] = in_east_req_address;
assign req_address[2] = in_south_req_address;
assign req_address[3] = in_west_req_address;
assign req_address[4] = in_local_req_address;

assign req_valid[0] = in_north_req_valid;
assign req_valid[1] = in_east_req_valid;
assign req_valid[2] = in_south_req_valid;
assign req_valid[3] = in_west_req_valid;
assign req_valid[4] = in_local_req_valid;

//======================================
// translate back to cardinal terms
//======================================
assign in_north_next_tile_fifo_arb_card = next_tile_fifo_arb_card[0];
assign in_east_next_tile_fifo_arb_card  = next_tile_fifo_arb_card[1];
assign in_south_next_tile_fifo_arb_card = next_tile_fifo_arb_card[2];
assign in_west_next_tile_fifo_arb_card  = next_tile_fifo_arb_card[3];
assign in_local_next_tile_fifo_arb_card = next_tile_fifo_arb_card[4];


always_comb begin : set_the_terms_used_for_calc_next_cardinal
for(int i=0; i<5; i++)begin
    //( x,y )->( col,row )->( [7:4],[3:0] )
    next_tile_final_col [i] = req_valid[i] && (req_address[i][7:4] == next_tile_id[7:4]);
    next_tile_final_row [i] = req_valid[i] && (req_address[i][3:0] == next_tile_id[3:0]);
    next_tile_is_target [i] = req_valid[i] && (req_address[i][7:0] == next_tile_id[7:0]);

    next_tile_need_north[i] = req_valid[i] && (req_address[i][3:0] < next_tile_id[3:0]);
    next_tile_need_south[i] = req_valid[i] && (req_address[i][3:0] > next_tile_id[3:0]);
    next_tile_need_west [i] = req_valid[i] && (req_address[i][7:4] < next_tile_id[7:4]);
    next_tile_need_east [i] = req_valid[i] && (req_address[i][7:4] > next_tile_id[7:4]);
end
end

// ======================================
// The algorithm is as follows:
// 1. First reach the row (north or south)
// 2. Then reach the column (east or west)
// ======================================
always_comb begin : set_the_next_card_according_to_algorithm
// This is accomplished using a is a ***priority*** mux:
// 1. if the next tile id row is smaller than the address[27:24], then set the next card to north (go more north)
// 2. if the next tile id row is larger than the address[27:24], then set the next card to south (go more south)
// 3. if the next tile id col is smaller than the address[31:27], then set the next card to west (go more west)
// 4. if the next tile id col is larger than the address[31:27], then set the next card to east (go more east)
// 5. if the next tile id is the target, then set the next card to local
for(int i=0; i<5; i++)begin
    if (next_tile_need_north[i]) begin
        next_tile_fifo_arb_card[i] = NORTH;
    end else if (next_tile_need_south[i]) begin
        next_tile_fifo_arb_card[i] = SOUTH;
    end else if (next_tile_need_west[i]) begin
        next_tile_fifo_arb_card[i] = WEST;
    end else if (next_tile_need_east[i]) begin
        next_tile_fifo_arb_card[i] = EAST;
    end else if (next_tile_is_target[i]) begin
        next_tile_fifo_arb_card[i] = LOCAL;
    end else begin
        next_tile_fifo_arb_card[i] = NULL_CARDINAL;
    end
end
end

// Concurrent assertion to check if next_tile is going back
//  property going_back;
   // @(posedge clk) 
   // (next_tile_fifo_arb_card == WEST && req_valid[3] && req_address[3][7:4] >= next_tile_id[7:4]) ||
   // (next_tile_fifo_arb_card == EAST && req_valid[1] && req_address[1][7:4] <= next_tile_id[7:4]) ||
   // (next_tile_fifo_arb_card == NORTH && req_valid[0] && req_address[0][3:0] >= next_tile_id[3:0]) ||
  //  (next_tile_fifo_arb_card == SOUTH && req_valid[2] && req_address[2][3:0] <= next_tile_id[3:0]);
  //endproperty
logic going_back;
`ASSERT (local_tile_id,((next_tile_fifo_arb_card == EAST && req_valid[3] && req_address[3][7:4] >= next_tile_id[7:4]) ||
    (next_tile_fifo_arb_card == WEST && req_valid[1] && req_address[1][7:4] <= next_tile_id[7:4]) ||
    (next_tile_fifo_arb_card == SOUTH && req_valid[0] && req_address[0][3:0] >= next_tile_id[3:0]) ||
    (next_tile_fifo_arb_card == NORTH && req_valid[2] && req_address[2][3:0] <= next_tile_id[3:0])),1'b1,"next_tile is going back");
  // Assert the going_back property
  //assert property (going_back);

endmodule 
