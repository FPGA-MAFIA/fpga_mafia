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

module cache_ref_model 
    import d_cache_param_pkg::*;  //FIXME: what about i_cache_param_pkg
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
logic [1:0]               req_byte_offset;
logic [CL_ADRS_WIDTH-1:0] req_cl_address;
t_req                     shifted_core2cache_req;
assign req_cl_address  = core2cache_req.address[MSB_TAG:LSB_SET];                //[19:4]
assign req_word_offset = core2cache_req.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET];//[3:2]
assign req_byte_offset = core2cache_req.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET];//[1:0]

always_comb begin
    next_mem = mem;

    shifted_core2cache_req = core2cache_req;
    if(req_byte_offset == 2'b01) begin
        shifted_core2cache_req.data    =  {core2cache_req.data[23:0], 8'b0};
        shifted_core2cache_req.byte_en =  {core2cache_req.byte_en[2:0], 1'b0};
    end
    else if (req_byte_offset == 2'b10) begin
        shifted_core2cache_req.data    =  {core2cache_req.data[15:0], 16'b0};
        shifted_core2cache_req.byte_en =  {core2cache_req.byte_en[1:0], 2'b0};
    end
    else if (req_byte_offset == 2'b11) begin
        shifted_core2cache_req.data    =  {core2cache_req.data[7:0], 24'b0};
        shifted_core2cache_req.byte_en =  {core2cache_req.byte_en[0], 3'b0}; 
    end
    else begin    
        shifted_core2cache_req.data    =  core2cache_req.data;
        shifted_core2cache_req.byte_en =  core2cache_req.byte_en;
    end
    
    if(core2cache_req.valid && (core2cache_req.opcode == WR_OP))
        if(req_word_offset == 2'b00 && shifted_core2cache_req.byte_en[0])  next_mem[req_cl_address][7:0]     = shifted_core2cache_req.data[7:0];   //8'b
        if(req_word_offset == 2'b00 && shifted_core2cache_req.byte_en[1])  next_mem[req_cl_address][15:8]    = shifted_core2cache_req.data[15:8];  //8'b
        if(req_word_offset == 2'b00 && shifted_core2cache_req.byte_en[2])  next_mem[req_cl_address][23:16]   = shifted_core2cache_req.data[23:16]; //8'b
        if(req_word_offset == 2'b00 && shifted_core2cache_req.byte_en[3])  next_mem[req_cl_address][31:24]   = shifted_core2cache_req.data[31:24]; //8'b

        if(req_word_offset == 2'b01 && shifted_core2cache_req.byte_en[0])  next_mem[req_cl_address][39:32]   = shifted_core2cache_req.data[7:0];   //8'b
        if(req_word_offset == 2'b01 && shifted_core2cache_req.byte_en[1])  next_mem[req_cl_address][47:40]   = shifted_core2cache_req.data[15:8];  //8'b
        if(req_word_offset == 2'b01 && shifted_core2cache_req.byte_en[2])  next_mem[req_cl_address][55:48]   = shifted_core2cache_req.data[23:16]; //8'b
        if(req_word_offset == 2'b01 && shifted_core2cache_req.byte_en[3])  next_mem[req_cl_address][63:56]   = shifted_core2cache_req.data[31:24]; //8'b
        
        if(req_word_offset == 2'b10 && shifted_core2cache_req.byte_en[0])  next_mem[req_cl_address][71:64]   = shifted_core2cache_req.data[7:0];   //8'b
        if(req_word_offset == 2'b10 && shifted_core2cache_req.byte_en[1])  next_mem[req_cl_address][79:72]   = shifted_core2cache_req.data[15:8];  //8'b
        if(req_word_offset == 2'b10 && shifted_core2cache_req.byte_en[2])  next_mem[req_cl_address][87:80]   = shifted_core2cache_req.data[23:16]; //8'b
        if(req_word_offset == 2'b10 && shifted_core2cache_req.byte_en[3])  next_mem[req_cl_address][95:88]   = shifted_core2cache_req.data[31:24]; //8'b

        if(req_word_offset == 2'b11 && shifted_core2cache_req.byte_en[0])  next_mem[req_cl_address][103:96]  = shifted_core2cache_req.data[7:0];   //8'b
        if(req_word_offset == 2'b11 && shifted_core2cache_req.byte_en[1])  next_mem[req_cl_address][111:104] = shifted_core2cache_req.data[15:8];  //8'b
        if(req_word_offset == 2'b11 && shifted_core2cache_req.byte_en[2])  next_mem[req_cl_address][119:112] = shifted_core2cache_req.data[23:16]; //8'b
        if(req_word_offset == 2'b11 && shifted_core2cache_req.byte_en[3])  next_mem[req_cl_address][127:120] = shifted_core2cache_req.data[31:24]; //8'b
        
        //if(req_word_offset == 2'b00)  next_mem[req_cl_address][31:0]   = core2cache_req.data; //32'b
        //if(req_word_offset == 2'b01)  next_mem[req_cl_address][63:32]  = core2cache_req.data; //32'b
        //if(req_word_offset == 2'b10)  next_mem[req_cl_address][95:64]  = core2cache_req.data; //32'b
        //if(req_word_offset == 2'b11)  next_mem[req_cl_address][127:96] = core2cache_req.data; //32'b
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
t_word          pre_rd_rsp_data, pre_shifted_rd_rsp_data, rd_rsp_data;

assign pre_cache2core_rsp.valid     = core2cache_req.valid && (core2cache_req.opcode == RD_OP);
assign pre_cache2core_rsp.address   = core2cache_req.address;
assign pre_cache2core_rsp.reg_id    = core2cache_req.reg_id;

//The data:
assign pre_shifted_rd_rsp_data = (req_word_offset == 2'b00) ? mem[req_cl_address][31:0]   :
                                 (req_word_offset == 2'b01) ? mem[req_cl_address][63:32]  :
                                 (req_word_offset == 2'b10) ? mem[req_cl_address][95:64]  :
                                 (req_word_offset == 2'b11) ? mem[req_cl_address][127:96] : 32'hDEAD_BEAF;

assign pre_rd_rsp_data = (req_byte_offset == 2'b01) ? {8'b0,  pre_shifted_rd_rsp_data[31:8]}  :
                         (req_byte_offset == 2'b10) ? {16'b0, pre_shifted_rd_rsp_data[31:16]} :
                         (req_byte_offset == 2'b11) ? {24'b0, pre_shifted_rd_rsp_data[31:24]} :
                                                              pre_shifted_rd_rsp_data         ;
                                                              
assign rd_rsp_data[7:0]   = core2cache_req.byte_en[0]  ? pre_rd_rsp_data[7:0]        : 8'h0;
assign rd_rsp_data[15:8]  = core2cache_req.byte_en[1]  ? pre_rd_rsp_data[15:8]       :
                            core2cache_req.sign_extend ? {8{rd_rsp_data[7]}}         : 8'h0;
assign rd_rsp_data[23:16] = core2cache_req.byte_en[2]  ? pre_rd_rsp_data[23:16]      :
                            core2cache_req.sign_extend ? {8{rd_rsp_data[15]}}        : 8'h0; 
assign rd_rsp_data[31:24] = core2cache_req.byte_en[3]  ? pre_rd_rsp_data[31:24]      :
                            core2cache_req.sign_extend ? {8{rd_rsp_data[23]}}        : 8'h0; 

assign pre_cache2core_rsp.data = rd_rsp_data;

`MAFIA_DFF(cache2core_rsp, pre_cache2core_rsp, clk)


endmodule