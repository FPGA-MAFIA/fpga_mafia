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

module cache_pipe
    import cache_param_pkg::*;  
(
    input   logic            clk,
    input   logic            rst,
    //tq interface 
    input   var t_lu_req     pipe_lu_req_q1,
    output  t_lu_rsp         pipe_lu_rsp_q3,
    // FM interface Reqiuets 
    output  t_fm_wr_req      cache2fm_wr_req_q3,
    output  t_fm_rd_req      cache2fm_rd_req_q3,
    //tag_array interface 
    output  t_set_rd_req     rd_set_req_q1,
    input   var t_set_rd_rsp pre_rd_data_set_rsp_q2,
    output  t_set_wr_req     wr_data_set_q2,
    //data_array interface 
    output  t_cl_rd_req      rd_cl_req_q2,
    input   var t_cl_rd_rsp  rd_data_cl_rsp_q3,
    output  t_cl_wr_req      wr_data_cl_q3
);

    assign pipe_lu_rsp_q3     = '0;
    assign cache2fm_wr_req_q3 = '0;
    assign cache2fm_rd_req_q3 = '0;
    assign rd_set_req_q1      = '0;
    assign wr_data_set_q2     = '0;
    assign rd_cl_req_q2       = '0;
    assign wr_data_cl_q3      = '0;

endmodule
