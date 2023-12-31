//-----------------------------------------------------------------------------
// Title            : core_rrv_fab_pkg 
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : core_rrv_fab_pkg.sv
// Original Author  :  
// Code Owner       : Amichai Ben-David
// Created          : 12/2023
//-----------------------------------------------------------------------------
// Description :
// Fabric and tile structs
//-----------------------------------------------------------------------------
//==============================
//Fabric definitions
//==============================
typedef logic [7:0] t_tile_id;
typedef enum logic[1:0] {  
 NULL =   2'b00 ,
 WR =     2'b01 ,
 RD =     2'b10 ,
 RD_RSP = 2'b11
} t_tile_opcode;

typedef enum logic[2:0] {  
 NULL_CARDINAL =     3'b000 ,
 NORTH         =     3'b001 ,
 SOUTH         =     3'b010 ,
 EAST          =     3'b011 ,
 WEST          =     3'b100 ,
 LOCAL         =     3'b101 
} t_cardinal;

typedef struct packed {
    logic [31:0]    address;
    t_tile_opcode   opcode;
    logic [31:0]    data;
    logic [7:0]     requestor_id;
    t_cardinal      next_tile_fifo_arb_id;
} t_tile_trans;

typedef struct packed {  
    logic  east_arb;
    logic  west_arb;
    logic  north_arb;
    logic  south_arb;
    logic  local_arb;
} t_fab_ready;