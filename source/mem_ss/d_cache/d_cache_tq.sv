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

module  d_cache_tq 
    import d_cache_param_pkg::*;  
(
    input   logic           clk,        
    input   logic           rst,        
    //core Interface
    input   var t_req       pre_core2cache_req,
    output  logic           ready,
    output  t_rd_rsp        cache2core_rsp,
    //FM Interface
    input   var t_fm_rd_rsp fm2cache_rd_rsp,
    //Pipe Interface
    output  t_lu_req           pipe_lu_req_q1,
    input   var t_early_lu_rsp pipe_early_lu_rsp_q2,
    input   var t_lu_rsp       pipe_lu_rsp_q3
);
t_req                         core2cache_req;
t_req                         reissue_req;

logic [NUM_TQ_ENTRY-1:0] rd_req_hit_mb;
logic [NUM_TQ_ENTRY-1:0] wr_req_hit_mb;
logic any_rd_hit_mb;
logic any_wr_hit_mb;

logic [NUM_TQ_ENTRY-1:0] free_entries;
logic [NUM_TQ_ENTRY-1:0] allocate_entry;
logic [NUM_TQ_ENTRY-1:0] first_free;
logic [NUM_TQ_ENTRY-1:0] fill_entries;
logic [NUM_TQ_ENTRY-1:0] first_fill;

logic    [NUM_TQ_ENTRY-1:0] en_tq_merge_buffer_e_modified; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_merge_buffer_data; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_cl_address; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_cl_word_offset; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_rd_indication; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_wr_indication; 
logic    [NUM_TQ_ENTRY-1:0] en_tq_reg_id; 
t_tq_entry [NUM_TQ_ENTRY-1:0] tq_entry;
t_cl         [NUM_TQ_ENTRY-1:0]                      tq_merge_buffer_data; 
t_cl_address [NUM_TQ_ENTRY-1:0]                      tq_cl_address;
t_word_offset[NUM_TQ_ENTRY-1:0]                      tq_cl_word_offset; 
logic        [NUM_TQ_ENTRY-1:0]                      tq_rd_indication; 
logic        [NUM_TQ_ENTRY-1:0]                      tq_wr_indication; 
t_reg_id     [NUM_TQ_ENTRY-1:0]                      tq_reg_id; 
t_tq_state   [NUM_TQ_ENTRY-1:0]                      next_tq_state;
logic        [NUM_TQ_ENTRY-1:0][NUM_WORDS_IN_CL-1:0] next_tq_merge_buffer_e_modified; 
t_cl         [NUM_TQ_ENTRY-1:0]                      next_tq_merge_buffer_data; 
t_cl_address [NUM_TQ_ENTRY-1:0]                      next_tq_cl_address; 
t_word_offset[NUM_TQ_ENTRY-1:0]                      next_tq_cl_word_offset; 
logic        [NUM_TQ_ENTRY-1:0]                      next_tq_rd_indication; 
logic        [NUM_TQ_ENTRY-1:0]                      next_tq_wr_indication; 
t_reg_id     [NUM_TQ_ENTRY-1:0]                      next_tq_reg_id; 

logic stall;

logic sel_reissue;
logic en_reissue_req;

logic set_rd_miss_stall;
logic rst_rd_miss_stall;
logic stall_rd_miss_q;
logic tq_full;

logic rd_hit_pipe_rsp_q3;
logic fill_with_rd_indication_q3;

t_tq_id      rd_miss_tq_id;
t_cl_address rd_miss_cl_address;

logic free_exists;
logic wr_hit_exists;
logic rd_hit_exists;
logic fill_exists;
t_tq_id enc_first_free;
t_tq_id enc_first_fill;
t_tq_id enc_wr_req_hit_mb;
t_tq_id enc_rd_req_hit_mb;

logic set_rd_miss_was_filled;
logic rd_miss_was_filled;
logic [MSB_WORD_OFFSET:LSB_WORD_OFFSET ] new_alloc_word_offset;

logic cancel_core_req;
//================================
// REISSUE BUFFER
//================================
// Incase there was a READ miss in Q2, we will cancel the Q1 request and reissue it when the miss is served
// Need to remember who is the Q1 request that was cancelled so we can re-issue it
// Need to remember the Q2 request that caused the cancellation so we can know when the miss was served
// Once the miss is served, we will re-issue the Q1 request
//================================
// Remember the last request that was cancelled due to a miss - will be reissued when the miss is served
// FIXME need to allow read hit from the TQ, and when that happens, there is no need to cancel the Q1 request
assign en_reissue_req   = pipe_early_lu_rsp_q2.rd_miss;
assign cancel_core_req  = pipe_early_lu_rsp_q2.rd_miss; // rename for clarity
`MAFIA_EN_DFF(reissue_req, pre_core2cache_req, clk, en_reissue_req)

// Remember what request read missed - used to determine if the read miss was served by the fill
`MAFIA_EN_DFF(rd_miss_tq_id,      pipe_early_lu_rsp_q2.lu_tq_id,   clk, en_reissue_req)
`MAFIA_EN_DFF(rd_miss_cl_address, pipe_early_lu_rsp_q2.cl_address, clk, en_reissue_req)

// Detect if the read miss was served by the fill
assign set_rd_miss_was_filled = stall_rd_miss_q                                         && // we are currently waiting for the miss to be served 
                                pipe_early_lu_rsp_q2.alloc_rd_fill                      && // The response was a fill for a read miss
                                (pipe_early_lu_rsp_q2.lu_tq_id   == rd_miss_tq_id)      && // The read miss that was served matches the tq read miss that we are waiting for
                                (pipe_early_lu_rsp_q2.cl_address == rd_miss_cl_address) ;  // The read miss that was served matches the address read miss that we are waiting for - TODO - review if needed

// using a EN_RST FF as a set/reset FF by connecting the set condition to the enable and the reset condition to the reset
// set reset FLIP-FLOP indication:
`MAFIA_EN_RST_DFF(  rd_miss_was_filled,    // The indication
                    1'b1,                  // when "enable" we set with 1'b1
                    clk,                   // clock
                    set_rd_miss_was_filled,// set indication 
                    (rst || sel_reissue) ) // reset indication
// We actually re-issue the request only when the miss was served and there are no other fills in the queue
// TODO - in this implementation we are prioritizing the fills over the re-issue which is not necessary the best performance
//        Maybe we should prioritize the re-issue over the fills that are not set for rd miss
assign sel_reissue = rd_miss_was_filled  && (!fill_exists);
// This is the mux that selects the request to be sent to the cache - either the re-issue or the request from the core
assign core2cache_req = sel_reissue  ? reissue_req       : // Send the re-issue request
                                       pre_core2cache_req; // else, send the request from core


//================================
//================================
// There are 2 flows that return the a read request to the core:
// 1. Read request (RD_LU) hit in cache
// 2. Read request that miss the cache, but was served by a fill
//    two options for this flow:
//    - The Read request is what initiated the fill
//    - The Read request hit in the merge buffer an older write miss that was waiting for a fill
//      Then the TQ entry was set as a "rd_indication" so once that fill is served, the read request will be returned to the core
//================================
// 1. Read request (RD_LU) hit in cache
assign rd_hit_pipe_rsp_q3 = pipe_lu_rsp_q3.valid              && 
                           (pipe_lu_rsp_q3.lu_op == RD_LU)    &&
                           (pipe_lu_rsp_q3.lu_result == HIT);

// 2. Read request that miss the cache, but was served by a fill
assign fill_with_rd_indication_q3 = pipe_lu_rsp_q3.valid              && 
                                    (pipe_lu_rsp_q3.lu_op == FILL_LU) &&
                                     pipe_lu_rsp_q3.rd_indication;

//================================
// setting the CACHE2CORE response
//================================
assign cache2core_rsp.valid =   rd_hit_pipe_rsp_q3 || fill_with_rd_indication_q3;
//take the relevant word from cache line
//FIXME - need to support byte enable -> make sure to shift the "word data" according to the byte enable in the response, and sign extend/zero extend
assign cache2core_rsp.data    = pipe_lu_rsp_q3.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET] == 2'b00 ?  pipe_lu_rsp_q3.cl_data[31:0]  : 
                                pipe_lu_rsp_q3.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET] == 2'b01 ?  pipe_lu_rsp_q3.cl_data[63:32] : 
                                pipe_lu_rsp_q3.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET] == 2'b10 ?  pipe_lu_rsp_q3.cl_data[95:64] :
                                                                                                    pipe_lu_rsp_q3.cl_data[127:96];
assign cache2core_rsp.address = pipe_lu_rsp_q3.address;
assign cache2core_rsp.reg_id  = pipe_lu_rsp_q3.reg_id;


//================================
// The TQ & MB logic
// (transaction queue & merge buffer)
//================================
// The TQ is used to track the transactions life cycle
// Incase of a hit, the TQ entry has a short life cycle
// Incase of a miss, the TQ entry has a longer life cycle that needs to wait for the fill
// Also need the handle the MB data corrects
// NOTE:  - A TQ can serve multiple writes that are to the same CL
//        - A TQ can serve a single read to each CL
//        - Read after Write to the same CL will merge into the same TQ entry.
//        - Read after Read to the same CL will not merge into the same TQ entry.
//        - When the tq_rd_indication is set for a TQ entry, there will be no more merges to that TQ entry

//===========================
// TQ entry states and signals
//===========================
genvar TQ_GEN;
generate for(TQ_GEN=0; TQ_GEN<NUM_TQ_ENTRY; TQ_GEN=TQ_GEN+1) begin : tq_generate_ff_block
    `MAFIA_RST_VAL_DFF(tq_entry[TQ_GEN].state                  , next_tq_state                  [TQ_GEN], clk, rst, S_IDLE)
    `MAFIA_EN_DFF     (tq_entry[TQ_GEN].merge_buffer_e_modified, next_tq_merge_buffer_e_modified[TQ_GEN], clk, en_tq_merge_buffer_e_modified[TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_rd_indication          [TQ_GEN], next_tq_rd_indication          [TQ_GEN], clk, en_tq_rd_indication          [TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_wr_indication          [TQ_GEN], next_tq_wr_indication          [TQ_GEN], clk, en_tq_wr_indication          [TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_merge_buffer_data      [TQ_GEN], next_tq_merge_buffer_data      [TQ_GEN], clk, en_tq_merge_buffer_data      [TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_cl_address             [TQ_GEN], next_tq_cl_address             [TQ_GEN], clk, en_tq_cl_address             [TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_cl_word_offset         [TQ_GEN], next_tq_cl_word_offset         [TQ_GEN], clk, en_tq_cl_word_offset         [TQ_GEN]) 
    `MAFIA_EN_DFF     (tq_reg_id                 [TQ_GEN], next_tq_reg_id                 [TQ_GEN], clk, en_tq_reg_id                 [TQ_GEN])
end endgenerate

//===========================
// conditions to allocate a new TQ entry
//===========================
always_comb begin
    for (int i=0; i<NUM_TQ_ENTRY; ++i) begin
        allocate_entry[i] = first_free[i]        &&  // first free entry to allocate exists
                            core2cache_req.valid &&  // core request is valid
                            (!any_rd_hit_mb)     &&  // no read hit in merge buffer
                            (!any_wr_hit_mb)     &&  // no write hit in merge buffer
                            (!cancel_core_req)    ;  // no read miss in pipe -> must cancel request, wil be re-issue from the reissue buffer   
    end
end //always_comb

//===========================
// The main TQ logic FSM
//===========================
always_comb begin
    // used to set the correct word offset in the cache line
    new_alloc_word_offset     = core2cache_req.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET];
    // the for loop will got through all the TQ entries
    // TODO - review if we want to have a new RTL module called "tq_entry" instead of using this for loop
    for (int i=0; i<NUM_TQ_ENTRY; ++i) begin
        // default data values
        next_tq_state                  [i] = tq_entry[i].state;
        next_tq_merge_buffer_e_modified[i] = '0;    //default value
        next_tq_merge_buffer_data      [i] = '0;
        next_tq_cl_address             [i] = '0;
        next_tq_rd_indication          [i] = '0;
        next_tq_wr_indication          [i] = '0;
        next_tq_reg_id                 [i] = '0;
        next_tq_cl_word_offset         [i] = '0;
        // default enable values
        en_tq_rd_indication            [i] = '0;
        en_tq_wr_indication            [i] = '0;
        en_tq_cl_word_offset           [i] = '0;
        en_tq_reg_id                   [i] = '0;
        en_tq_cl_address               [i] = '0;
        en_tq_merge_buffer_e_modified  [i] = '0;
        en_tq_merge_buffer_data        [i] = '0;
        //==================================
        // start the State Machine per TQ entry
        //==================================
        unique casez (tq_entry[i].state)
            S_IDLE                : begin
                //if core_req && tq_entry_winner : next_state == LU_CORE_WR/RD_REQ 
                if (allocate_entry[i]) begin
                    next_tq_state[i] =  ((core2cache_req.opcode == RD_OP) || 
                                         (core2cache_req.opcode == WR_OP))    ? S_LU_CORE : S_ERROR   ;
                    en_tq_rd_indication             [i] = 1'b1;
                    en_tq_wr_indication             [i] = 1'b1;
                    en_tq_cl_word_offset            [i] = 1'b1;
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
                        // FIXME - need to take into account the byte enable logic
                        next_tq_merge_buffer_data[i][31:0]   = (new_alloc_word_offset == 2'd0) ? core2cache_req.data : '0;
                        next_tq_merge_buffer_data[i][63:32]  = (new_alloc_word_offset == 2'd1) ? core2cache_req.data : '0;
                        next_tq_merge_buffer_data[i][95:64]  = (new_alloc_word_offset == 2'd2) ? core2cache_req.data : '0;
                        next_tq_merge_buffer_data[i][127:96] = (new_alloc_word_offset == 2'd3) ? core2cache_req.data : '0;
                        //set the corresponding bit in the e_modified vector
                        next_tq_merge_buffer_e_modified[i][new_alloc_word_offset] = 1'b1;
                    end
                end
            end    
            S_LU_CORE: begin
                //if Cache_hit  : nex_state == IDLE
                //if Cache_miss : next_state == MB_WAIT_FILL
                if ((pipe_lu_rsp_q3.tq_id == i) && (pipe_lu_rsp_q3.valid)) begin  
                    next_tq_state[i]=   (pipe_lu_rsp_q3.lu_result == HIT)     ?   S_IDLE            :
                                        (pipe_lu_rsp_q3.lu_result == MISS)    ?   S_MB_WAIT_FILL    :
                                        // There is a corner case where the fill lu_rsp has the TQ id of a new lookup
                                        // This FILL is from an older request, don't want it to affect the entry
                                        // so simply ignore it and stay in the S_LU_CORE state
                                        (pipe_lu_rsp_q3.lu_result == FILL)    ?   S_LU_CORE         : 
                                        /*(pipe_lu_rsp_q3.lu_result == REJECT)*/  S_ERROR           ;

                // Handle the case where there are 2 writes B2B to same cache line
                // The data is merged in MB, but was already sent to pipe separately, 
                // only when the last write is done we can go to idle - if other write match in pipe we need to wait for it in the S_LU_CORE state
                // Note: this is still within the if((pipe_lu_rsp_q3.tq_id == i) && (pipe_lu_rsp_q3.valid)
                    if( pipe_lu_rsp_q3.wr_match_in_pipe && (pipe_lu_rsp_q3.lu_result == HIT)) begin
                         next_tq_state[i] = S_LU_CORE ;
                    end
                end //((pipe_lu_rsp_q3.tq_id == i) && (pipe_lu_rsp_q3.valid))                    
            end
            S_MB_WAIT_FILL                : begin
                // NOTE: We are allowing a single outstanding request per CL address!!!
                //       this means we can match on the address of the fill rsp to know if it is for this entry
                if(fm2cache_rd_rsp.valid && (fm2cache_rd_rsp.address[MSB_TAG:LSB_SET] == tq_cl_address[i])) begin
                    next_tq_state[i] = S_MB_FILL_READY;
                    en_tq_merge_buffer_data  [i] = 1'b1;
                    // If the tq_entry.merge_buffer_e_modified[i][x] is set, then the data in the merge buffer already has the correct data - we don't want to override it with the fill data
                    // FIXME - This logic needs to take into account the Byte Enable logic that we have not coded yet
                    next_tq_merge_buffer_data[i][31:0]   = tq_entry[i].merge_buffer_e_modified[0] ? tq_merge_buffer_data[i][31:0]   : fm2cache_rd_rsp.data[31:0];
                    next_tq_merge_buffer_data[i][63:32]  = tq_entry[i].merge_buffer_e_modified[1] ? tq_merge_buffer_data[i][63:32]  : fm2cache_rd_rsp.data[63:32];
                    next_tq_merge_buffer_data[i][95:64]  = tq_entry[i].merge_buffer_e_modified[2] ? tq_merge_buffer_data[i][95:64]  : fm2cache_rd_rsp.data[95:64];
                    next_tq_merge_buffer_data[i][127:96] = tq_entry[i].merge_buffer_e_modified[3] ? tq_merge_buffer_data[i][127:96] : fm2cache_rd_rsp.data[127:96];
                end
            end //S_MB_WAIT_FILL
            S_MB_FILL_READY               : begin
                // opportunistic pipe lookup - if no core request, then fill
                // The fill are a lower priority than the core requests
                // Note: if we are waiting on a rd_miss, we wont be getting any core requests, 
                // So the fill will win the arbitration and will send the fill to the LU pipe
                if (first_fill[i] && (!core2cache_req.valid)) begin 
                    next_tq_state[i] = S_IDLE;
                end //if
            end//S_MB_FILL_READY
            S_ERROR                       : begin
                next_tq_state[i] = tq_entry[i].state;
            end
            default: begin
                next_tq_state[i] = tq_entry[i].state;
            end

        endcase //casez

        //==================================================================================================
        //  Merge buffer hit logic
        //==================================================================================================
                // The case of read after write - we set the read indication and update the offset for the read rsp:
                // an entry that is already set as read indication will merge to the same entry in the merge buffer
                if(rd_req_hit_mb[i]) begin
                    en_tq_rd_indication   [i] = 1'b1;
                    en_tq_cl_word_offset  [i] = 1'b1;
                    en_tq_reg_id          [i] = 1'b1;
                    next_tq_rd_indication [i] = 1'b1;
                    next_tq_cl_word_offset[i] = core2cache_req.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET];
                    next_tq_reg_id        [i] = core2cache_req.reg_id;
                end //if
                
                // The case of write after write - we set the write indication and update the merge buffer data:
                if(wr_req_hit_mb[i]) begin
                    en_tq_wr_indication          [i] = 1'b1;
                    en_tq_merge_buffer_data      [i] = 1'b1;
                    en_tq_merge_buffer_e_modified[i] = 1'b1;
                    next_tq_wr_indication        [i] = 1'b1;
                    //write the data to the correct word offset in the merge buffer
                    next_tq_merge_buffer_data[i][31:0]   = (new_alloc_word_offset == 2'd0) ? core2cache_req.data :  tq_merge_buffer_data[i][31:0]  ;
                    next_tq_merge_buffer_data[i][63:32]  = (new_alloc_word_offset == 2'd1) ? core2cache_req.data :  tq_merge_buffer_data[i][63:32] ;
                    next_tq_merge_buffer_data[i][95:64]  = (new_alloc_word_offset == 2'd2) ? core2cache_req.data :  tq_merge_buffer_data[i][95:64] ;
                    next_tq_merge_buffer_data[i][127:96] = (new_alloc_word_offset == 2'd3) ? core2cache_req.data :  tq_merge_buffer_data[i][127:96];
                    //set the corresponding bit in the e_modified vector
                    next_tq_merge_buffer_e_modified[i]                        = tq_entry[i].merge_buffer_e_modified;
                    next_tq_merge_buffer_e_modified[i][new_alloc_word_offset] = 1'b1;


                    // This is to fix a corner case where we have a fill & a write in the same cycle!!
                    // This will make sure that the fm2cache response will not be ignored
                    if( (tq_entry[i].state == S_MB_WAIT_FILL) && fm2cache_rd_rsp.valid && (fm2cache_rd_rsp.address[MSB_TAG:LSB_SET] == tq_cl_address[i]) )begin
                        next_tq_merge_buffer_data[i][31:0]   = next_tq_merge_buffer_e_modified[i][0] ? next_tq_merge_buffer_data[i][31:0]   : fm2cache_rd_rsp.data[31:0];
                        next_tq_merge_buffer_data[i][63:32]  = next_tq_merge_buffer_e_modified[i][1] ? next_tq_merge_buffer_data[i][63:32]  : fm2cache_rd_rsp.data[63:32];
                        next_tq_merge_buffer_data[i][95:64]  = next_tq_merge_buffer_e_modified[i][2] ? next_tq_merge_buffer_data[i][95:64]  : fm2cache_rd_rsp.data[95:64];
                        next_tq_merge_buffer_data[i][127:96] = next_tq_merge_buffer_e_modified[i][3] ? next_tq_merge_buffer_data[i][127:96] : fm2cache_rd_rsp.data[127:96];
                    end
                end //if

    end //for loop   
end //always_comb

always_comb begin
    for(int i =0; i<NUM_TQ_ENTRY; ++i) begin
        rd_req_hit_mb[i] = core2cache_req.valid             && 
                           (core2cache_req.opcode == RD_OP) &&
                           (core2cache_req.address[MSB_TAG:LSB_SET] == tq_cl_address[i]) &&
                           (!tq_rd_indication[i])           && // if the entry is already set as read indication, then we don't merge to the same entry
                           (!(cancel_core_req))             && // the request will be reissued later. we don't want to merge it to the same entry
                           ((tq_entry[i].state == S_MB_WAIT_FILL) || (tq_entry[i].state == S_MB_FILL_READY) || (tq_entry[i].state == S_LU_CORE));
    
        wr_req_hit_mb[i] = core2cache_req.valid             && 
                           (core2cache_req.opcode == WR_OP) &&
                           (core2cache_req.address[MSB_TAG:LSB_SET] == tq_cl_address[i]) &&
                           (!tq_rd_indication[i])           && //if the entry is already set as read indication, then we don't merge to the same entry
                           (!(cancel_core_req))             && // the request will be reissued later. we don't want to merge it to the same entry
                           ((tq_entry[i].state == S_MB_WAIT_FILL) || (tq_entry[i].state == S_MB_FILL_READY) || (tq_entry[i].state == S_LU_CORE));
    
    end
end

assign tq_full = &(~free_entries[NUM_TQ_ENTRY-1:0] | allocate_entry[NUM_TQ_ENTRY-1:0]);

//sticky stall indication - used for read miss stall logic
assign set_rd_miss_stall = pipe_early_lu_rsp_q2.rd_miss;
assign rst_rd_miss_stall = sel_reissue;
// This is an implementation of a set_rst flop using a en_rst flop
`MAFIA_EN_RST_DFF(stall_rd_miss_q,            // output
                  1'b1 ,  
                  clk, 
                  set_rd_miss_stall,           // set condition
                  (rst_rd_miss_stall || rst) ) // reset condition

//Stall if there is a read miss in pipe q2 or tq full.
assign stall = tq_full || stall_rd_miss_q || set_rd_miss_stall;
assign ready = ~stall;


assign any_rd_hit_mb = |rd_req_hit_mb;
assign any_wr_hit_mb = |wr_req_hit_mb;

always_comb begin
    for (int i=0; i<NUM_TQ_ENTRY; ++i) begin
        free_entries[i] = (tq_entry[i].state == S_IDLE);
        fill_entries[i] = (tq_entry[i].state == S_MB_FILL_READY);
    end
end
`MAFIA_FIND_FIRST(first_free, free_entries)
//suppress the first free entry if there is a read hit in the merge buffer

//FIXME - need to replace with round robin
`MAFIA_FIND_FIRST(first_fill, fill_entries)

`MAFIA_ENCODER(enc_first_free, free_exists, first_free)
`MAFIA_ENCODER(enc_first_fill, fill_exists, first_fill)
`MAFIA_ENCODER(enc_wr_req_hit_mb, wr_hit_exists, wr_req_hit_mb)
`MAFIA_ENCODER(enc_rd_req_hit_mb, rd_hit_exists, rd_req_hit_mb)

//=================
// Pipe lookup mux - core request vs fill request
//=================
// The Pipe lookup can come from 2 sources:
// 1. Core request (or re-issue)
// 2. Fill request (from the TQ)
// The Core request has higher priority than the fill request.
always_comb begin
    pipe_lu_req_q1 = '0;
    if(core2cache_req.valid) begin
        if(!cancel_core_req) begin // incase of rd miss in q2, then we need to cancel the core request and reissue it later
            pipe_lu_req_q1.valid   = core2cache_req.valid;
            pipe_lu_req_q1.reg_id  = core2cache_req.reg_id;
            pipe_lu_req_q1.lu_op   = (core2cache_req.opcode == WR_OP) ? WR_LU :
                                     (core2cache_req.opcode == RD_OP) ? RD_LU :
                                                                        NO_LU ;
            pipe_lu_req_q1.address       = core2cache_req.address;
            pipe_lu_req_q1.data          = core2cache_req.data;
            pipe_lu_req_q1.tq_id         = any_wr_hit_mb ? enc_wr_req_hit_mb :
                                           any_rd_hit_mb ? enc_rd_req_hit_mb :
                                                           enc_first_free    ;
            pipe_lu_req_q1.mb_hit_cancel = any_rd_hit_mb || any_wr_hit_mb;
            pipe_lu_req_q1.rd_indication = (core2cache_req.opcode == RD_OP);
            pipe_lu_req_q1.wr_indication = (core2cache_req.opcode == WR_OP);
        end // pipe_early_lu_rsp_q2.rd_miss
    // There is no valid "core2cache_req.valid" we will check if there is a fill request
    // if so, we can send a fill to the PIPE
    end else if (fill_exists) begin
        pipe_lu_req_q1.valid         = 1'b1;
        pipe_lu_req_q1.lu_op         = FILL_LU;
        pipe_lu_req_q1.address       = {tq_cl_address      [enc_first_fill],tq_cl_word_offset[enc_first_fill],2'b00} ;//FIXME need to remember the correct address offset for the case that rd indication is set
        pipe_lu_req_q1.cl_data       = tq_merge_buffer_data[enc_first_fill];
        pipe_lu_req_q1.tq_id         = enc_first_fill;
        pipe_lu_req_q1.rd_indication = tq_rd_indication    [enc_first_fill];
        pipe_lu_req_q1.wr_indication = tq_wr_indication    [enc_first_fill];
        pipe_lu_req_q1.reg_id        = tq_reg_id           [enc_first_fill];
    end //else if

    //incase of a read miss, we need to cancel the request and re-issue it later from the re-issue buffer



end

// FIXME - add assertion that We are allowing a single outstanding request per CL address!!!
// FIXME - add assertion that a there is no pre_core2cache_req.valid when stall is asserted
// FIXME - add assertion that no 2 tq entries have the same tq_cl_address && are in S_MB_WAIT_FILL

endmodule
