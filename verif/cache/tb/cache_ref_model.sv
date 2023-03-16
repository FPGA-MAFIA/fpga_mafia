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
`include "macros.sv"

module cache_ref_model 
    import cache_param_pkg::*;  
(
    input   logic           clk,
    input   logic           rst,
    //Core Interface
    input   var t_req       core2cache_req,
    output  t_rd_rsp        cache2core_rsp  //RD Response
);


localparam NUM_FM_CL = 2**(CL_ADRS_WIDTH);
t_cl    mem       [NUM_FM_CL-1:0];
t_cl    next_mem  [NUM_FM_CL-1:0];
//=======================================
//          Writing to memory
//=======================================
logic [1:0]               req_word_offset;
logic [CL_ADRS_WIDTH-1:0] req_cl_address;
assign req_cl_address  = core2cache_req.address[MSB_TAG:LSB_SET];                //[19:4]
assign req_word_offset = core2cache_req.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET];//[3:2]
always_comb begin
    next_mem = mem;
    if(core2cache_req.valid && (core2cache_req.opcode == WR_OP)) 
        if(req_word_offset == 2'b00)  next_mem[req_cl_address][31:0]   = core2cache_req.data; //32'b
        if(req_word_offset == 2'b01)  next_mem[req_cl_address][63:32]  = core2cache_req.data; //32'b
        if(req_word_offset == 2'b10)  next_mem[req_cl_address][95:64]  = core2cache_req.data; //32'b
        if(req_word_offset == 2'b11)  next_mem[req_cl_address][127:96] = core2cache_req.data; //32'b
end 

//=======================================
//          the memory Array
//=======================================

logic mem_write_enable;
assign mem_write_enable = core2cache_req.valid && (core2cache_req.opcode == WR_OP);
genvar MEM_ENTRY;
generate for(MEM_ENTRY=0; MEM_ENTRY<NUM_FM_CL; MEM_ENTRY++) begin
    `MAFIA_EN_RST_DFF(mem[MEM_ENTRY], next_mem[MEM_ENTRY], clk, mem_write_enable, rst)
end endgenerate

//=======================================
//          reading the memory
//=======================================
t_rd_rsp        pre_cache2core_rsp;
t_cl            rd_rsp_data;

assign pre_cache2core_rsp.valid     = core2cache_req.valid && (core2cache_req.opcode == RD_OP);
assign pre_cache2core_rsp.address   = core2cache_req.address;
assign pre_cache2core_rsp.reg_id    = core2cache_req.reg_id;

//The data:
assign rd_rsp_data = (req_word_offset == 2'b00) ? mem[req_cl_address][31:0]   :
                     (req_word_offset == 2'b01) ? mem[req_cl_address][63:32]  :
                     (req_word_offset == 2'b10) ? mem[req_cl_address][95:64]  :
                     (req_word_offset == 2'b11) ? mem[req_cl_address][127:96] : 32'hDEAD_BEAF;
assign pre_cache2core_rsp.data = rd_rsp_data;

`MAFIA_DFF(cache2core_rsp, pre_cache2core_rsp, clk)


endmodule