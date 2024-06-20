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

module d_cache_tq 
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

t_req pre_shift_core2cache_req; 
t_tq_entry [NUM_TQ_ENTRY-1:0] tq_entry;
t_tq_entry [NUM_TQ_ENTRY-1:0] next_tq_entry;

logic stall;

logic sel_reissue;
logic en_reissue_req;

logic set_rd_miss_stall;
logic rst_rd_miss_stall;
logic stall_rd_miss_q;
logic tq_full;

logic rd_hit_pipe_rsp_q3;
logic fill_with_rd_indication_q3;

t_word pre_cache2core_rsp;
t_word pre_shifted_cache2core_rsp;

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
//===============================
// miss aligned address check
//===============================
// The address must be word aligned. Meaning we can write a word only when the address lsb is equal to 00.
// We also can write a half byte only when address lsb is equal to 01, 10
// We can write a byte to any address lsb.
`ifdef SIM_ONLY
logic en_assert;
assign en_assert = 1'b1; // default value is 1'b1 and set to enable assertion

logic correct_aligned_access;

assign correct_aligned_access = (pre_core2cache_req.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b00)                                          ||  // its possible to write any alignment to adreess that ends with lsb's of 00.
                                (pre_core2cache_req.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b01 && pre_core2cache_req.byte_en == 4'b0001) ||  // byte correct alignment
                                (pre_core2cache_req.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b01 && pre_core2cache_req.byte_en == 4'b0011) ||  // half word correct alignment
                                (pre_core2cache_req.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b10 && pre_core2cache_req.byte_en == 4'b0001) ||  // byte correct alignment
                                (pre_core2cache_req.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b10 && pre_core2cache_req.byte_en == 4'b0011) ||  // half word correct alignment
                                (pre_core2cache_req.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b11 && pre_core2cache_req.byte_en == 4'b0001);    // byte correct alignment


// Assertion for read operations
string read_error_msg = "miss aligned access while reading";
logic read_error_align;
assign read_error_align = pre_core2cache_req.valid && !correct_aligned_access && (core2cache_req.opcode == RD_OP);
`MAFIA_ASSERT("read_error", read_error_align, en_assert, read_error_msg)

// Assertion for write operations
string write_error_msg = "miss aligned access while writing";
logic write_error_align;
assign write_error_align = pre_core2cache_req.valid && !correct_aligned_access && (core2cache_req.opcode == WR_OP);
`MAFIA_ASSERT("write_error", write_error_align, en_assert, write_error_msg)

// Assertion for other operations
string other_error_msg = "miss aligned access while writing(possibly debug is needed)";
logic other_error_align;
assign other_error_align = pre_core2cache_req.valid && !correct_aligned_access && core2cache_req.opcode != RD_OP && core2cache_req.opcode != WR_OP;
`MAFIA_ASSERT("other_error", other_error_align, en_assert, other_error_msg)

`endif

// Data and Byte En shifter
//===============================
// When writing to cache, the byte enable and the data must be shifted to fit proper alignment.
// the internal logic is CL aligned, and the request are always word aligned with byte enable
// This means dont nativly support non word aligned requests - so we add this shift on the data and byte enable
always_comb begin
pre_shift_core2cache_req = pre_core2cache_req;  
    if(pre_core2cache_req.opcode == WR_OP) begin
        pre_shift_core2cache_req.data    = (pre_core2cache_req.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b01 ) ? { pre_core2cache_req.data[23:0],8'b0  } :
                                           (pre_core2cache_req.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b10 ) ? { pre_core2cache_req.data[15:0],16'b0 } :
                                           (pre_core2cache_req.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b11 ) ? { pre_core2cache_req.data[7:0] ,24'b0 } :
                                                                                           pre_core2cache_req.data;
        pre_shift_core2cache_req.byte_en = (pre_core2cache_req.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b01 ) ? { pre_core2cache_req.byte_en[2:0],1'b0 } :
                                           (pre_core2cache_req.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b10 ) ? { pre_core2cache_req.byte_en[1:0],2'b0 } :
                                           (pre_core2cache_req.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b11 ) ? { pre_core2cache_req.byte_en[0]  ,3'b0 } :
                                                                                           pre_core2cache_req.byte_en;
    end
end 

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
`MAFIA_EN_DFF(reissue_req, pre_shift_core2cache_req, clk, en_reissue_req)

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
                                       pre_shift_core2cache_req; // else, send the request from core


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
//Take the relevant word from cache line
//Make sure to shift the "word data" according to the byte enable in the response, and sign extend/zero extend
//This is undoing the shift that was done in the core2cache_req

assign pre_shifted_cache2core_rsp     = pipe_lu_rsp_q3.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET] == 2'b00 ?  pipe_lu_rsp_q3.cl_data[31:0]  : 
                                        pipe_lu_rsp_q3.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET] == 2'b01 ?  pipe_lu_rsp_q3.cl_data[63:32] : 
                                        pipe_lu_rsp_q3.address[MSB_WORD_OFFSET:LSB_WORD_OFFSET] == 2'b10 ?  pipe_lu_rsp_q3.cl_data[95:64] :
                                                                                                            pipe_lu_rsp_q3.cl_data[127:96];

assign pre_cache2core_rsp = pipe_lu_rsp_q3.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b01 ? {8'b0,  pre_shifted_cache2core_rsp[31:8]}  :
                            pipe_lu_rsp_q3.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b10 ? {16'b0, pre_shifted_cache2core_rsp[31:16]} :
                            pipe_lu_rsp_q3.address[MSB_BYTE_OFFSET:LSB_BYTE_OFFSET] == 2'b11 ? {24'b0, pre_shifted_cache2core_rsp[31:24]} :
                                                                                                       pre_shifted_cache2core_rsp         ;

assign cache2core_rsp.data[7:0]    = pipe_lu_rsp_q3.byte_en[0]  ? pre_cache2core_rsp[7:0]        : 8'h0;
assign cache2core_rsp.data[15:8]   = pipe_lu_rsp_q3.byte_en[1]  ? pre_cache2core_rsp[15:8]       :
                                     pipe_lu_rsp_q3.sign_extend ? {8{cache2core_rsp.data[7]}}    : 8'h0;
assign cache2core_rsp.data[23:16]  = pipe_lu_rsp_q3.byte_en[2]  ? pre_cache2core_rsp[23:16]      :
                                     pipe_lu_rsp_q3.sign_extend ? {8{cache2core_rsp.data[15]}}   : 8'h0; 
assign cache2core_rsp.data[31:24]  = pipe_lu_rsp_q3.byte_en[3]  ? pre_cache2core_rsp[31:24]      :
                                     pipe_lu_rsp_q3.sign_extend ? {8{cache2core_rsp.data[23]}}   : 8'h0;                                                                        

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
genvar TQ_ENTRY;
generate for(TQ_ENTRY=0; TQ_ENTRY<NUM_TQ_ENTRY; TQ_ENTRY++) begin : tq_e
d_cache_tq_entry d_cache_tq_entry_i (
.clk              (clk           ),          //    input  logic                     clk,
.rst              (rst           ),          //    input  logic                     rst,
.entry_id         (3'(TQ_ENTRY)  ),          //    input  logic                     entry_id,
// Core requests
.core2cache_req   (core2cache_req),          //    input  t_req                     core2cache_req,
.allocate_entry   (allocate_entry[TQ_ENTRY]),//    input  logic           allocate_entry,
// FM responses from cache miss
.fm2cache_rd_rsp  (fm2cache_rd_rsp),         //    input  var t_fm_rd_rsp           fm2cache_rd_rsp,
// Pipe responses from LU
.pipe_lu_rsp_q3   (pipe_lu_rsp_q3  ),        //    input  var t_lu_rsp              pipe_lu_rsp_q3,
// Current TQ entry signals
.first_fill       (first_fill   [TQ_ENTRY]), //  input  logic
.cancel_core_req  (cancel_core_req),         //  output logic
.tq_entry         (tq_entry     [TQ_ENTRY]), //  output t_tq_entry
.next_tq_entry    (next_tq_entry[TQ_ENTRY]), //  output t_tq_entry // Note: used only for verification - not RTL
.rd_req_hit_mb    (rd_req_hit_mb[TQ_ENTRY]), //  output logic
.wr_req_hit_mb    (wr_req_hit_mb[TQ_ENTRY]), //  output logic
.free_entry       (free_entries [TQ_ENTRY]), //  output logic
.fill_entry       (fill_entries [TQ_ENTRY])  //  output logic
);
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

always_comb begin
    for(int i =0; i<NUM_TQ_ENTRY; ++i) begin
        rd_req_hit_mb[i] = core2cache_req.valid             && 
                           (core2cache_req.opcode == RD_OP) &&
                           (core2cache_req.address[MSB_TAG:LSB_SET] == tq_entry[i].cl_address) &&
                           (!tq_entry[i].rd_indication)     && // if the entry is already set as read indication, then we don't merge to the same entry
                           (!(cancel_core_req))             && // the request will be reissued later. we don't want to merge it to the same entry
                           ((tq_entry[i].state == S_MB_WAIT_FILL) || (tq_entry[i].state == S_MB_FILL_READY) || (tq_entry[i].state == S_LU_CORE));
    
        wr_req_hit_mb[i] = core2cache_req.valid             && 
                           (core2cache_req.opcode == WR_OP) &&
                           (core2cache_req.address[MSB_TAG:LSB_SET] == tq_entry[i].cl_address) &&
                           (!tq_entry[i].rd_indication)     && //if the entry is already set as read indication, then we don't merge to the same entry
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


`MAFIA_FIND_FIRST(first_free, free_entries)
//suppress the first free entry if there is a read hit in the merge buffer

//FIXME - need to replace with round robin or Age Matrix
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
            pipe_lu_req_q1.byte_en       = (core2cache_req.byte_en); 
            pipe_lu_req_q1.sign_extend   = (core2cache_req.sign_extend);
        end // pipe_early_lu_rsp_q2.rd_miss
    // There is no valid "core2cache_req.valid" we will check if there is a fill request
    // if so, we can send a fill to the PIPE
    end else if (fill_exists) begin
        pipe_lu_req_q1.valid         = 1'b1;
        pipe_lu_req_q1.lu_op         = FILL_LU;
        pipe_lu_req_q1.tq_id         = enc_first_fill;
        pipe_lu_req_q1.address       = {tq_entry[enc_first_fill].cl_address,
                                        tq_entry[enc_first_fill].cl_word_offset,
                                        tq_entry[enc_first_fill].cl_byte_offset};
        pipe_lu_req_q1.cl_data       =  tq_entry[enc_first_fill].merge_buffer_data;
        pipe_lu_req_q1.rd_indication =  tq_entry[enc_first_fill].rd_indication;
        pipe_lu_req_q1.wr_indication =  tq_entry[enc_first_fill].wr_indication;
        pipe_lu_req_q1.reg_id        =  tq_entry[enc_first_fill].reg_id;
        pipe_lu_req_q1.byte_en       =  tq_entry[enc_first_fill].byte_en;
        pipe_lu_req_q1.sign_extend   =  tq_entry[enc_first_fill].sign_extend;
    end //else if

    //incase of a read miss, we need to cancel the request and re-issue it later from the re-issue buffer



end

// FIXME - Add assertion that We are allowing a single outstanding request per CL address!!!
// FIXME - Add assertion that a there is no pre_shift_core2cache_req.valid when stall is asserted
// FIXME - Add assertion that no 2 tq entries have the same tq_cl_address && are in S_MB_WAIT_FILL
// FIXME - Add assertion that every pipe response HIT/MISS have a matching valid TQ entry
//logic rsp_hit_or_miss_entry_q3;
//always_comb begin
//    rsp_hit_or_miss_entry_q3 = ((pipe_lu_rsp_q3.lu_result == HIT) || (pipe_lu_rsp_q3.lu_result == MISS)) && 
//                               (tq_entry[pipe_lu_rsp_q3.tq_id].state == S_LU_CORE);
//end
//`MAFIA_ASSERT("no_matching_tq_for_hit_or_miss", 
//             (!rsp_hit_or_miss_entry_q3),                                 // Condition
//             pipe_lu_rsp_q3.valid && (pipe_lu_rsp_q3.lu_result != FILL),  // En
//             "no_matching_tq_for_hit_or_miss")     


endmodule
