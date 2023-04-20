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

module cache_pipe_wrap 
    import cache_param_pkg::*;  
(
    input   logic        clk,
    input   logic        rst,
    //Agent Interface
    input   var t_lu_req       pipe_lu_req_q1,
    output  var t_early_lu_rsp pipe_early_lu_rsp_q2,
    output  t_lu_rsp           pipe_lu_rsp_q3,
    // FM Interface
    output  t_fm_req  cache2fm_req_q3
);

t_set_rd_req rd_set_req_q1;
t_set_rd_rsp rd_data_set_rsp_q2;
t_set_wr_req wr_data_set_q2;
t_cl_rd_req  rd_cl_req_q2; 
t_cl_rd_rsp  rd_data_cl_rsp_q3; 
t_cl_wr_req  wr_data_cl_q3; 

cache_pipe cache_pipe(
    .clk                    (clk),               //input
    .rst                    (rst),               //input
    //tq interface
    .pipe_lu_req_q1         (pipe_lu_req_q1),    //input
    .pipe_early_lu_rsp_q2   (pipe_early_lu_rsp_q2),
    .pipe_lu_rsp_q3         (pipe_lu_rsp_q3),    //output
    // FM interface request 
    .cache2fm_req_q3     (cache2fm_req_q3),//output
    //tag_array interface
    .rd_set_req_q1          (rd_set_req_q1),     //output
    .pre_rd_data_set_rsp_q2 (rd_data_set_rsp_q2),//input
    .wr_data_set_q2         (wr_data_set_q2),    //output
    //data_array interface
    .rd_cl_req_q2           (rd_cl_req_q2),      //output
    .pre_rd_data_cl_rsp_q3  (rd_data_cl_rsp_q3), //input
    .wr_data_cl_q3          (wr_data_cl_q3)      //output
);

//============================
//          TAG ARRAY
//============================
//============================
array #(
    .WORD_WIDTH     (SET_WIDTH),        // {tag,valid,modified,lru,fill} * NUM_WAYS
    .ADRS_WIDTH     (SET_ADRS_WIDTH)    // 2^SET_ADRS_WIDTH -> array size
) tag_array (
    .clk            (clk),                     //input
    .rst            (rst),                     //input
    //write interface
    .wr_en          (wr_data_set_q2.en),       //input
    .wr_address     (wr_data_set_q2.set),      //input
    .wr_data        ({wr_data_set_q2.tags,     // #way x tag_width
                      wr_data_set_q2.valid,    // #way 
                      wr_data_set_q2.modified, // #way 
                      wr_data_set_q2.mru}),   // #way
    //read interface
    .rd_address     (rd_set_req_q1.set),       //input
    .q              (rd_data_set_rsp_q2)       //output
);

//============================
//          DATA ARRAY
//============================
//============================
array  #(
    .WORD_WIDTH     (CL_WIDTH),
    .ADRS_WIDTH     (SET_ADRS_WIDTH + WAY_WIDTH)
) data_array (
    .clk            (clk),                     //input
    .rst            (rst),                     //input
    //write interface
    .wr_en          (wr_data_cl_q3.valid),     //input
    .wr_address     (wr_data_cl_q3.cl_address),//input
    .wr_data        (wr_data_cl_q3.data),      //input
    //read interface
    .rd_address     (rd_cl_req_q2),            //input
    .q              (rd_data_cl_rsp_q3)        //output
);


endmodule