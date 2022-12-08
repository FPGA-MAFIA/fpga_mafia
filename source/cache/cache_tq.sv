//-----------------------------------------------------------------------------
// Title            : 
// Project          : 
//-----------------------------------------------------------------------------
// File             : <TODO>
// Original Author  : 
// Code Owner       : 
// Created          : 
//-----------------------------------------------------------------------------
// Description : 
//
//
//-----------------------------------------------------------------------------
`include "macros.sv"

module  cache_tq 
    import cache_param_pkg::*;  
(
    input   logic               clk,        
    input   logic               rst,        
    //core Interface
    input   var t_req           core2cache_req,
    output  logic               stall,
    output  t_rd_rsp            cache2core_rsp,
    //FM Inteface
    input   var t_fm_rd_rsp     fm2cache_rd_rsp,
    //Pipe Interface
    output  t_lu_req            pipe_lu_req_q1,
    input   var t_lu_rsp        pipe_lu_rsp_q3
);

    assign stall            = '0;
    assign cache2core_rsp   = '0;

assign pipe_lu_req_q1.valid   = core2cache_req.valid;
assign pipe_lu_req_q1.lu_op   = (core2cache_req.opcode == WR_OP) ? WR_LU :
                                (core2cache_req.opcode == RD_OP) ? RD_LU :
                                                                   NO_LU ;
assign pipe_lu_req_q1.address = core2cache_req.address;
assign pipe_lu_req_q1.cl_data    = core2cache_req.data;

endmodule
