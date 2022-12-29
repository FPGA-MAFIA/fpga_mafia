//-----------------------------------------------------------------------------
// Title            : Cache
// Project          : riscv_manycore_mesh_fpga 
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

module cache 
    import cache_param_pkg::*;  
(
    input   logic           clk,
    input   logic           rst,
    //Core Inteface
    input   var t_req       core2cache_req,
    output  logic           stall,
    output  t_rd_rsp        cache2core_rsp, //RD Response
    // FM Interface
    output  t_fm_wr_req     cache2fm_wr_req_q3, // WB -> Dirty evict
    output  t_fm_rd_req     cache2fm_rd_req_q3, // Cache Miss
    input   var t_fm_rd_rsp fm2cache_rd_rsp
);

t_lu_req    pipe_lu_req_q1;
t_lu_rsp    pipe_lu_rsp_q3;


cache_tq cache_tq (
    .clk             (clk),            //input
    .rst             (rst),            //input
    //Agent Interface
    .core2cache_req  (core2cache_req), //input
    .stall           (stall),          //output
    .cache2core_rsp  (cache2core_rsp), //output
    //FM Inteface
    .fm2cache_rd_rsp (fm2cache_rd_rsp),//input
    //Pipe Interface
    .pipe_lu_req_q1  (pipe_lu_req_q1), //output
    .pipe_lu_rsp_q3  (pipe_lu_rsp_q3)  //input
);

cache_pipe_wrap cache_pipe_wrap (
    .clk                (clk),               //input
    .rst                (rst),               //input
    //Pipe Interface
    .pipe_lu_req_q1     (pipe_lu_req_q1),    //input
    .pipe_lu_rsp_q3     (pipe_lu_rsp_q3),    //output
    //FM Inteface
    .cache2fm_rd_req_q3 (cache2fm_rd_req_q3),//output
    .cache2fm_wr_req_q3 (cache2fm_wr_req_q3) //output
);



endmodule