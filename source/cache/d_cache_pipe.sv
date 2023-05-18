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

module d_cache_pipe
    import d_cache_param_pkg::*;  
(
    input   logic               clk,
    input   logic               rst,
    //tq interface 
    input   var t_lu_req        pipe_lu_req_q1,
    output  var t_early_lu_rsp  pipe_early_lu_rsp_q2,
    output  t_lu_rsp            pipe_lu_rsp_q3,
    // FM interface Requests 
    output  t_fm_req            cache2fm_req_q3,
    //tag_array interface 
    output  t_set_rd_req        rd_set_req_q1,
    input   var t_set_rd_rsp    pre_rd_data_set_rsp_q2,
    output  t_set_wr_req        wr_data_set_q2,
    //data_array interface 
    output  t_cl_rd_req         rd_cl_req_q2,
    input   var t_cl_rd_rsp     pre_rd_data_cl_rsp_q3,
    output  t_cl_wr_req         wr_data_cl_q3
);

t_cl_rd_rsp     hazard_rd_data_cl_rsp_q4;
t_cl_wr_req     wr_data_cl_q4;
t_cl_rd_rsp     rd_data_cl_rsp_q3;
t_set_rd_rsp    rd_data_set_rsp_q2;
t_set_rd_rsp    hazard_rd_data_set_rsp_q3;
t_set_wr_req    wr_data_set_q3;
t_pipe_bus      pre_cache_pipe_lu_q2, pre_cache_pipe_lu_q3;
t_pipe_bus      cache_pipe_lu_q1, cache_pipe_lu_q2, cache_pipe_lu_q3;
t_word_offset   lu_word_offset_q3;
logic [NUM_WAYS-1:0]                        way_tag_match_q2;
logic [WAY_WIDTH-1:0]                       way_tag_enc_match_q2;
logic [NUM_WORDS_IN_CL-1:0][WORD_WIDTH-1:0] data_array_data_q3;

logic [NUM_WAYS-1:0]                set_ways_mru_q2;
logic [NUM_WAYS-1:0]                set_ways_victim_q2;
logic [NUM_WAYS-1:0]                set_ways_modified_q2;
logic [NUM_WAYS-1:0]                set_ways_valid_q2;
logic [NUM_WAYS-1:0][TAG_WIDTH-1:0] set_ways_tags_q2; 
logic [NUM_WAYS-1:0][TAG_WIDTH-1:0] og_set_ways_tags_q2; 
logic [NUM_WAYS-1:0][TAG_WIDTH-1:0] og_set_ways_tags_q3; 

logic [WAY_WIDTH-1:0]               set_ways_enc_victim_q2;
logic [WAY_WIDTH-1:0]               set_ways_enc_victim_q3;

logic [NUM_WAYS-1:0]                set_ways_lru_q2;
logic [NUM_WAYS-1:0]                set_ways_free_q2;
logic [NUM_WAYS-1:0]                first_free_way_q2;
logic [NUM_WAYS-1:0]                first_lru_way_q2;
logic [NUM_WAYS-1:0]                victim_and_modified_q2;
logic                               dirty_evict_q2;
logic                               any_free_way_q2;
logic                               any_lru_way_q2;
logic hazard_detected_q2;
logic hazard_detected_q3;
//==================================================================
//       ____    _                     ___    _ 
//      |  _ \  (_)  _ __     ___     / _ \  / |
//      | |_) | | | | '_ \   / _ \   | | | | | |
//      |  __/  | | | |_) | |  __/   | |_| | | |
//      |_|     |_| | .__/   \___|    \__\_\ |_|
//                  |_|                         
//==================================================================
//      assign signals to the PIPE BUS 
//      Hold the pipe transaction indications & Data
//      assign the signals to the tag array lookup request
//=================================================================


//======================
//  SET_LOOKUP / TAG Array Lookup
//======================
    assign rd_set_req_q1.set = pipe_lu_req_q1.address[MSB_SET:LSB_SET];
//==================================================================

//======================
//  assign PIPE BUS
//======================
always_comb begin
  cache_pipe_lu_q1 ='0; //this is the default value
  cache_pipe_lu_q1.lu_valid         = pipe_lu_req_q1.valid ;
  cache_pipe_lu_q1.reg_id           = pipe_lu_req_q1.reg_id ;
  cache_pipe_lu_q1.lu_offset        = pipe_lu_req_q1.address[MSB_OFFSET:LSB_OFFSET];
  cache_pipe_lu_q1.lu_set           = pipe_lu_req_q1.address[MSB_SET:LSB_SET];
  cache_pipe_lu_q1.lu_tag           = pipe_lu_req_q1.address[MSB_TAG:LSB_TAG]; 
  cache_pipe_lu_q1.lu_op            = pipe_lu_req_q1.lu_op ;
  cache_pipe_lu_q1.cl_data          = pipe_lu_req_q1.cl_data;
  cache_pipe_lu_q1.data             = pipe_lu_req_q1.data;
  cache_pipe_lu_q1.mb_hit_cancel    = pipe_lu_req_q1.mb_hit_cancel ;
  cache_pipe_lu_q1.lu_tq_id         = pipe_lu_req_q1.tq_id; 
  cache_pipe_lu_q1.fill_modified    = pipe_lu_req_q1.wr_indication && pipe_lu_req_q1.lu_op == FILL_LU;
  cache_pipe_lu_q1.fill_rd          = pipe_lu_req_q1.rd_indication && pipe_lu_req_q1.lu_op == FILL_LU;
  cache_pipe_lu_q1.rd_indication    = pipe_lu_req_q1.rd_indication;

end //always_comb

//==================================================================
`MAFIA_DFF(pre_cache_pipe_lu_q2, cache_pipe_lu_q1, clk)
//==================================================================
//       ____    _                     ___    ____  
//      |  _ \  (_)  _ __     ___     / _ \  |___ \ 
//      | |_) | | | | '_ \   / _ \   | | | |   __) |
//      |  __/  | | | |_) | |  __/   | |_| |  / __/ 
//      |_|     |_| | .__/   \___|    \__\_\ |_____|
//                  |_|                             
//==================================================================
//  1. Solve hazard - If detect that q2 & q3 use the same set
//  2. TAG compare - find which way hit if any
//  3. incase of fill - choose victim for allocation
//  4. update the tag array. (MRU, tag incase of fill, etc)
//  5. rd request from data array
//==================================================================


//======================
//     Data_Hazard - accessing same set B2B 
//====================== 
assign hazard_detected_q2 = (cache_pipe_lu_q2.lu_set == cache_pipe_lu_q3.lu_set) && cache_pipe_lu_q3.lu_valid && cache_pipe_lu_q2.lu_valid;
assign hazard_rd_data_set_rsp_q3.valid    = wr_data_set_q3.valid;
assign hazard_rd_data_set_rsp_q3.tags     = wr_data_set_q3.tags;
assign hazard_rd_data_set_rsp_q3.modified = wr_data_set_q3.modified;
assign hazard_rd_data_set_rsp_q3.mru      = wr_data_set_q3.mru;
assign rd_data_set_rsp_q2 = hazard_detected_q2 ? hazard_rd_data_set_rsp_q3 : pre_rd_data_set_rsp_q2;
//======================
//     TAG_COMPARE 
//====================== 
always_comb begin
    for( int WAY =0; WAY<NUM_WAYS; WAY++) begin
        way_tag_match_q2[WAY] = (rd_data_set_rsp_q2.tags[WAY] == cache_pipe_lu_q2.lu_tag)  && 
                                 rd_data_set_rsp_q2.valid[WAY] &&
                                 cache_pipe_lu_q2.lu_valid ;
    end
end

//======================
//    ALOC_VICTIM (incase of fill)
//====================== 
//TODO: if Opcode is fill, find first invalid entry if all valids use MRU to choose victim
// set the cache_pipe_lu_q2.dirty_evict incase of modified data is the victim

assign set_ways_lru_q2  = ~rd_data_set_rsp_q2.mru;
assign set_ways_free_q2 = ~rd_data_set_rsp_q2.valid;
`FIND_FIRST(first_free_way_q2, set_ways_free_q2)
`FIND_FIRST(first_lru_way_q2 , set_ways_lru_q2)

always_comb begin : fill_victim_way
    set_ways_victim_q2 = '0; //TODO
    dirty_evict_q2     = 1'b0;
    any_free_way_q2    = |set_ways_free_q2;
    any_lru_way_q2     = |first_lru_way_q2;
    if( cache_pipe_lu_q2.lu_op == FILL_LU ) begin
        set_ways_victim_q2 = any_free_way_q2 ? first_free_way_q2 :
                             any_lru_way_q2  ? first_lru_way_q2  : // expecting always to have at lease 1 LRU (due to the bit flip)
                                               4'b0000 ;           // not expecting to occure - this will couse a bug if it doues 
    end
    // if entry is valid, modified and chosen as victim
    victim_and_modified_q2 = (rd_data_set_rsp_q2.valid & rd_data_set_rsp_q2.modified & set_ways_victim_q2); //the "and" will help us indicate if we choose a modified entry to evict
    // set the dirty evict bit
    dirty_evict_q2     = |victim_and_modified_q2;

end

//======================
//    WRITE_SET_UPDATE
//======================
//TODO: in case Rd hit update MRU 
//      in case of Wr hit update MRU , modified
//      in case of fill, update tag,valid,mru, modified?
always_comb begin
    set_ways_valid_q2    = rd_data_set_rsp_q2.valid;    //default value - keep data the same.
    set_ways_mru_q2      = rd_data_set_rsp_q2.mru;      //default value - keep data the same.  
    set_ways_modified_q2 = rd_data_set_rsp_q2.modified; //default value - keep data the same.  
    set_ways_tags_q2     = rd_data_set_rsp_q2.tags;     //default value - keep data the same.
    og_set_ways_tags_q2  = rd_data_set_rsp_q2.tags;     //default value - keep data the same.
    //-----------------------------
    // in case of RD hit update MRU
    //-----------------------------
    if ((cache_pipe_lu_q2.lu_op == RD_LU) && (cache_pipe_lu_q2.hit)) begin //Need to check valid too or hit is enough ? 
        set_ways_mru_q2      =  cache_pipe_lu_q2.set_ways_hit | rd_data_set_rsp_q2.mru;
    end

    //-----------------------------
    // in case of Wr hit update MRU , modified  
    //-----------------------------
    if ((cache_pipe_lu_q2.lu_op == WR_LU) && (cache_pipe_lu_q2.hit)) begin
        set_ways_mru_q2      = cache_pipe_lu_q2.set_ways_hit | rd_data_set_rsp_q2.mru;     // adding the way hit location to the current MRU vec
        set_ways_modified_q2 = cache_pipe_lu_q2.set_ways_hit | rd_data_set_rsp_q2.modified;// adding the way hit location to the current modified vec
    end
    
    //-----------------------------
    // in case of fill, update tag,valid,mru, modified?
    //-----------------------------
    if ((cache_pipe_lu_q2.lu_op == FILL_LU)) begin
        set_ways_mru_q2                           = cache_pipe_lu_q2.set_ways_victim | rd_data_set_rsp_q2.mru;
        set_ways_valid_q2                         = cache_pipe_lu_q2.set_ways_victim | rd_data_set_rsp_q2.valid;
        set_ways_tags_q2[set_ways_enc_victim_q2]  = cache_pipe_lu_q2.lu_tag;  // updating the way victim entry only - the rest of the ways are updated in the defuat value
        if(cache_pipe_lu_q2.fill_modified) begin //the fill has modified data from the merge buffer
            set_ways_modified_q2 = cache_pipe_lu_q2.set_ways_victim | rd_data_set_rsp_q2.modified;// adding the way victim to location to the current modified vec
        end
        else begin //clear the modified bit in the victim way
            set_ways_modified_q2 = ~cache_pipe_lu_q2.set_ways_victim & rd_data_set_rsp_q2.modified;// adding the way victim to location to the current modified vec
        end
    end

    //-----------------------------
    // if all are MRU - need to bit flip and set the new allocation/ last hit
    //-----------------------------
    if(&(set_ways_mru_q2)) begin        
        set_ways_mru_q2 = cache_pipe_lu_q2.hit ? cache_pipe_lu_q2.set_ways_hit    : //reset all, and set only the WR/RD Hit location
                                                 cache_pipe_lu_q2.set_ways_victim ; //reset all, and set only the WR/RD Hit location
    end

end

always_comb begin : tag_array_update_assignment
    //-----------------------------
    // assiging the final tag array update
    //-----------------------------
    wr_data_set_q2.en       =  cache_pipe_lu_q2.lu_valid;
    wr_data_set_q2.set      =  cache_pipe_lu_q2.lu_set; 
    wr_data_set_q2.tags     =  cache_pipe_lu_q2.set_ways_tags ;
    wr_data_set_q2.valid    =  cache_pipe_lu_q2.set_ways_valid ;
    wr_data_set_q2.modified =  cache_pipe_lu_q2.set_ways_modified ;
    wr_data_set_q2.mru      =  cache_pipe_lu_q2.set_ways_mru ;
end

//used for forwarding unit - Solve the Hazard of read after write to the same SET
`MAFIA_DFF(wr_data_set_q3, wr_data_set_q2, clk)
//======================
//    DATA_FETCH
//======================

//`ENCODER(way_tag_enc_match_q2 , valid_match, way_tag_match_q2 )
always_comb begin
    unique case (way_tag_match_q2)
        4'b0001 : way_tag_enc_match_q2 = 2'b00;
        4'b0010 : way_tag_enc_match_q2 = 2'b01;
        4'b0100 : way_tag_enc_match_q2 = 2'b10;
        4'b1000 : way_tag_enc_match_q2 = 2'b11;
        default : way_tag_enc_match_q2 = 2'b00;
    endcase
end

//`ENCODER(set_ways_enc_victim_q2 , set_ways_victim_q2 )
always_comb begin
    unique case (set_ways_victim_q2)
        4'b0001 : set_ways_enc_victim_q2 = 2'b00;
        4'b0010 : set_ways_enc_victim_q2 = 2'b01;
        4'b0100 : set_ways_enc_victim_q2 = 2'b10;
        4'b1000 : set_ways_enc_victim_q2 = 2'b11;
        default : set_ways_enc_victim_q2 = 2'b00;
    endcase
end

//======================
//    assign PIPE BUS
//======================

always_comb begin
  cache_pipe_lu_q2                      =   pre_cache_pipe_lu_q2;     //this is the default value
  cache_pipe_lu_q2.set_ways_valid       =   set_ways_valid_q2; //FIXME - need to update valid bits incase of fill
  cache_pipe_lu_q2.set_ways_tags        =   set_ways_tags_q2;  //FIXME - need to update tag incase of fill
  cache_pipe_lu_q2.set_ways_mru         =   set_ways_mru_q2;
  cache_pipe_lu_q2.set_ways_hit         =   way_tag_match_q2;
  cache_pipe_lu_q2.set_ways_enc_hit     =   way_tag_enc_match_q2;
  cache_pipe_lu_q2.set_ways_victim      =   set_ways_victim_q2;
  cache_pipe_lu_q2.set_ways_modified    =   set_ways_modified_q2;
  cache_pipe_lu_q2.hit                  =   |way_tag_match_q2;
  cache_pipe_lu_q2.miss                 =   !(|way_tag_match_q2) && (cache_pipe_lu_q2.lu_valid);
  cache_pipe_lu_q2.data_array_address   =   (cache_pipe_lu_q2.lu_op == FILL_LU) ? {cache_pipe_lu_q2.lu_set , set_ways_enc_victim_q2} :
                                                                                  {cache_pipe_lu_q2.lu_set , way_tag_enc_match_q2}   ;
  cache_pipe_lu_q2.dirty_evict          =  dirty_evict_q2;

end //always_comb

//data array read
assign rd_cl_req_q2.data_array_address = cache_pipe_lu_q2.data_array_address;


assign pipe_early_lu_rsp_q2.rd_miss       = cache_pipe_lu_q2.miss && (cache_pipe_lu_q2.lu_op == RD_LU) && cache_pipe_lu_q2.lu_valid;
assign pipe_early_lu_rsp_q2.alloc_rd_fill = cache_pipe_lu_q2.fill_rd && cache_pipe_lu_q2.lu_valid;
assign pipe_early_lu_rsp_q2.lu_tq_id      = cache_pipe_lu_q2.lu_tq_id;
assign pipe_early_lu_rsp_q2.cl_address    = {cache_pipe_lu_q2.lu_tag, cache_pipe_lu_q2.lu_set};

//==================================================================
`MAFIA_DFF(pre_cache_pipe_lu_q3, cache_pipe_lu_q2, clk)
//==================================================================
//       ____    _                     ___    _____ 
//      |  _ \  (_)  _ __     ___     / _ \  |___ / 
//      | |_) | | | | '_ \   / _ \   | | | |   |_ \ 
//      |  __/  | | | |_) | |  __/   | |_| |  ___) |
//      |_|     |_| | .__/   \___|    \__\_\ |____/ 
//                  |_|                             
//==================================================================
//
//
//==================================================================

//======================
//    assign PIPE BUS
//======================
always_comb begin
  cache_pipe_lu_q3  =   pre_cache_pipe_lu_q3; //this is the default value
end
//======================
//    TQ_UPDATE -> PIPE_LU_RSP_q3
//======================
assign pipe_lu_rsp_q3.valid         =   cache_pipe_lu_q3.lu_valid;
assign pipe_lu_rsp_q3.lu_op         =   cache_pipe_lu_q3.lu_op;
assign pipe_lu_rsp_q3.lu_result     =   (cache_pipe_lu_q3.lu_op == FILL_LU) ? FILL  :
                                        cache_pipe_lu_q3.hit                ? HIT   :
                                        cache_pipe_lu_q3.miss               ? MISS  : 
                                                                              NO_RSP;                      
assign pipe_lu_rsp_q3.tq_id         =   cache_pipe_lu_q3.lu_tq_id; 
assign pipe_lu_rsp_q3.cl_data       =   (cache_pipe_lu_q3.lu_op == FILL_LU)                             ? cache_pipe_lu_q3.cl_data  :
                                        (cache_pipe_lu_q3.lu_op == RD_LU) && (cache_pipe_lu_q3.hit)     ? rd_data_cl_rsp_q3         :
                                                                                                        '0;    
assign pipe_lu_rsp_q3.address       =    {cache_pipe_lu_q3.lu_tag,cache_pipe_lu_q3.lu_set,cache_pipe_lu_q3.lu_offset};
assign pipe_lu_rsp_q3.reg_id        =    cache_pipe_lu_q3.reg_id;
assign pipe_lu_rsp_q3.rd_indication =    cache_pipe_lu_q3.rd_indication;

logic wr_match_in_pipe_q1_q3;
logic wr_match_in_pipe_q2_q3;
assign wr_match_in_pipe_q2_q3 = ({cache_pipe_lu_q3.lu_tag,cache_pipe_lu_q3.lu_set} == {cache_pipe_lu_q2.lu_tag,cache_pipe_lu_q2.lu_set}) && //Match address q3 and q2
                                ( cache_pipe_lu_q3.lu_valid        && cache_pipe_lu_q2.lu_valid)             && //Both valid q3 and q2
                                ( cache_pipe_lu_q3.lu_op == WR_LU) && (cache_pipe_lu_q2.lu_op == WR_LU);        //Both write q3 and q2

assign wr_match_in_pipe_q1_q3 = ({cache_pipe_lu_q3.lu_tag,cache_pipe_lu_q3.lu_set} == {cache_pipe_lu_q1.lu_tag,cache_pipe_lu_q1.lu_set}) && //Match address q3 and q1
                                ( cache_pipe_lu_q3.lu_valid        && cache_pipe_lu_q1.lu_valid)             && //Both valid q3 and q1
                                ( cache_pipe_lu_q3.lu_op == WR_LU) && (cache_pipe_lu_q1.lu_op == WR_LU);        //Both write q3 and q1
assign pipe_lu_rsp_q3.wr_match_in_pipe = wr_match_in_pipe_q1_q3 || wr_match_in_pipe_q2_q3;

`MAFIA_DFF(og_set_ways_tags_q3,    og_set_ways_tags_q2, clk)
`MAFIA_DFF(set_ways_enc_victim_q3, set_ways_enc_victim_q2, clk)
always_comb begin
    cache2fm_req_q3 = '0;   
//======================
//    DIRTY_EVICT 
//======================
//We should dirty evict to far memory only in case of fill that allocated a modified entry
if (cache_pipe_lu_q3.dirty_evict &&
    (cache_pipe_lu_q3.lu_op == FILL_LU)) begin
    cache2fm_req_q3.valid    =  cache_pipe_lu_q3.lu_valid; 
    cache2fm_req_q3.address  = {og_set_ways_tags_q3[set_ways_enc_victim_q3], cache_pipe_lu_q3.lu_set, 4'b0000};
    cache2fm_req_q3.tq_id    =  cache_pipe_lu_q3.lu_tq_id;
    cache2fm_req_q3.data     =  rd_data_cl_rsp_q3;
    cache2fm_req_q3.opcode   =  DIRTY_EVICT_OP;
end

//======================
//    CACHE_MISS, send FM_FILL_REQUEST
//======================
//in case of Rd/Wr cache_miss send a FM fill request
if (cache_pipe_lu_q3.miss && 
   (!(cache_pipe_lu_q3.lu_op == FILL_LU)) &&
   (!(cache_pipe_lu_q3.mb_hit_cancel))) begin
    cache2fm_req_q3.valid   =  cache_pipe_lu_q3.lu_valid; 
    cache2fm_req_q3.address = {cache_pipe_lu_q3.lu_tag, cache_pipe_lu_q3.lu_set, cache_pipe_lu_q3.lu_offset};
    cache2fm_req_q3.tq_id   =  cache_pipe_lu_q3.lu_tq_id;
    cache2fm_req_q3.data    =  '0; //Rd Request does not use data field
    cache2fm_req_q3.opcode  =  FILL_REQ_OP;
end 
end
//======================
//     Data_Hazard - accessing same set B2B 
//====================== 
assign hazard_detected_q3 = (wr_data_cl_q4.data_array_address == wr_data_cl_q3.data_array_address) && wr_data_cl_q4.valid;
assign hazard_rd_data_cl_rsp_q4 = wr_data_cl_q4.data;
assign rd_data_cl_rsp_q3  = hazard_detected_q3 ? hazard_rd_data_cl_rsp_q4  : pre_rd_data_cl_rsp_q3;
//======================
//    WRITE_DATA
//======================
assign lu_word_offset_q3 = cache_pipe_lu_q3.lu_offset[MSB_WORD_OFFSET:LSB_WORD_OFFSET];

always_comb begin
    data_array_data_q3                   =   rd_data_cl_rsp_q3; //the current CL in data array
    data_array_data_q3[lu_word_offset_q3]=   cache_pipe_lu_q3.data; //override the specific word
    wr_data_cl_q3                        =   '0;
    wr_data_cl_q3.data                   =   (cache_pipe_lu_q3.lu_op == FILL_LU)                             ? cache_pipe_lu_q3.cl_data  :
                                             (cache_pipe_lu_q3.lu_op == WR_LU)   && (cache_pipe_lu_q3.hit)   ? data_array_data_q3        : 
                                                                                                            '0; 
    wr_data_cl_q3.data_array_address     =  cache_pipe_lu_q3.data_array_address;
    wr_data_cl_q3.valid                  =  (cache_pipe_lu_q3.lu_valid && ((cache_pipe_lu_q3.lu_op == WR_LU) && cache_pipe_lu_q3.hit)) ||
                                            (cache_pipe_lu_q3.lu_valid && (cache_pipe_lu_q3.lu_op == FILL_LU));
end


`MAFIA_DFF(wr_data_cl_q4, wr_data_cl_q3, clk)
endmodule
