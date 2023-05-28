//this is the systemverilog memory subsystem module (mem_ss)

module mem_ss (
    input logic clock,
    input logic rst,
    //=========================================================================
    // interface from big_core unit
    //=========================================================================
    //i_cache
    input  t_req    imem_core2cache_req,
    output logic    imem_stall,
    output t_rd_rsp imem_cache2core_rsp,
    //d_cache
    input  t_req    dmem_core2cache_req,
    output logic    dmem_stall,
    output t_rd_rsp dmem_cache2core_rsp 
    //=========================================================================
    // interface to the off die sram 
    //=========================================================================
    //TODO

);


i_cache i_cache ( //DUT
   .clk                (clk),                //input   logic
   .rst                (rst),                //input   logic
    //Agent Interface     
   .core2cache_req     (imem_core2cache_req), //input   
   .stall              (imem_stall),          //output  logic
   .cache2core_rsp     (imem_cache2core_rsp), //output  t_rd_rsp
    // FM Interface                   
   .cache2fm_req_q3    (imem_cache2fm_req_q3),//output  t_fm_req
   .fm2cache_rd_rsp    (i_fm2cache_rd_rsp) //input   var t_fm_rd_rsp
);

d_cache d_cache ( //DUT
   .clk                (clk),            //input   logic
   .rst                (rst),            //input   logic
    //Agent Interface                      
   .core2cache_req     (dmem_core2cache_req), //input   
   .stall              (dmem_stall),          //output  logic
   .cache2core_rsp     (dmem_cache2core_rsp), //output  t_rd_rsp
    // FM Interface                   
   .cache2fm_req_q3    (dmem_cache2fm_req_q3),//output  t_fm_req
   .fm2cache_rd_rsp    (d_fm2cache_rd_rsp) //input   var t_fm_rd_rsp
);


// MC (memory controller) will accept the FM (far memory) requests and will pass it on to the off die SRAM
// MC will also accept the DRAM responses and will pass it on to the cache
mc mc ( //memory controller
    .clk                (clk),            //input   logic
    .rst                (rst)             //input   logic
    // d_cache interface
   .d_cache2fm_req_q3    (dmem_cache2fm_req_q3),//output  t_fm_req
   .d_fm2cache_rd_rsp    (d_fm2cache_rd_rsp), //input   var t_fm_rd_rsp_cache and i_cache requests to the memory controller within the MC
    // i_cache interface
   .i_fm2cache_rd_rsp    (i_fm2cache_rd_rsp), //input   var t_fm_rd_rsp
   .i_cache2fm_req_q3    (imem_cache2fm_req_q3) //output  t_fm_req
   // sram interface   TODO
)


endmodule
