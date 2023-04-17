`include "macros.sv"

module cache_tb ;

import cache_param_pkg::*;  
logic             clk;
logic             rst;
t_req             core2cache_req;
logic             stall;
t_rd_rsp          cache2core_rsp;
t_fm_req          cache2fm_req_q3;
t_fm_rd_rsp [9:0] samp_fm2cache_rd_rsp;
t_fm_rd_rsp       fm2cache_rd_rsp;



int LOCAL_NUM_TAG_PULL; // used for setting the number of tag pulls from test itself
int LOCAL_NUM_SET_PULL; // used for setting the number of tag pulls from test itself

//default values - override from command line
parameter V_MAX_REQ_DELAY= 16;
parameter V_MIN_REQ_DELAY= 15;
parameter V_NUM_REQ      = 50;
parameter V_RD_RATIO     = 25;
parameter V_NUM_SET_PULL = 2 ;//Max is MAX_NUM_SET_PULL
parameter V_NUM_TAG_PULL = 2 ;//Max is MAX_NUM_TAG_PULL

parameter V_MAX_NUM_SET_PULL  = 50;  //Max is 
parameter V_MAX_NUM_TAG_PULL  = 50;

logic [7:0] tag_pull [V_MAX_NUM_TAG_PULL:0];
logic [7:0] set_pull [V_MAX_NUM_SET_PULL:0];

//==================
//      clk Gen
//==================
initial begin: clock_gen
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end
end// clock_gen

t_set_rd_rsp back_door_entry ;
localparam NUM_FM_CL = 2**(SET_ADRS_WIDTH + TAG_WIDTH);
t_cl back_door_fm_mem   [NUM_FM_CL-1:0];
logic [SET_WIDTH-1:0] tag_mem   [(2**SET_ADRS_WIDTH)-1:0];
logic [CL_WIDTH-1:0]  data_mem  [(2**(SET_ADRS_WIDTH + WAY_WIDTH))-1:0];


string test_name;
initial begin : start_test
    if ($value$plusargs ("STRING=%s", test_name)) begin
        $display("STRING value %s", test_name);
    end
    $display("================\n     START\n================\n");
            rst= 1'b1;
            core2cache_req     = '0;
//exit reset
delay(80);  rst= 1'b0;
$display("====== Reset Done =======\n");
//start test
if(test_name == "cache_alive") begin
`include "cache_alive.sv"
end else if(test_name == "cache_alive_2") begin
`include "cache_alive_2.sv"
end else if(test_name == "single_fm_req") begin
`include "single_fm_req.sv"
end else if(test_name == "rd_modify_rd") begin
`include "rd_modify_rd.sv"
end else if(test_name == "wr_miss_rd_hit") begin
`include "wr_miss_rd_hit.sv"
end else if(test_name == "wr_miss_rd_hit_mb") begin
`include "wr_miss_rd_hit_mb.sv"
end else if(test_name == "wr_miss_wr_hit") begin
`include "wr_miss_wr_hit.sv"
end else if(test_name == "wr_after_wr_cl") begin
`include "wr_after_wr_cl.sv"
end else if(test_name == "fill_8_tq_entries") begin
`include "fill_8_tq_entries.sv"
end else if(test_name == "wr_b2b_same_cl") begin
`include "wr_b2b_same_cl.sv"
end else if(test_name == "wr_b2b_hit") begin
`include "wr_b2b_hit.sv"
end else if(test_name == "rd_b2b_hit") begin
`include "rd_b2b_hit.sv"
end else if(test_name == "rd_b2b_same_cl") begin
`include "rd_b2b_same_cl.sv"
end else if(test_name == "rd_b2b_diff_cl") begin
`include "rd_b2b_diff_cl.sv"
end else if(test_name == "rand_simple") begin
`include "rand_simple.sv"
end else if(test_name == "rand_set_stress") begin
`include "rand_set_stress.sv"
end else  if(test_name == "rand_wr") begin
`include "rand_wr.sv"
end else  if(test_name == "many_tag_one_set") begin
`include "many_tag_one_set.sv"
end else begin
    $display("\n\n=============================================");
    $display("ERROR: Test %s not found", test_name);
    $display("=============================================");
    delay(80); $finish;
    $finish;
end
$display("\n\n================\n     Done\n================\n");

delay(80); $finish;
end// initial

`include "cache_trk.vh"
`include "cache_tasks.vh"

cache cache ( //DUT
   .clk                (clk),            //input   logic
   .rst                (rst),            //input   logic
    //Agent Interface                      
   .core2cache_req     (core2cache_req), //input   
   .stall              (stall),          //output  logic
   .cache2core_rsp     (cache2core_rsp), //output  t_rd_rsp
    // FM Interface                   
   .cache2fm_req_q3    (cache2fm_req_q3),//output  t_fm_req
   .fm2cache_rd_rsp    (fm2cache_rd_rsp) //input   var t_fm_rd_rsp
);


//============================
//          Far Memory ARRAY
//============================
array  #(
    .WORD_WIDTH     (CL_WIDTH),
    .ADRS_WIDTH     (SET_ADRS_WIDTH + TAG_WIDTH)
) far_memory_array (
    .clk            (clk),                                     //input
    .rst            (rst),                                     //input
    //write interface
    .wr_en          (cache2fm_req_q3.valid && (cache2fm_req_q3.opcode == DIRTY_EVICT_OP)),                   //input
    .wr_address     (cache2fm_req_q3.address[MSB_TAG:LSB_SET]),//input
    .wr_data        (cache2fm_req_q3.data),                    //input
    //read interface
    .rd_address     (cache2fm_req_q3.address[MSB_TAG:LSB_SET]),//input
    .q              (samp_fm2cache_rd_rsp[0].data)                //output
);

// One Cycle Latency on memory read - sample the id & Valid.
`MAFIA_DFF(samp_fm2cache_rd_rsp[0].tq_id   ,cache2fm_req_q3.tq_id     , clk)
`MAFIA_DFF(samp_fm2cache_rd_rsp[0].valid   ,cache2fm_req_q3.valid  && (cache2fm_req_q3.opcode == FILL_REQ_OP)   , clk)
// Shift register to add 10 cycle latecy on FM read.
`MAFIA_DFF(samp_fm2cache_rd_rsp[9:1]       ,samp_fm2cache_rd_rsp[8:0] , clk)
`MAFIA_DFF(fm2cache_rd_rsp                 ,samp_fm2cache_rd_rsp[9]   , clk)


t_rd_rsp          ref_cache2core_rsp;
cache_ref_model cache_ref_model (
    .clk                (clk),            //input   logic
    .rst                (rst),            //input   logic
    //Agent Interface                      
    .core2cache_req     (core2cache_req), //input   
    .cache2core_rsp     (ref_cache2core_rsp)  //output  t_rd_rsp
);

endmodule // test_tb
