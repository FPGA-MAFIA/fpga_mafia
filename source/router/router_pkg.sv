//-----------------------------------------------------------------------------
// Title            : riscv as-fast-as-possible 
// Project          : rvc_asap
//-----------------------------------------------------------------------------
// File             : rvc_asap_pkg.sv
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Created          : 11/2021
//-----------------------------------------------------------------------------
// Description :
// enum & parameters for the RVC core
//-----------------------------------------------------------------------------

package router_pkg;

typedef enum logic[1:0] {  
    2'b00 = NULL;
    2'b01 = WR;
    2'b10 = RD;
    2'b11 = RD_RSP;
} t_tile_opcode;

typedef struct packed {
    logic [31:0]    address,
    t_tile_opcode   opcode,
    logic [31:0]    data,
    logic [9:0]     requstor_id 
} t_tile_trans;


endpackage
