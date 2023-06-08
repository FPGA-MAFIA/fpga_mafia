//this is the systemverilog memory subsystem module (mem_ss)
module mem_ss
    import mem_ss_param_pkg::*;  
(
    input logic clk,
    input logic rst,
    //=========================================================================
    // interface from big_core unit
    //=========================================================================
    //i_cache
    input  var t_req    imem_core2cache_req,
    output logic        imem_ready,
    output t_rd_rsp     imem_cache2core_rsp,
    //d_cache
    input  var t_req    dmem_core2cache_req,
    output logic        dmem_ready,
    output t_rd_rsp     dmem_cache2core_rsp,
    //=========================================================================
    // interface to the off die sram 
    //=========================================================================
    //TODO - for now using simple t_fm_req
    output var t_fm_req    cl_req_to_sram,
    input  var t_sram_rd_rsp cl_rsp_from_sram
);


t_fm_req imem_cache2fm_req_q3;
t_fm_rd_rsp i_fm2cache_rd_rsp;          
t_fm_req dmem_cache2fm_req_q3;
t_fm_rd_rsp d_fm2cache_rd_rsp;          

i_cache i_cache ( //DUT
   .clk                (clk),                //input   logic
   .rst                (rst),                //input   logic
    //Agent Interface     
   .core2cache_req     (imem_core2cache_req), //input   
   .ready              (imem_ready),          //output  logic
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
   .ready              (dmem_ready),          //output  logic
   .cache2core_rsp     (dmem_cache2core_rsp), //output  t_rd_rsp
    // FM Interface                   
   .cache2fm_req_q3    (dmem_cache2fm_req_q3),//output  t_fm_req
   .fm2cache_rd_rsp    (d_fm2cache_rd_rsp) //input   var t_fm_rd_rsp
);


// MC (memory controller) will accept the FM (far memory) requests and will pass it on to the off die SRAM
// MC will also accept the DRAM responses and will pass it on to the cache
mc mc ( //memory controller
    .clk                (clk),            //input   logic
    .rst                (rst),             //input   logic
    // d_cache interface
   .d_cache2fm_req_q3    (dmem_cache2fm_req_q3),//output  t_fm_req
   .mc2d_cache_ready     (),                    //output  logic        mc2d_cache_ready ,
   .d_fm2cache_rd_rsp    (d_fm2cache_rd_rsp),   //input   var t_fm_rd_rsp_cache and i_cache requests to the memory controller within the MC
    // i_cache interface
   .i_fm2cache_rd_rsp    (i_fm2cache_rd_rsp),   //input   var t_fm_rd_rsp
   .mc2i_cache_ready     (),                    //output  logic        mc2i_cache_ready ,
   .i_cache2fm_req_q3    (imem_cache2fm_req_q3),//output  t_fm_req
   // sram interface   TODO
   .cl_req_to_sram       (cl_req_to_sram),      //output  t_fm_req
   .sram_ready           (1'b1),                  //input   logic           sram_ready,
   .cl_rsp_from_sram     (cl_rsp_from_sram)     //input  t_fm_rd_rsp
);


endmodule
