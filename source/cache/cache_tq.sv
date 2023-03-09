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

module  cache_tq 
    import cache_param_pkg::*;  
(
    input   logic           clk,        
    input   logic           rst,        
    //core Interface
    input   var t_req       core2cache_req,
    output  logic           stall,
    output  t_rd_rsp        cache2core_rsp,
    //FM Interface
    input   var t_fm_rd_rsp fm2cache_rd_rsp,
    //Pipe Interface
    output  t_lu_req        pipe_lu_req_q1,
    input   var t_lu_rsp    pipe_lu_rsp_q3
);
t_tq_state [NUM_TQ_ENTRY-1:0] tq_state;
t_tq_state [NUM_TQ_ENTRY-1:0] next_tq_state;


logic [NUM_TQ_ENTRY-1:0] rd_req_hit_mb;
logic [NUM_TQ_ENTRY-1:0] wr_req_hit_mb;
logic any_rd_hit_mb;
logic any_wr_hit_mb;

logic [NUM_TQ_ENTRY-1:0] free_entries;
logic [NUM_TQ_ENTRY-1:0] allocate_entry;
logic [NUM_TQ_ENTRY-1:0] first_free;
logic [NUM_TQ_ENTRY-1:0] fill_entries;
logic [NUM_TQ_ENTRY-1:0] first_fill;

t_reg_id [NUM_TQ_ENTRY-1:0]     tq_reg_id; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_merge_buffer_e_modified; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_merge_buffer_data; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_cl_address; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_cl_word_offset; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_rd_indication; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_wr_indication; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_reg_id; 

logic        [NUM_TQ_ENTRY-1:0][NUM_WORDS_IN_CL-1:0]  tq_merge_buffer_e_modified; 
t_cl         [NUM_TQ_ENTRY-1:0] tq_merge_buffer_data; 
t_cl_address [NUM_TQ_ENTRY-1:0] tq_cl_address;
t_word_offset[NUM_TQ_ENTRY-1:0] tq_cl_word_offset; 
logic        [NUM_TQ_ENTRY-1:0] tq_rd_indication; 
logic        [NUM_TQ_ENTRY-1:0] tq_wr_indication; 
logic        [NUM_TQ_ENTRY-1:0][NUM_WORDS_IN_CL-1:0]  next_tq_merge_buffer_e_modified; 
t_cl         [NUM_TQ_ENTRY-1:0] next_tq_merge_buffer_data; 
t_cl_address [NUM_TQ_ENTRY-1:0] next_tq_cl_address; 
t_word_offset[NUM_TQ_ENTRY-1:0] next_tq_cl_word_offset; 
logic        [NUM_TQ_ENTRY-1:0] next_tq_rd_indication; 
logic        [NUM_TQ_ENTRY-1:0] next_tq_wr_indication; 
logic        [NUM_TQ_ENTRY-1:0] next_tq_reg_id; 


logic rd_hit_pipe_rsp_q3;
logic fill_with_rd_indication;

assign rd_hit_pipe_rsp_q3     = pipe_lu_rsp_q3.valid               && 
                               (pipe_lu_rsp_q3.lu_op == RD_LU) &&
                               (pipe_lu_rsp_q3.lu_result == HIT);

assign fill_with_rd_indication = pipe_lu_rsp_q3.valid  && 
                                (pipe_lu_rsp_q3.lu_op == FILL_LU) &&
                                tq_rd_indication[pipe_lu_rsp_q3.tq_id];

assign cache2core_rsp.valid =   rd_hit_pipe_rsp_q3 || fill_with_rd_indication;
//take the relevant word from cache line
assign cache2core_rsp.data    = pipe_lu_rsp_q3.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET] == 2'b00 ?  pipe_lu_rsp_q3.cl_data[31:0]  : 
                                pipe_lu_rsp_q3.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET] == 2'b01 ?  pipe_lu_rsp_q3.cl_data[63:32] : 
                                pipe_lu_rsp_q3.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET] == 2'b10 ?  pipe_lu_rsp_q3.cl_data[95:64] :
                                                                                                    pipe_lu_rsp_q3.cl_data[127:96];
assign cache2core_rsp.address = pipe_lu_rsp_q3.address; //FIXME: address should come from tq_entry
assign cache2core_rsp.reg_id  = tq_reg_id[pipe_lu_rsp_q3.tq_id]; //FIXME



genvar TQ_GEN;
generate for(TQ_GEN=0; TQ_GEN<NUM_TQ_ENTRY; TQ_GEN=TQ_GEN+1) begin : tq_generate_ff_block
    `MAFIA_RST_VAL_DFF(tq_state                  [TQ_GEN], next_tq_state                  [TQ_GEN], clk, rst, S_IDLE)
    `MAFIA_EN_DFF     (tq_rd_indication          [TQ_GEN], next_tq_rd_indication          [TQ_GEN], clk, en_tq_rd_indication          [TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_wr_indication          [TQ_GEN], next_tq_wr_indication          [TQ_GEN], clk, en_tq_wr_indication          [TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_merge_buffer_data      [TQ_GEN], next_tq_merge_buffer_data      [TQ_GEN], clk, en_tq_merge_buffer_data      [TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_merge_buffer_e_modified[TQ_GEN], next_tq_merge_buffer_e_modified[TQ_GEN], clk, en_tq_merge_buffer_e_modified[TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_cl_address             [TQ_GEN], next_tq_cl_address             [TQ_GEN], clk, en_tq_cl_address             [TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_cl_word_offset         [TQ_GEN], next_tq_cl_word_offset         [TQ_GEN], clk, en_tq_cl_word_offset         [TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_reg_id                 [TQ_GEN], next_tq_reg_id                 [TQ_GEN], clk, en_tq_reg_id                 [TQ_GEN])
end endgenerate

logic [MSB_WORD_OFFSET:LSB_WORD_OFFSET ] new_alloc_word_offset;
always_comb begin
    for (int i=0; i<NUM_TQ_ENTRY; ++i) begin
        allocate_entry[i] = first_free[i] && core2cache_req.valid && (!any_rd_hit_mb) && (!any_wr_hit_mb);
    end
    new_alloc_word_offset     = core2cache_req.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET];
    for (int i=0; i<NUM_TQ_ENTRY; ++i) begin
        next_tq_state            [i] = tq_state[i];
        next_tq_merge_buffer_e_modified[i] = '0;    //default value
        next_tq_merge_buffer_data[i] = '0;
        next_tq_cl_address       [i] = '0;
        next_tq_rd_indication    [i] = '0;
        next_tq_wr_indication    [i] = '0;
        en_tq_merge_buffer_data  [i] = '0;
        en_tq_cl_address         [i] = '0;
        en_tq_rd_indication      [i] = '0;
        en_tq_wr_indication      [i] = '0;
        en_tq_merge_buffer_e_modified[i] = '0;
        unique casez (tq_state[i])
            S_IDLE                : begin
                //if core_req && tq_entry_winner : next_state == LU_CORE_WR/RD_REQ 
                if (allocate_entry[i]) begin
                    next_tq_state[i] =  ((core2cache_req.opcode == RD_OP) || ( core2cache_req.opcode == WR_OP)) ? S_LU_CORE :
                                                                                                                  S_ERROR   ;
                    en_tq_rd_indication             [i] = 1'b1;
                    en_tq_cl_word_offset            [i] = 1'b1;
                    en_tq_wr_indication             [i] = 1'b1;
                    en_tq_reg_id                    [i] = 1'b1;
                    en_tq_cl_address                [i] = 1'b1;
                    en_tq_merge_buffer_e_modified   [i] = 1'b1;
                    en_tq_merge_buffer_data         [i] = 1'b1;
                    next_tq_rd_indication           [i] = (core2cache_req.opcode == RD_OP);
                    next_tq_wr_indication           [i] = (core2cache_req.opcode == WR_OP);
                    next_tq_reg_id                  [i] = core2cache_req.reg_id;
                    next_tq_cl_address              [i] = core2cache_req.address[MSB_TAG:LSB_SET];
                    next_tq_cl_word_offset          [i] = core2cache_req.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET];
                    if(core2cache_req.opcode == WR_OP) begin
                        //write the data to the correct word offset in the merge buffer
                        next_tq_merge_buffer_data[i][31:0]   = (new_alloc_word_offset == 2'd0) ? core2cache_req.data : '0;
                        next_tq_merge_buffer_data[i][63:32]  = (new_alloc_word_offset == 2'd1) ? core2cache_req.data : '0;
                        next_tq_merge_buffer_data[i][95:64]  = (new_alloc_word_offset == 2'd2) ? core2cache_req.data : '0;
                        next_tq_merge_buffer_data[i][127:96] = (new_alloc_word_offset == 2'd3) ? core2cache_req.data : '0;
                        //set the corresponding bit in the e_modified vector
                        next_tq_merge_buffer_e_modified[i][new_alloc_word_offset] = 1'b1;
                    end
                end
            end    
            //FIXME: in case of write after write to same cache line we still need to write the data to mb ?
            S_LU_CORE: begin
                //if Cache_hit : nex_state == IDLE
                //if Cache_miss : next_state == MB_WAIT_FILL
                if ((pipe_lu_rsp_q3.tq_id == i) && (pipe_lu_rsp_q3.valid)) begin  
                    next_tq_state[i]=   (pipe_lu_rsp_q3.lu_result == HIT)     ?   S_IDLE            :
                                        (pipe_lu_rsp_q3.lu_result == MISS)    ?   S_MB_WAIT_FILL    :
                                        (pipe_lu_rsp_q3.lu_result == FILL)    ?   S_LU_CORE         : // this FILL is from an older request, don't want it to affect the entry
                                        /*(pipe_lu_rsp_q3.lu_result == REJECT)*/  S_ERROR           ;
                end                    
            end
            S_MB_WAIT_FILL                : begin
                if(fm2cache_rd_rsp.valid && (fm2cache_rd_rsp.tq_id == i)) begin
                    next_tq_state[i] = S_MB_FILL_READY;
                    en_tq_merge_buffer_data  [i] = 1'b1;
                    // If the tq_merge_buffer_e_modified[i][x] is set, then the data in the merge buffer already has the correct data - we don't want to override it with the fill data
                    next_tq_merge_buffer_data[i][31:0]   = tq_merge_buffer_e_modified[i][0] ? tq_merge_buffer_data[i][31:0]   : fm2cache_rd_rsp.data[31:0];
                    next_tq_merge_buffer_data[i][63:32]  = tq_merge_buffer_e_modified[i][1] ? tq_merge_buffer_data[i][63:32]  : fm2cache_rd_rsp.data[63:32];
                    next_tq_merge_buffer_data[i][95:64]  = tq_merge_buffer_e_modified[i][2] ? tq_merge_buffer_data[i][95:64]  : fm2cache_rd_rsp.data[95:64];
                    next_tq_merge_buffer_data[i][127:96] = tq_merge_buffer_e_modified[i][3] ? tq_merge_buffer_data[i][127:96] : fm2cache_rd_rsp.data[127:96];
                end

                //The case of read after write - we set the read indication and update the offset for the read rsp:
                if(rd_req_hit_mb[i]) begin
                    en_tq_rd_indication   [i] = 1'b1;
                    en_tq_cl_word_offset  [i] = 1'b1;
                    next_tq_rd_indication [i] = 1'b1;
                    next_tq_cl_word_offset[i] = core2cache_req.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET];
                end //if
                
                if(wr_req_hit_mb[i]) begin
                    en_tq_wr_indication     [i] = 1'b1;
                    en_tq_merge_buffer_data [i] = 1'b1;
                    en_tq_merge_buffer_e_modified   [i] = 1'b1;
                    
                    next_tq_wr_indication   [i] = 1'b1;
                    //write the data to the correct word offset in the merge buffer
                    next_tq_merge_buffer_data[i][31:0]   = (new_alloc_word_offset == 2'd0) ? core2cache_req.data :  tq_merge_buffer_data[i][31:0]  ;
                    next_tq_merge_buffer_data[i][63:32]  = (new_alloc_word_offset == 2'd1) ? core2cache_req.data :  tq_merge_buffer_data[i][63:32] ;
                    next_tq_merge_buffer_data[i][95:64]  = (new_alloc_word_offset == 2'd2) ? core2cache_req.data :  tq_merge_buffer_data[i][95:64] ;
                    next_tq_merge_buffer_data[i][127:96] = (new_alloc_word_offset == 2'd3) ? core2cache_req.data :  tq_merge_buffer_data[i][127:96];
                    //set the corresponding bit in the e_modified vector
                    next_tq_merge_buffer_e_modified[i]                        = tq_merge_buffer_e_modified[i];
                    next_tq_merge_buffer_e_modified[i][new_alloc_word_offset] = 1'b1;
                end //if

            end //S_MB_WAIT_FILL
            S_MB_FILL_READY               : begin
                if(rd_req_hit_mb[i]) begin
                    en_tq_rd_indication   [i] = 1'b1;
                    en_tq_cl_word_offset  [i] = 1'b1;
                    next_tq_rd_indication [i] = 1'b1;
                    next_tq_cl_word_offset[i] = core2cache_req.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET];
                end //if
                if(wr_req_hit_mb[i]) begin
                    en_tq_wr_indication   [i] = 1'b1;
                    en_tq_cl_word_offset  [i] = 1'b1;
                    next_tq_wr_indication [i] = 1'b1;
                    next_tq_cl_word_offset[i] = core2cache_req.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET];
                end //if

                if (first_fill[i] && (!core2cache_req.valid)) begin // opportunistic pipe lookup - if no core request, then fill
                    next_tq_state[i] = S_IDLE;
                end //if
            end//S_MB_FILL_READY
            S_ERROR                       : begin
                next_tq_state[i] = tq_state[i];
            end
            default: begin
                next_tq_state[i] = tq_state[i];
            end

        endcase //casez
    end //for loop   
end //always_comb

always_comb begin
    for(int i =0; i<NUM_TQ_ENTRY; ++i) begin
        rd_req_hit_mb[i] = core2cache_req.valid             && 
                           (core2cache_req.opcode == RD_OP) &&
                           (core2cache_req.address[MSB_TAG:LSB_SET] == tq_cl_address[i]) &&
                           (!tq_rd_indication[i])           && 
                           ((tq_state[i] == S_MB_WAIT_FILL) || (tq_state[i] == S_MB_FILL_READY));
    
        wr_req_hit_mb[i] = core2cache_req.valid             && 
                           (core2cache_req.opcode == WR_OP) &&
                           (core2cache_req.address[MSB_TAG:LSB_SET] == tq_cl_address[i]) &&
                           ((tq_state[i] == S_MB_WAIT_FILL) || (tq_state[i] == S_MB_FILL_READY));
    
    end
end

always_comb begin
    stall            = 1'b1;                //default to stall
    for(int i =0; i<NUM_TQ_ENTRY; ++i) begin
        if(tq_state[i] == S_IDLE) begin     //if there is an idle entry, then no stall
            stall = 1'b0;
        end
    end
end

assign any_rd_hit_mb = |rd_req_hit_mb;
assign any_wr_hit_mb = |wr_req_hit_mb;

always_comb begin
    for (int i=0; i<NUM_TQ_ENTRY; ++i) begin
        free_entries[i] = (tq_state[i] == S_IDLE);
        fill_entries[i] = (tq_state[i] == S_MB_FILL_READY);
    end
end
`FIND_FIRST(first_free, free_entries)
//suppress the first free entry if there is a read hit in the merge buffer

//FIXME - need to replace with round robin
`FIND_FIRST(first_fill, fill_entries)

logic free_exists;
logic wr_hit_exists;
logic fill_exists;
t_tq_id enc_first_free;
t_tq_id enc_first_fill;
t_tq_id enc_wr_req_hit_mb;
`ENCODER(enc_first_free, free_exists, first_free)
`ENCODER(enc_first_fill, fill_exists, first_fill)
`ENCODER(enc_wr_req_hit_mb, wr_hit_exists, wr_req_hit_mb)

//=================
// Pipe lookup mux - core request vs fill request
//=================
always_comb begin
    pipe_lu_req_q1 = '0;
    if(core2cache_req.valid) begin
        pipe_lu_req_q1.valid   = core2cache_req.valid;
        pipe_lu_req_q1.lu_op   = (core2cache_req.opcode == WR_OP) ? WR_LU :
                                 (core2cache_req.opcode == RD_OP) ? RD_LU :
                                                                    NO_LU ;
        pipe_lu_req_q1.address       = core2cache_req.address;
        pipe_lu_req_q1.data          = core2cache_req.data;
        pipe_lu_req_q1.tq_id         = any_wr_hit_mb ? enc_wr_req_hit_mb : enc_first_free;
        pipe_lu_req_q1.mb_hit_cancel = any_rd_hit_mb || any_wr_hit_mb;
    end else if (fill_exists) begin
        pipe_lu_req_q1.valid         = 1'b1;
        pipe_lu_req_q1.lu_op         = FILL_LU;
        pipe_lu_req_q1.address       = {tq_cl_address      [enc_first_fill],tq_cl_word_offset[enc_first_fill],2'b00} ;//FIXME need to remember the correct address offset for the case that rd indication is set
        pipe_lu_req_q1.cl_data       = tq_merge_buffer_data[enc_first_fill];
        pipe_lu_req_q1.tq_id         = enc_first_fill;
        pipe_lu_req_q1.rd_indication = tq_rd_indication    [enc_first_fill];
        pipe_lu_req_q1.wr_indication = tq_wr_indication    [enc_first_fill];
    end //else if

end


endmodule
