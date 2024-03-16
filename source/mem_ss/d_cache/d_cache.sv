//-----------------------------------------------------------------------------
// Title            : Cache
// Project          : fpga_mafia 
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
`include "macros.vh"

module d_cache 
    import d_cache_param_pkg::*;  
(
    input   logic           clk,
    input   logic           rst,
    //Core Interface
    input   var t_req       core2cache_req,
    output  logic           ready,
    output  t_rd_rsp        cache2core_rsp, //RD Response
    // FM Interface
    output  t_fm_req        cache2fm_req_q3, 
    input   var t_fm_rd_rsp fm2cache_rd_rsp
);

t_lu_req        pipe_lu_req_q1;
t_early_lu_rsp  pipe_early_lu_rsp_q2;
t_lu_rsp        pipe_lu_rsp_q3;

d_cache_tq d_cache_tq (
    .clk             (clk),            //input
    .rst             (rst),            //input
    //Agent Interface
    .pre_core2cache_req(core2cache_req), //input
    .ready           (ready),          //output
    .cache2core_rsp  (cache2core_rsp), //output
    //FM Interface
    .fm2cache_rd_rsp (fm2cache_rd_rsp),//input
    //Pipe Interface
    .pipe_lu_req_q1       (pipe_lu_req_q1), //output
    .pipe_early_lu_rsp_q2 (pipe_early_lu_rsp_q2),
    .pipe_lu_rsp_q3       (pipe_lu_rsp_q3)  //input
);

d_cache_pipe_wrap d_cache_pipe_wrap (
    .clk                (clk),               //input
    .rst                (rst),               //input
    //Pipe Interface
    .pipe_lu_req_q1       (pipe_lu_req_q1),    //input
    .pipe_early_lu_rsp_q2 (pipe_early_lu_rsp_q2),
    .pipe_lu_rsp_q3       (pipe_lu_rsp_q3),    //output
    //FM Interface
    .cache2fm_req_q3 (cache2fm_req_q3)//output
);


endmodule