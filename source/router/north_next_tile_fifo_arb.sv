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
module north_next_tile_fifo_arb
import router_pkg::*;
(
    input t_tile_id     local_tile_id,
    input logic         in_south_req_valid_match_north,
    input logic         in_east_req_valid_match_north,
    input logic         in_west_req_valid_match_north,
    input logic         in_local_req_valid_match_north,
    input logic [31:24] in_south_req_address,
    input logic [31:24] in_east_req_address,
    input logic [31:24] in_west_req_address,
    input logic [31:24] in_local_req_address,
    //output
    output t_cardinal in_south_to_north_next_tile_fifo_arb_id,
    output t_cardinal in_east_to_north_next_tile_fifo_arb_id,
    output t_cardinal in_west_to_north_next_tile_fifo_arb_id,
    output t_cardinal in_local_to_north_next_tile_fifo_arb_id
);
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


// using a simple algorithm to determine the next tile id
// (1) first we reach the row (in this case -> keep going north)
// (2) then we reach the column (in this case -> keep going east/west)


// local_tile_id this is the our tile id
t_tile_id north_tile_id;
assign north_tile_id[7:4] =  local_tile_id[7:4];
assign north_tile_id[3:0] =  local_tile_id[3:0]-1;

// in_south:
logic in_south_req_next_tile_is_target;
logic in_south_req_next_tile_final_row;
logic in_south_req_next_tile_final_col;
logic in_south_req_next_tile_col_west ;
logic in_south_req_next_tile_col_east ;
// in_east:
logic in_east_req_next_tile_is_target;
logic in_east_req_next_tile_final_row;
logic in_east_req_next_tile_final_col;
logic in_east_req_next_tile_col_west;
logic in_east_req_next_tile_col_east;
// in_west:
logic in_west_req_next_tile_is_target;
logic in_west_req_next_tile_final_row;
logic in_west_req_next_tile_final_col;
logic in_west_req_next_tile_col_west;
logic in_west_req_next_tile_col_east;
// in_local:
logic in_local_req_next_tile_is_target;
logic in_local_req_next_tile_final_row;
logic in_local_req_next_tile_final_col;
logic in_local_req_next_tile_col_west;
logic in_local_req_next_tile_col_east;


logic in_south_to_north_assert_illegal;
logic in_east_to_north_assert_illegal;
logic in_west_to_north_assert_illegal;
logic in_local_to_north_assert_illegal;
//======================================
// North Interface -> only need to determine which fifo in north tile to send to
//======================================
always_comb begin : set_nxt_tile_fifo_arb_id_north
// ==============================
// input south request -> matching north fifo arbiter , and determine in next tile what is the correct fifo cardinality
// ==============================
    in_south_req_next_tile_is_target = in_south_req_valid_match_north && (north_tile_id[7:0] == in_south_req_address[31:24]);
    in_south_req_next_tile_final_row = in_south_req_valid_match_north && (north_tile_id[3:0] == in_south_req_address[27:24]);
    in_south_req_next_tile_final_col = in_south_req_valid_match_north && (north_tile_id[7:4] == in_south_req_address[31:28]);
    in_south_req_next_tile_col_west  = in_south_req_valid_match_north && (north_tile_id[7:4]  > in_south_req_address[31:28]);
    in_south_req_next_tile_col_east  = in_south_req_valid_match_north && (north_tile_id[7:4]  < in_south_req_address[31:28]);

    //default values for unique case
    in_south_to_north_assert_illegal = 1'b0;
    in_south_to_north_next_tile_fifo_arb_id    = NULL_CARDINAL;
    unique case({in_south_req_next_tile_is_target, in_south_req_next_tile_final_row, in_south_req_next_tile_col_west, in_south_req_next_tile_col_east})
        4'b1??? : in_south_to_north_next_tile_fifo_arb_id    = LOCAL; // Next tile is final, in_south_req_next_tile_is_target is set is all we care about
        4'b0110 : in_south_to_north_next_tile_fifo_arb_id    = WEST;  // Next tile is final row, need to move west due to (north_tile_id[7:4] > in_south_req.address[31:28]);
        4'b0101 : in_south_to_north_next_tile_fifo_arb_id    = EAST;  // Next tile is final row, need to move east due to (north_tile_id[7:4] < in_south_req.address[31:28]);
        4'b00?? : in_south_to_north_next_tile_fifo_arb_id    = NORTH; // Next tile is not final row, need to move north (this is the naive algorithm) - assumption moving north using the North fifo arbiter was correct.
        default : in_south_to_north_assert_illegal = in_south_req_valid_match_north;
    endcase

// ==============================
// input east request -> matching north fifo arbiter , and determine in next tile what is the correct fifo cardinality
// ==============================
    in_east_req_next_tile_is_target = in_east_req_valid_match_north && (north_tile_id[7:0] == in_east_req_address[31:24]);
    in_east_req_next_tile_final_row = in_east_req_valid_match_north && (north_tile_id[3:0] == in_east_req_address[27:24]);
    in_east_req_next_tile_final_col = in_east_req_valid_match_north && (north_tile_id[7:4] == in_east_req_address[31:28]);
    in_east_req_next_tile_col_west  = in_east_req_valid_match_north && (north_tile_id[7:4]  > in_east_req_address[31:28]);
    // TODO: this is not expected - when request arrives from east, the next tile should not be in the east direction 
    // add assertion?
    in_east_req_next_tile_col_east  = in_east_req_valid_match_north && (north_tile_id[7:4]  < in_east_req_address[31:28]);

    //default values for unique case
    in_east_to_north_assert_illegal = 1'b0;
    in_east_to_north_next_tile_fifo_arb_id    = NULL_CARDINAL;
    unique case({in_east_req_next_tile_is_target, in_east_req_next_tile_final_row, in_east_req_next_tile_col_west, in_east_req_next_tile_col_east})
        4'b1??? : in_east_to_north_next_tile_fifo_arb_id    = LOCAL; // Next tile is final, in_east_req_next_tile_is_target is set is all we care about
        4'b0000 : in_east_to_north_next_tile_fifo_arb_id    = NORTH; // Next tile is not final row, need to move north (this is the naive algorithm) - assumption moving north using the North fifo arbiter was correct.
        4'b0001 : in_east_to_north_next_tile_fifo_arb_id    = NORTH; // Next tile is not final row, need to move north (this is the naive algorithm) - assumption moving north using the North fifo arbiter was correct.
        4'b0010 : in_east_to_north_next_tile_fifo_arb_id    = NORTH; // Next tile is not final row, need to move north (this is the naive algorithm) - assumption moving north using the North fifo arbiter was correct.
        4'b0011 : in_east_to_north_next_tile_fifo_arb_id    = NORTH; // Next tile is not final row, need to move north (this is the naive algorithm) - assumption moving north using the North fifo arbiter was correct.
        4'b0110 : in_east_to_north_next_tile_fifo_arb_id    = WEST;  // Next tile is final row, need to move west due to (north_tile_id[7:4] > in_east_req.address[31:28]);
        4'b0101 : in_east_to_north_next_tile_fifo_arb_id    = EAST;  // Next tile is final row, need to move east due to (north_tile_id[7:4] < in_east_req.address[31:28]);
        default : in_east_to_north_assert_illegal         = in_east_req_valid_match_north;
    endcase

// ==============================
// input west request -> matching north fifo arbiter , and determine in next tile what is the correct fifo cardinality
// ==============================
    in_west_req_next_tile_is_target = in_west_req_valid_match_north && (north_tile_id[7:0] == in_west_req_address[31:24]);
    in_west_req_next_tile_final_row = in_west_req_valid_match_north && (north_tile_id[3:0] == in_west_req_address[27:24]);
    in_west_req_next_tile_final_col = in_west_req_valid_match_north && (north_tile_id[7:4] == in_west_req_address[31:28]);
    // TODO: this is not expected - when request arrives from west, the next tile should not be in the west direction 
    // add assertion?
    in_west_req_next_tile_col_west  = in_west_req_valid_match_north && (north_tile_id[7:4]  > in_west_req_address[31:28]);
    in_west_req_next_tile_col_east  = in_west_req_valid_match_north && (north_tile_id[7:4]  < in_west_req_address[31:28]);

    //default values for unique case
    in_west_to_north_assert_illegal = 1'b0;
    in_west_to_north_next_tile_fifo_arb_id    = NULL_CARDINAL;
    unique case({in_west_req_next_tile_is_target, in_west_req_next_tile_final_row, in_west_req_next_tile_col_west, in_west_req_next_tile_col_east})
        4'b1??? : in_west_to_north_next_tile_fifo_arb_id    = LOCAL; // Next tile is final, in_west_req_next_tile_is_target is set is all we care about
        4'b0110 : in_west_to_north_next_tile_fifo_arb_id    = WEST;  // Next tile is final row, need to move west due to (north_tile_id[7:4] > in_west_req.address[31:28]);
        4'b0101 : in_west_to_north_next_tile_fifo_arb_id    = EAST;  // Next tile is final row, need to move east due to (north_tile_id[7:4] < in_west_req.address[31:28]);
        4'b00?? : in_west_to_north_next_tile_fifo_arb_id    = NORTH; // Next tile is not final row, need to move north (this is the naive algorithm) - assumption moving north using the North fifo arbiter was correct.
        default : in_west_to_north_assert_illegal         =in_west_req_valid_match_north;
    endcase

// ==============================
// input west request -> matching north fifo arbiter , and determine in next tile what is the correct fifo cardinality
// ==============================
    in_local_req_next_tile_is_target = in_local_req_valid_match_north && (north_tile_id[7:0] == in_local_req_address[31:24]);
    in_local_req_next_tile_final_row = in_local_req_valid_match_north && (north_tile_id[3:0] == in_local_req_address[27:24]);
    in_local_req_next_tile_final_col = in_local_req_valid_match_north && (north_tile_id[7:4] == in_local_req_address[31:28]);
    in_local_req_next_tile_col_west  = in_local_req_valid_match_north && (north_tile_id[7:4]  > in_local_req_address[31:28]);
    in_local_req_next_tile_col_east  = in_local_req_valid_match_north && (north_tile_id[7:4]  < in_local_req_address[31:28]);

    //default values for unique case
    in_local_to_north_assert_illegal = 1'b0;
    in_local_to_north_next_tile_fifo_arb_id    = NULL_CARDINAL;
    unique case({in_local_req_next_tile_is_target, in_local_req_next_tile_final_row, in_local_req_next_tile_col_west, in_local_req_next_tile_col_east})
        4'b1??? : in_local_to_north_next_tile_fifo_arb_id    = LOCAL; // Next tile is final, in_local_req_next_tile_is_target is set is all we care about
        4'b0110 : in_local_to_north_next_tile_fifo_arb_id    = WEST;  // Next tile is final row, need to move west due to (north_tile_id[7:4] > in_local_req.address[31:28]);
        4'b0101 : in_local_to_north_next_tile_fifo_arb_id    = EAST;  // Next tile is final row, need to move east due to (north_tile_id[7:4] < in_local_req.address[31:28]);
        4'b00?? : in_local_to_north_next_tile_fifo_arb_id    = NORTH; // Next tile is not final row, need to move north (this is the naive algorithm) - assumption moving north using the North fifo arbiter was correct.
        default : in_local_to_north_assert_illegal         = in_local_req_valid_match_north;
    endcase

end // always_comb

endmodule 
