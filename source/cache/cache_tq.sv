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
    //output 
    //Pipe Interface
    output  t_lu_req        pipe_lu_req_q1,
    input   var t_lu_rsp    pipe_lu_rsp_q3
);
t_tq_state [NUM_TQ_ENTRY-1:0] tq_state;
t_tq_state [NUM_TQ_ENTRY-1:0] next_tq_state;
assign stall            = '0;


logic [NUM_TQ_ENTRY-1:0] free_entries;
logic [NUM_TQ_ENTRY-1:0] first_free;
logic [NUM_TQ_ENTRY-1:0] fill_entries;
logic [NUM_TQ_ENTRY-1:0] first_fill;

t_reg_id [NUM_TQ_ENTRY-1:0] tq_reg_id; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_merge_buffer_data; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_cl_address; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_rd_indication; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_wr_indication; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_reg_id; 

t_cl         [NUM_TQ_ENTRY-1:0] tq_merge_buffer_data; 
t_cl_address [NUM_TQ_ENTRY-1:0] tq_cl_address;
logic        [NUM_TQ_ENTRY-1:0] tq_rd_indication; 
logic        [NUM_TQ_ENTRY-1:0] tq_wr_indication; 
t_cl         [NUM_TQ_ENTRY-1:0] next_tq_merge_buffer_data; 
t_cl_address [NUM_TQ_ENTRY-1:0] next_tq_cl_address; 
logic        [NUM_TQ_ENTRY-1:0] next_tq_rd_indication; 
logic        [NUM_TQ_ENTRY-1:0] next_tq_wr_indication; 
logic        [NUM_TQ_ENTRY-1:0] next_tq_reg_id; 


logic rd_hit_pipe_rsp_q3;
logic fill_with_rd_indication;

assign rd_hit_pipe_rsp_q3     =   pipe_lu_rsp_q3.valid               && 
                               (pipe_lu_rsp_q3.lu_opcode == RD_LU) &&
                               (pipe_lu_rsp_q3.lu_result == HIT);

assign fill_with_rd_indication = pipe_lu_rsp_q3.valid  && 
                                (pipe_lu_rsp_q3.lu_opcode == FILL_LU) &&
                                tq_rd_indication[pipe_lu_rsp_q3.tq_id];

assign cache2core_rsp.valid =   rd_hit_pipe_rsp_q3 || fill_with_rd_indication;
//take the relevant word from cache line
assign cache2core_rsp.data    = pipe_lu_rsp_q3.address[3:2] == 2'b00 ?  pipe_lu_rsp_q3.data[31:0]  : 
                                pipe_lu_rsp_q3.address[3:2] == 2'b01 ?  pipe_lu_rsp_q3.data[63:32] : 
                                pipe_lu_rsp_q3.address[3:2] == 2'b10 ?  pipe_lu_rsp_q3.data[95:64] :
                                                                        pipe_lu_rsp_q3.data[127:96];
assign cache2core_rsp.address = pipe_lu_rsp_q3.address; //FIXME: address should come from tq_entry
assign cache2core_rsp.reg_id  = tq_reg_id[pipe_lu_rsp_q3.tq_id]; //FIXME



genvar TQ_GEN;
generate for(TQ_GEN=0; TQ_GEN<NUM_TQ_ENTRY; TQ_GEN=TQ_GEN+1) begin : tq_generate_ff_block
    `MAFIA_RST_VAL_DFF(tq_state            [TQ_GEN], next_tq_state            [TQ_GEN], clk, rst, S_IDLE)
    `MAFIA_EN_DFF     (tq_rd_indication    [TQ_GEN], next_tq_rd_indication    [TQ_GEN], clk, en_tq_rd_indication    [TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_wr_indication    [TQ_GEN], next_tq_wr_indication    [TQ_GEN], clk, en_tq_wr_indication    [TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_merge_buffer_data[TQ_GEN], next_tq_merge_buffer_data[TQ_GEN], clk, en_tq_merge_buffer_data[TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_cl_address       [TQ_GEN], next_tq_cl_address       [TQ_GEN], clk, en_tq_cl_address       [TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_reg_id           [TQ_GEN], next_tq_reg_id           [TQ_GEN], clk, en_tq_reg_id           [TQ_GEN])
end endgenerate

always_comb begin
    for (int i=0; i<NUM_TQ_ENTRY; ++i) begin
        next_tq_state            [i] = tq_state[i];
        next_tq_merge_buffer_data[i] = '0;
        next_tq_cl_address       [i] = '0;
        next_tq_rd_indication    [i] = '0;
        next_tq_wr_indication    [i] = '0;
        en_tq_merge_buffer_data  [i] = '0;
        en_tq_cl_address         [i] = '0;
        en_tq_rd_indication      [i] = '0;
        en_tq_wr_indication      [i] = '0;
        unique casez (tq_state)
            S_IDLE                : 
                //if core_req && tq_entry_winner : next_state == LU_CORE_WR/RD_REQ 
                if (first_free[i] && core2cache_req.valid) begin
                    next_tq_state[i] =  (core2cache_req.opcode == RD_OP) || ( (core2cache_req.opcode == WR_OP) )    ? S_LU_CORE :
                                                                                                                      S_ERROR   ;
                    en_tq_rd_indication  [i] = 1'b1;
                    en_tq_wr_indication  [i] = 1'b1;
                    en_tq_reg_id         [i] = 1'b1;
                    en_tq_cl_address     [i] = 1'b1;
                    next_tq_rd_indication[i] = (core2cache_req.opcode == RD_OP);
                    next_tq_wr_indication[i] = (core2cache_req.opcode == WR_OP);
                    next_tq_reg_id       [i] = core2cache_req.reg_id;
                    next_tq_cl_address   [i] = core2cache_req.address[MSB_TAG:LSB_SET];
                end
            S_LU_CORE: 
                //if Cache_hit : nex_state == IDLE
                //if Cache_miss : next_state == MB_WAIT_FILL
                if ((pipe_lu_rsp_q3.tq_id == i) && (pipe_lu_rsp_q3.valid)) begin  
                    next_tq_state[i]=   (pipe_lu_rsp_q3.lu_result == HIT)     ?   S_IDLE            :
                                        (pipe_lu_rsp_q3.lu_result == MISS)    ?   S_MB_WAIT_FILL    :
                                        /*(pipe_lu_rsp_q3.lu_result == REJECT)*/  S_ERROR           ;
                end                    
               
            S_MB_WAIT_FILL                :
                if(fm2cache_rd_rsp.valid && (fm2cache_rd_rsp.tq_id == i)) begin
                    next_tq_state[i] = S_MB_FILL_READY;
                    en_tq_merge_buffer_data  [i] = 1'b1;
                    next_tq_merge_buffer_data[i] = fm2cache_rd_rsp.data; //FIXME need to merge the data with the FM rd data - not override the merge_data entry
                end
            S_MB_FILL_READY               :
                if (first_fill[i] && (!core2cache_req.valid)) begin // opportunistic pipe lookup - if no core request, then fill
                    next_tq_state[i] = S_IDLE;
                end //if
            S_ERROR                       :
                next_tq_state[i] = tq_state[i];

            default: begin
                next_tq_state[i] = tq_state[i];
            end

        endcase //casez
    end //for loop   
end //always_comb


always_comb begin
    for (int i=0; i<NUM_TQ_ENTRY; ++i) begin
        free_entries[i] = (tq_state[i] == S_IDLE);
        fill_entries[i] = (tq_state[i] == S_MB_FILL_READY);
    end
end
`FIND_FIRST(first_free, free_entries)
//FIXME - need to replace with round robin
`FIND_FIRST(first_fill, fill_entries)

logic free_exists;
logic fill_exists;
t_tq_id enc_first_free;
t_tq_id enc_first_fill;
`ENCODER(enc_first_free, free_exists, first_free)
`ENCODER(enc_first_fill, fill_exists, first_fill)

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
        pipe_lu_req_q1.address = core2cache_req.address;
        pipe_lu_req_q1.data    = core2cache_req.data;
        pipe_lu_req_q1.tq_id   = enc_first_free;
    end else if (fill_exists) begin
        pipe_lu_req_q1.valid         = 1'b1;
        pipe_lu_req_q1.lu_op         = FILL_LU;
        pipe_lu_req_q1.address       = {tq_cl_address      [enc_first_fill],{OFFSET_WIDTH{1'b0}}} ;//FIXME need to remember the correct address offset for the case that rd indication is set
        pipe_lu_req_q1.cl_data       = tq_merge_buffer_data[enc_first_fill];
        pipe_lu_req_q1.tq_id         = enc_first_fill;
        pipe_lu_req_q1.rd_indication = tq_rd_indication    [enc_first_fill];
        pipe_lu_req_q1.wr_indication = tq_wr_indication    [enc_first_fill];
    end //else if

end


endmodule
