`include "macros.sv"

module cache_tb ;

import cache_param_pkg::*;  
logic             clk;
logic             rst;
t_req             core2cache_req;
logic             stall;
t_rd_rsp          cache2core_rsp;
t_fm_req       cache2fm_req_q3;
t_fm_rd_rsp [9:0] samp_fm2cache_rd_rsp;
t_fm_rd_rsp       fm2cache_rd_rsp;

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

logic [SET_WIDTH-1:0] tag_mem   [(2**SET_ADRS_WIDTH)-1:0];
logic [CL_WIDTH-1:0]  data_mem  [(2**(SET_ADRS_WIDTH + WAY_WIDTH))-1:0];




string test_name;
initial begin : start_test
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
$display("================\n     START\n================\n");
            rst= 1'b1;
            core2cache_req     = '0;
//exit reset
delay(80);  rst= 1'b0;
$display("====== Reset Done =======\n");
//start test
if(test_name == "cache_alive") begin
`include "cache_alive.sv"
end else 
if(test_name == "cache_alive_2") begin
`include "cache_alive_2.sv"
end
if(test_name == "single_fm_req") begin
`include "single_fm_req.sv"
end
if(test_name == "rd_modify_rd") begin
`include "rd_modify_rd.sv"
end
if(test_name == "wr_miss_rd_hit") begin
`include "wr_miss_rd_hit.sv"
end
if(test_name == "wr_miss_rd_hit_mb") begin
`include "wr_miss_rd_hit_mb.sv"
end
$display("\n\n================\n     Done\n================\n");

delay(80); $finish;
end// initial

`include "cache_trk.vh"

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

task delay(input int cycles);
  for(int i =0; i< cycles; i++) begin
    @(posedge clk);
  end
endtask

task backdoor_cache_load();

  for(int SET =0; SET< NUM_SET ; SET++) begin
    for(int WAY =0; WAY< NUM_WAYS; WAY++) begin
        back_door_entry.tags    [WAY] = WAY + 1000;
        back_door_entry.valid   [WAY] = 1'b1;
        back_door_entry.modified[WAY] = 1'b0;
        back_door_entry.mru     [WAY] = 1'b0;
    end
    tag_mem[SET]  = back_door_entry;
  end

  for(int D_WAY = 0; D_WAY< (SET_ADRS_WIDTH + WAY_WIDTH) ; D_WAY++) begin
    data_mem[D_WAY]  = 'h5000+D_WAY;
  end
    force cache.cache_pipe_wrap.tag_array.mem  = tag_mem;
    force cache.cache_pipe_wrap.data_array.mem = data_mem;
    delay(5);

    release cache.cache_pipe_wrap.data_array.mem;
    release cache.cache_pipe_wrap.tag_array.mem;
endtask

localparam NUM_FM_CL = 2**(SET_ADRS_WIDTH + TAG_WIDTH);
t_cl back_door_fm_mem   [NUM_FM_CL-1:0];
task backdoor_fm_load();
  $display("= backdoor_fm_load start =\n");
  for(int FM_ADDRESS =0; FM_ADDRESS < NUM_FM_CL ; FM_ADDRESS++) begin
        back_door_fm_mem[FM_ADDRESS] = FM_ADDRESS + 'hABBA_BABA_0000_1111;
  end
    force far_memory_array.mem  = back_door_fm_mem;
    delay(5);
    release far_memory_array.mem;
  $display("= backdoor_fm_load done =\n");
endtask

task wr_req( input logic [19:0]  address, 
             input logic [127:0] data ,
             input logic [4:0]   id );
    while (stall) begin
      delay(1); $display("-> stall! cant send write: %h ", address );
    end
$display("wr_req: %h , address %h:", id, address);
    core2cache_req.valid   =  1'b1;
    core2cache_req.opcode  =  WR_OP;
    core2cache_req.address =  address;
    core2cache_req.data    =  data;
    core2cache_req.reg_id  =  id;
    delay(1); 
    core2cache_req     = '0;
endtask

task rd_req( input logic [19:0] address,
             input logic [4:0] id); 
    while (stall) begin 
    delay(1);  $display("-> stall! cant send read: %h ", address);
    end
$display("rd_req: %h , address %h:", id, address);
    core2cache_req.valid   =  1'b1;
    core2cache_req.opcode  =  RD_OP;
    core2cache_req.address =  address;
    core2cache_req.reg_id  =  id;
    delay(1);
    core2cache_req     = '0;
endtask

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




endmodule // test_tb
