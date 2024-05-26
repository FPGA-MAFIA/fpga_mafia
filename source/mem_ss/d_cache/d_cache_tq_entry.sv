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
`include "macros.vh"

module d_cache_tq_entry
import d_cache_param_pkg::*;  
(
    input  logic                clk,
    input  logic                rst,
    input  logic  [2:0]         entry_id,
    // Core requests
    input  var t_req           core2cache_req,
    input  logic                allocate_entry,
    // FM responses from cache miss
    input  var t_fm_rd_rsp      fm2cache_rd_rsp,
    // Pipe responses from LU
    input  var t_lu_rsp         pipe_lu_rsp_q3,
    // Current TQ entry signals
    input  logic                first_fill,
    input  logic                cancel_core_req,
    output t_tq_entry           tq_entry,
    output t_tq_entry           next_tq_entry, //used for verification & tracker
    output logic                rd_req_hit_mb,
    output logic                wr_req_hit_mb,
    output logic                free_entry,
    output logic                fill_entry
);

logic rsp_hit_with_wr_match_in_pipe_q3;
logic [MSB_WORD_OFFSET:LSB_WORD_OFFSET ] new_alloc_word_offset;
logic  en_tq_merge_buffer_e_modified; 
logic  en_tq_merge_buffer_data; 
logic  en_tq_cl_address; 
logic  en_tq_cl_word_offset; 
logic  en_tq_rd_indication; 
logic  en_tq_wr_indication; 
logic  en_tq_reg_id; 
//===========================
// TQ entry states and signals
//===========================
`MAFIA_RST_VAL_DFF(tq_entry.state                  , next_tq_entry.state                  , clk, rst, S_IDLE)
`MAFIA_EN_DFF     (tq_entry.merge_buffer_e_modified, next_tq_entry.merge_buffer_e_modified, clk, en_tq_merge_buffer_e_modified) 
`MAFIA_EN_DFF     (tq_entry.rd_indication          , next_tq_entry.rd_indication          , clk, en_tq_rd_indication          ) 
`MAFIA_EN_DFF     (tq_entry.wr_indication          , next_tq_entry.wr_indication          , clk, en_tq_wr_indication          ) 
`MAFIA_EN_DFF     (tq_entry.merge_buffer_data      , next_tq_entry.merge_buffer_data      , clk, en_tq_merge_buffer_data      ) 
`MAFIA_EN_DFF     (tq_entry.cl_address             , next_tq_entry.cl_address             , clk, en_tq_cl_address             ) 
`MAFIA_EN_DFF     (tq_entry.cl_word_offset         , next_tq_entry.cl_word_offset         , clk, en_tq_cl_word_offset         ) 
`MAFIA_EN_DFF     (tq_entry.reg_id                 , next_tq_entry.reg_id                 , clk, en_tq_reg_id                 )


//===========================
// The main TQ logic FSM
//===========================
always_comb begin
    rsp_hit_with_wr_match_in_pipe_q3 = '0;
    // used to set the correct word offset in the cache line
    new_alloc_word_offset     = core2cache_req.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET];
    // the for loop will got through all the TQ entries
        // default data values
        next_tq_entry.state                   = tq_entry.state;
        next_tq_entry.merge_buffer_e_modified = '0;    //default value
        next_tq_entry.merge_buffer_data       = '0;
        next_tq_entry.cl_address              = '0;
        next_tq_entry.rd_indication           = '0;
        next_tq_entry.wr_indication           = '0;
        next_tq_entry.reg_id                  = '0;
        next_tq_entry.cl_word_offset          = '0;
        // default enable values
        en_tq_rd_indication             = '0;
        en_tq_wr_indication             = '0;
        en_tq_cl_word_offset            = '0;
        en_tq_reg_id                    = '0;
        en_tq_cl_address                = '0;
        en_tq_merge_buffer_e_modified   = '0;
        en_tq_merge_buffer_data         = '0;
        //==================================
        // start the State Machine per TQ entry
        //==================================
        unique casez (tq_entry.state)
            S_IDLE                : begin
                //if core_req && tq_entry_winner : next_state == LU_CORE_WR/RD_REQ 
                if (allocate_entry) begin
                    next_tq_entry.state =  ((core2cache_req.opcode == RD_OP) || 
                                         (core2cache_req.opcode == WR_OP))    ? S_LU_CORE : S_ERROR   ;
                    en_tq_rd_indication              = 1'b1;
                    en_tq_wr_indication              = 1'b1;
                    en_tq_cl_word_offset             = 1'b1;
                    en_tq_reg_id                     = 1'b1;
                    en_tq_cl_address                 = 1'b1;
                    en_tq_merge_buffer_e_modified    = 1'b1;
                    en_tq_merge_buffer_data          = 1'b1;
                    next_tq_entry.rd_indication      = (core2cache_req.opcode == RD_OP);
                    next_tq_entry.wr_indication      = (core2cache_req.opcode == WR_OP);
                    next_tq_entry.reg_id             = core2cache_req.reg_id;
                    next_tq_entry.cl_address         = core2cache_req.address[MSB_TAG:LSB_SET];
                    next_tq_entry.cl_word_offset     = core2cache_req.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET];
                    if(core2cache_req.opcode == WR_OP) begin
                        //write the data to the correct word offset in the merge buffer
                        // Loop through each word offset and byte offset to write the data to the correct position in the merge buffer
                        for (int WORD_OFST = 0; WORD_OFST < 4; WORD_OFST++) begin
                            for (int BYTE_OFST = 0; BYTE_OFST < 4; BYTE_OFST++) begin
                                // Calculate the correct bit range in merge_buffer_data for the current word and byte offset
                                // Write data to merge_buffer_data if the word and byte offsets match and the byte enable is set - Otherwise, write '0'
                                next_tq_entry.merge_buffer_data[(WORD_OFST*32 + BYTE_OFST*8) +: 8] = (new_alloc_word_offset == WORD_OFST[1:0] && core2cache_req.byte_en[BYTE_OFST]) ? core2cache_req.data[(BYTE_OFST*8) +: 8] : '0;
                            end
                        end //for each merge buffer buffer_data byte 
                        
                        // Loop through each word offset and byte offset to set the corresponding bit in the merge_buffer_e_modified vector
                        for (int WORD_OFST = 0; WORD_OFST < 4; WORD_OFST++) begin
                            for (int BYTE_OFST = 0; BYTE_OFST < 4; BYTE_OFST++) begin
                                // Calculate the correct index in merge_buffer_e_modified for the current word and byte offset
                                // Set the bit in merge_buffer_e_modified if the word and byte offsets match
                                next_tq_entry.merge_buffer_e_modified[WORD_OFST*4 + BYTE_OFST] = (new_alloc_word_offset == WORD_OFST[1:0] && core2cache_req.byte_en[BYTE_OFST]);
                            end
                        end // for each merge buffer_e_modified bit
                    end
                end
            end    
            S_LU_CORE: begin
                //if Cache_hit  : nex_state == IDLE
                //if Cache_miss : next_state == MB_WAIT_FILL
                // Handle the case where there are 2 writes B2B to same cache line
                // The data is merged in MB, but was already sent to pipe separately, 
                // only when the last write is done we can go to idle - if other write match in pipe we need to wait for it in the S_LU_CORE state
                // Note: this is still within the if((pipe_lu_rsp_q3.tq_id == entry_id) && (pipe_lu_rsp_q3.valid)
                rsp_hit_with_wr_match_in_pipe_q3 = (pipe_lu_rsp_q3.lu_result == HIT) && pipe_lu_rsp_q3.wr_match_in_pipe;
                if ((pipe_lu_rsp_q3.tq_id == entry_id) && (pipe_lu_rsp_q3.valid)) begin  
                    next_tq_entry.state=    rsp_hit_with_wr_match_in_pipe_q3     ?   S_LU_CORE      :
                                           (pipe_lu_rsp_q3.lu_result == HIT)     ?   S_IDLE         :
                                           (pipe_lu_rsp_q3.lu_result == MISS)    ?   S_MB_WAIT_FILL :
                                           // There is a corner case where the fill lu_rsp has the TQ id of a new lookup
                                           // This FILL is from an older request, don't want it to affect the entry
                                           // so simply ignore it and stay in the S_LU_CORE state
                                           (pipe_lu_rsp_q3.lu_result == FILL)    ?   S_LU_CORE      : 
                                           /*(pipe_lu_rsp_q3.lu_result == REJECT)*/  S_ERROR        ;

                end                    
            end
            S_MB_WAIT_FILL                : begin
                // NOTE: We are allowing a single outstanding request per CL address!!!
                //       this means we can match on the address of the fill rsp to know if it is for this entry
                if(fm2cache_rd_rsp.valid && (fm2cache_rd_rsp.address[MSB_TAG:LSB_SET] == tq_entry.cl_address)) begin
                    next_tq_entry.state = S_MB_FILL_READY;
                    en_tq_merge_buffer_data   = 1'b1;
                    // If the tq_entry.merge_buffer_e_modified[x] is set, then the data in the merge buffer already has the correct data - we don't want to override it with the fill data
                    // Loop through each word offset and byte offset to merge data into the merge buffer
                    for (int WORD_OFST = 0; WORD_OFST < 4; WORD_OFST++) begin
                        for (int BYTE_OFST = 0; BYTE_OFST < 4; BYTE_OFST++) begin
                            // Calculate the correct bit range in merge_buffer_data for the current word and byte offset
                            // Merge data from tq_entry or fm2cache_rd_rsp based on the modified flag
                            next_tq_entry.merge_buffer_data[(WORD_OFST*32 + BYTE_OFST*8) +: 8] = tq_entry.merge_buffer_e_modified[WORD_OFST*4 + BYTE_OFST] ? tq_entry.merge_buffer_data[(WORD_OFST*32 + BYTE_OFST*8) +: 8] : fm2cache_rd_rsp.data[(WORD_OFST*32 + BYTE_OFST*8) +: 8];
                        end
                    end

                end
            end //S_MB_WAIT_FILL
            S_MB_FILL_READY               : begin
                // opportunistic pipe lookup - if no core request, then fill
                // The fill are a lower priority than the core requests
                // Note: if we are waiting on a rd_miss, we wont be getting any core requests, 
                // So the fill will win the arbitration and will send the fill to the LU pipe
                if (first_fill && (!core2cache_req.valid)) begin 
                    next_tq_entry.state = S_IDLE;
                end //if
            end//S_MB_FILL_READY
            S_ERROR                       : begin
                next_tq_entry.state = tq_entry.state;
            end
            default: begin
                next_tq_entry.state = tq_entry.state;
            end

        endcase //casez

        //==================================================================================================
        //  Merge buffer hit logic
        //==================================================================================================
        // The case of read after write - we set the read indication and update the offset for the read rsp:
        // an entry that is already set as read indication will merge to the same entry in the merge buffer
        if(rd_req_hit_mb) begin
            en_tq_rd_indication    = 1'b1;
            en_tq_cl_word_offset   = 1'b1;
            en_tq_reg_id           = 1'b1;
            next_tq_entry.rd_indication = 1'b1;
            next_tq_entry.cl_word_offset= core2cache_req.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET];
            next_tq_entry.reg_id        = core2cache_req.reg_id;
        end //if
        
        // The case of write after write - we set the write indication and update the merge buffer data:
        if(wr_req_hit_mb) begin
            en_tq_wr_indication           = 1'b1;
            en_tq_merge_buffer_data       = 1'b1;
            en_tq_merge_buffer_e_modified = 1'b1;
            next_tq_entry.wr_indication   = 1'b1;
            // Write the data to the correct word offset in the merge buffer
            for (int WORD_OFST = 0; WORD_OFST < 4; WORD_OFST++) begin
                for (int BYTE_OFST = 0; BYTE_OFST < 4; BYTE_OFST++) begin
                    // Calculate the correct bit range in merge_buffer_data for the current word and byte offset
                    // Write data from core2cache_req or keep the existing tq_entry data based on conditions
                    next_tq_entry.merge_buffer_data[(WORD_OFST*32 + BYTE_OFST*8) +: 8] = (new_alloc_word_offset == WORD_OFST[1:0] && core2cache_req.byte_en[BYTE_OFST]) ? core2cache_req.data[(BYTE_OFST*8) +: 8] : tq_entry.merge_buffer_data[(WORD_OFST*32 + BYTE_OFST*8) +: 8];
                end
            end

            // Set the corresponding bit in the e_modified vector
            for (int WORD_OFST = 0; WORD_OFST < 4; WORD_OFST++) begin
                for (int BYTE_OFST = 0; BYTE_OFST < 4; BYTE_OFST++) begin
                    // Calculate the correct index in merge_buffer_e_modified for the current word and byte offset
                    // Set the bit in merge_buffer_e_modified if the word and byte offsets match or keep the existing bit
                    next_tq_entry.merge_buffer_e_modified[WORD_OFST*4 + BYTE_OFST] = tq_entry.merge_buffer_e_modified[WORD_OFST*4 + BYTE_OFST] || (new_alloc_word_offset == WORD_OFST[1:0] && core2cache_req.byte_en[BYTE_OFST]);
                end
            end
            // This is to fix a corner case where we have a fill & a write in the same cycle!!
            // This will make sure that the fm2cache response will not be ignored
            if( (tq_entry.state == S_MB_WAIT_FILL) && fm2cache_rd_rsp.valid && (fm2cache_rd_rsp.address[MSB_TAG:LSB_SET] == tq_entry.cl_address) )begin
                // Loop through each word offset and byte offset to merge data from fm2cache_rd_rsp into the merge buffer
                for (int WORD_OFST = 0; WORD_OFST < 4; WORD_OFST++) begin
                    for (int BYTE_OFST = 0; BYTE_OFST < 4; BYTE_OFST++) begin
                        // Calculate the correct bit range in merge_buffer_data for the current word and byte offset
                        // Merge data from fm2cache_rd_rsp into next_tq_entry.merge_buffer_data if merge_buffer_e_modified is not set
                        next_tq_entry.merge_buffer_data[(WORD_OFST*32 + BYTE_OFST*8) +: 8] = next_tq_entry.merge_buffer_e_modified[WORD_OFST*4 + BYTE_OFST] ? next_tq_entry.merge_buffer_data[(WORD_OFST*32 + BYTE_OFST*8) +: 8] : fm2cache_rd_rsp.data[(WORD_OFST*32 + BYTE_OFST*8) +: 8];
                    end
                end

            end
        end //if
end //always_comb

always_comb begin
        rd_req_hit_mb = core2cache_req.valid             && 
                           (core2cache_req.opcode == RD_OP) &&
                           (core2cache_req.address[MSB_TAG:LSB_SET] == tq_entry.cl_address) &&
                           (!tq_entry.rd_indication)           && // if the entry is already set as read indication, then we don't merge to the same entry
                           (!(cancel_core_req))             && // the request will be reissued later. we don't want to merge it to the same entry
                           ((tq_entry.state == S_MB_WAIT_FILL) || (tq_entry.state == S_MB_FILL_READY) || (tq_entry.state == S_LU_CORE));
    
        wr_req_hit_mb = core2cache_req.valid             && 
                           (core2cache_req.opcode == WR_OP) &&
                           (core2cache_req.address[MSB_TAG:LSB_SET] == tq_entry.cl_address) &&
                           (!tq_entry.rd_indication)           && //if the entry is already set as read indication, then we don't merge to the same entry
                           (!(cancel_core_req))             && // the request will be reissued later. we don't want to merge it to the same entry
                           ((tq_entry.state == S_MB_WAIT_FILL) || (tq_entry.state == S_MB_FILL_READY) || (tq_entry.state == S_LU_CORE));
    
end


assign free_entry = (tq_entry.state == S_IDLE);
assign fill_entry = (tq_entry.state == S_MB_FILL_READY);

endmodule