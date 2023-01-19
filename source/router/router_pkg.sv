//-----------------------------------------------------------------------------
// Title            : 
// Project          : 
//-----------------------------------------------------------------------------
// File             : 
// Original Author  : 
// Code Owner       : 
// Created          : 
//-----------------------------------------------------------------------------
// Description :
//-----------------------------------------------------------------------------

package router_pkg;

typedef enum logic[1:0] {  
    2'b00 = NULL;
    2'b01 = WR;
    2'b10 = RD;
    2'b11 = RD_RSP;
} t_tile_opcode;

typedef enum logic[1:0] {  
    3'b000 = NULL_CARDINAL;
    3'b001 = NORTH;
    3'b010 = SOUTH;
    3'b011 = EAST;
    3'b100 = WEST;
    3'b111 = LOCAL;
} t_cardinal;

typedef struct packed {
    logic [31:0]    address,
    t_tile_opcode   opcode,
    logic [31:0]    data,
    logic [9:0]     requestor_id,
    t_cardinal      next_tile_fifo_arb_id
} t_fab_req;

typedef struct packed {  
    logic  east_arb,
    logic  west_arb,
    logic  north_arb,
    logic  south_arb,
    logic  local_arb
} t_fab_ready;
endpackage
