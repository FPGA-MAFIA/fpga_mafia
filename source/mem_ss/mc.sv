// this is the system verilog memory controller unit (MC)

module mc 
import mem_ss_param_pkg::*;
(
   input   logic        clk               ,
   input   logic        rst               ,

   input   var t_fm_req d_cache2fm_req_q3 ,
   output  logic        mc2d_cache_ready ,
   output  t_fm_rd_rsp  d_fm2cache_rd_rsp ,

   input   var t_fm_req i_cache2fm_req_q3,
   output  logic        mc2i_cache_ready,
   output  t_fm_rd_rsp  i_fm2cache_rd_rsp,

   output  t_fm_req        cl_req_to_sram,
   input   logic           sram_ready,
   input   var t_sram_rd_rsp cl_rsp_from_sram  
);
logic i_mem_fifo_full;
logic d_mem_fifo_full;
logic pop_i_mem_fifo;
t_fm_req i_cache2fm_req_q4;
t_fm_req d_cache2fm_req_q4;
logic i_mem_fifo_empty;
logic pop_d_mem_fifo;
logic d_mem_fifo_empty;
logic [1:0] valid_candidate;
logic [1:0] winner_dec_id;
logic [1:0] fifo_pop;

//TODO create "ready" indication to back pressure the cache sending requests to the MC (FIFOs full indication)
assign mc2i_cache_ready = ~i_mem_fifo_full;
assign mc2d_cache_ready = ~d_mem_fifo_full;

// as a first step, we will use a FIFO for each of the agents read/write requests
// and use a round robin arbiter to select the next request to be sent to the SRAM
fifo #(.DATA_WIDTH($bits(t_fm_req)),.FIFO_DEPTH(4))
        i_mem_fifo_req  (.clk       (clk),
                         .rst       (rst),
                         .push      (i_cache2fm_req_q3.valid),
                         .push_data (i_cache2fm_req_q3),
                         .pop       (pop_i_mem_fifo),
                         .pop_data  (i_cache2fm_req_q4),
                         .full      (i_mem_fifo_full),
                         .empty     (i_mem_fifo_empty)
                        );

fifo #(.DATA_WIDTH($bits(t_fm_req)),.FIFO_DEPTH(4))
        d_mem_fifo_req  (.clk       (clk),
                         .rst       (rst),
                         .push      (d_cache2fm_req_q3.valid),
                         .push_data (d_cache2fm_req_q3),
                         .pop       (pop_d_mem_fifo),
                         .pop_data  (d_cache2fm_req_q4),
                         .full      (d_mem_fifo_full),
                         .empty     (d_mem_fifo_empty)
                        );




assign valid_candidate[0] = ~i_mem_fifo_empty && sram_ready;
assign valid_candidate[1] = ~d_mem_fifo_empty && sram_ready;
arbiter #(.NUM_CLIENTS(2))
rr_arb(
    .clk(clk),
    .rst(rst),
    .valid_candidate(valid_candidate[1:0]),    // input from each fifo - not empty indication, valid candidate.
    .winner_dec_id  (winner_dec_id[1:0])  // the arbiter winner use to fifo pop.        
);

assign fifo_pop[1:0]   = winner_dec_id[1:0];
assign pop_i_mem_fifo  = fifo_pop[0] ;
assign pop_d_mem_fifo  = fifo_pop[1] ;

//detect if the response is for the I or D cache according to the 
localparam I_MEM_BASE_RANGE = 32'h00000000;
localparam I_MEM_TOP_RANGE  = 32'h0000ffff;
localparam D_MEM_BASE_RANGE = 32'h00010000;
localparam D_MEM_TOP_RANGE  = 32'h0001ffff;
logic sram_rsp_is_to_i_cache;
logic sram_rsp_is_to_d_cache;
assign sram_rsp_is_to_i_cache = (cl_rsp_from_sram.address < I_MEM_TOP_RANGE) && (cl_rsp_from_sram.address >= I_MEM_BASE_RANGE);
assign sram_rsp_is_to_d_cache = (cl_rsp_from_sram.address < D_MEM_TOP_RANGE) && (cl_rsp_from_sram.address >= D_MEM_BASE_RANGE);
assign i_fm2cache_rd_rsp.valid = sram_rsp_is_to_i_cache && cl_rsp_from_sram.valid;
assign d_fm2cache_rd_rsp.valid = sram_rsp_is_to_d_cache && cl_rsp_from_sram.valid;
assign i_fm2cache_rd_rsp.data  = cl_rsp_from_sram.data;
assign d_fm2cache_rd_rsp.data  = cl_rsp_from_sram.data;
assign d_fm2cache_rd_rsp.tq_id = '0;//TODO - keep track of the transaction to assign the correct TQ

assign cl_req_to_sram = winner_dec_id[0] ? i_cache2fm_req_q4 :
                        winner_dec_id[1] ? d_cache2fm_req_q4 :
                                           '0;         
endmodule