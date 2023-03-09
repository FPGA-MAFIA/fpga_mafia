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
 NULL =     2'b00 ,
 WR =     2'b01 ,
 RD =     2'b10 ,
 RD_RSP =     2'b11
} t_tile_opcode;


typedef enum logic[2:0] {  
 NULL_CARDINAL =     3'b000 ,
 NORTH =     3'b001 ,
 SOUTH =     3'b010 ,
 EAST =     3'b011 ,
 WEST =     3'b100 ,
 LOCAL =     3'b111 
} t_cardinal;

typedef struct packed {
    logic [31:0]    address;// bit [31:24] target tile. 
    t_tile_opcode   opcode; // 
    logic [31:0]    data;
    logic [9:0]     requestor_id;
    t_cardinal      next_tile_fifo_arb_id;
} t_tile_trans;

typedef struct packed {  
    logic  east_arb;
    logic  west_arb;
    logic  north_arb;
    logic  south_arb;
    logic  local_arb;
} t_fab_ready;

endpackage
