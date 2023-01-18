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

module cache_pipe
    import cache_param_pkg::*;  
(
    input   logic               clk,
    input   logic               rst,
    //tq interface 
    input   var t_lu_req        pipe_lu_req_q1,
    output  t_lu_rsp            pipe_lu_rsp_q3,
    // FM interface Reqiuets 
    output  t_fm_req            cache2fm_req_q3,
    //tag_array interface 
    output  t_set_rd_req        rd_set_req_q1,
    input   var t_set_rd_rsp    rd_data_set_rsp_q2,
    output  t_set_wr_req        wr_data_set_q2,
    //data_array interface 
    output  t_cl_rd_req         rd_cl_req_q2,
    input   var t_cl_rd_rsp     rd_data_cl_rsp_q3,
    output  t_cl_wr_req         wr_data_cl_q3

);

t_pipe_bus pre_cache_pipe_lu_q2, pre_cache_pipe_lu_q3;
t_pipe_bus cache_pipe_lu_q1, cache_pipe_lu_q2, cache_pipe_lu_q3;
t_offset    lu_offset_q3;
logic [NUM_WAYS-1:0] way_tag_match_q2;
logic [WAY_WIDTH-1:0] way_tag_enc_match_q2;
logic   [NUM_WORDS_IN_CL-1:0][WORD_WIDTH-1:0] data_array_data_q3;



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
  cache_pipe_lu_q1.lu_offset        = pipe_lu_req_q1.address[MSB_OFFSET:LSB_OFFSET];
  cache_pipe_lu_q1.lu_set           = pipe_lu_req_q1.address[MSB_SET:LSB_SET];
  cache_pipe_lu_q1.lu_tag           = pipe_lu_req_q1.address[MSB_TAG:LSB_TAG]; 
  cache_pipe_lu_q1.lu_op            = pipe_lu_req_q1.lu_op ;
  cache_pipe_lu_q1.cl_data          = pipe_lu_req_q1.cl_data;
  cache_pipe_lu_q1.data             = pipe_lu_req_q1.data;
end //always_comb

//==================================================================
`RVC_DFF(pre_cache_pipe_lu_q2, cache_pipe_lu_q1, clk)
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
//TODO: Detect acces to same set back2back

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


//======================
//    WRITE_SET_UPDATE
//======================
//TODO: in case Rd hit update MRU 
//      in case of Wr hit update MRU , modified
//      in case of fill, update tag,valid,mru, modified?
assign wr_data_set_q2     = '0;

always_comb begin 
    //in case Rd hit update MRU 
    if ((cache_pipe_lu_q2.lu_op == RD_LU)&&(cache_pipe_lu_q2.hit)) begin //Need to check valid too or hit is enough ? 
        
    end

    //      in case of Wr hit update MRU , modified  
    if ((cache_pipe_lu_q2.lu_op == WR_LU)&&(cache_pipe_lu_q2.hit)) begin
        
    end
    
    //      in case of fill, update tag,valid,mru, modified?
    if ((cache_pipe_lu_q2.lu_op == FILL_LU)) begin
        
    end



end

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


//======================
//    assign PIPE BUS
//======================

always_comb begin
  cache_pipe_lu_q2                      =   pre_cache_pipe_lu_q2; //this is the default value
  cache_pipe_lu_q2.set_ways_valid       =   rd_data_set_rsp_q2.valid;
  cache_pipe_lu_q2.set_ways_tags        =   rd_data_set_rsp_q2.tags;
  cache_pipe_lu_q2.set_ways_mru         =   rd_data_set_rsp_q2.mru;
  cache_pipe_lu_q2.set_ways_hit         =   way_tag_match_q2;
  cache_pipe_lu_q2.set_ways_enc_hit     =   way_tag_enc_match_q2;
  cache_pipe_lu_q2.hit                  =   |way_tag_match_q2;
  cache_pipe_lu_q2.miss                 =   !(|way_tag_match_q2) && (cache_pipe_lu_q2.lu_valid);
  cache_pipe_lu_q2.data_array_address   =   {cache_pipe_lu_q2.lu_set , cache_pipe_lu_q2.set_ways_enc_hit};

end //always_comb

//data array read
assign rd_cl_req_q2.cl_address = cache_pipe_lu_q2.data_array_address;


//==================================================================
`RVC_DFF(pre_cache_pipe_lu_q3, cache_pipe_lu_q2, clk)
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
//    TQ_UPDATE -> PIPE_LU_RSP_q3
//======================

assign pipe_lu_rsp_q3.valid         =   cache_pipe_lu_q3.lu_valid;
assign pipe_lu_rsp_q3.lu_opcode     =   cache_pipe_lu_q3.lu_op;
assign pipe_lu_rsp_q3.lu_result     =   cache_pipe_lu_q3.hit ?      HIT :
                                        cache_pipe_lu_q3.miss ?     MISS : 
                                                                    NO_RSP;                      
assign pipe_lu_rsp_q3.tq_id         =   cache_pipe_lu_q3.lu_tq_id; 
assign pipe_lu_rsp_q3.data          =   (cache_pipe_lu_q3.lu_op == FILL_LU)                             ? cache_pipe_lu_q3.cl_data  :
                                        (cache_pipe_lu_q3.lu_op == RD_LU) && (cache_pipe_lu_q3.hit)     ? rd_data_cl_rsp_q3         :
                                                                                                        '0;    
assign pipe_lu_rsp_q3.address       =    {cache_pipe_lu_q3.lu_tag,cache_pipe_lu_q3.lu_set,cache_pipe_lu_q3.lu_offset,2'b00};

//======================
//    assign PIPE BUS
//======================
always_comb begin
  cache_pipe_lu_q3  =   pre_cache_pipe_lu_q3; //this is the default value
end


always_comb begin
    cache2fm_req_q3 = '0;   
//======================
//    DIRTY_EVICT 
//======================
//We should dirty evict to far memory only in case of fill that allocated a modified entry
if (cache_pipe_lu_q3.dirty_evict &&
    (cache_pipe_lu_q3.lu_op == FILL_LU)) begin
    cache2fm_req_q3.valid    = cache_pipe_lu_q3.lu_valid; 
    cache2fm_req_q3.address  ={cache_pipe_lu_q3.lu_tag, cache_pipe_lu_q3.lu_set, cache_pipe_lu_q3.lu_offset, 2'b00};
    cache2fm_req_q3.tq_id    = cache_pipe_lu_q3.lu_tq_id;
    cache2fm_req_q3.data     = cache_pipe_lu_q3.cl_data;
    cache2fm_req_q3.opcode   = DIRTY_EVICT_OP;
end

//======================
//    CACHE_MISS, send FM_FILL_REQUEST
//======================
//in case of Rd/Wr cache_miss send a FM fill request
if (cache_pipe_lu_q3.miss) begin
    cache2fm_req_q3.valid   = cache_pipe_lu_q3.lu_valid; 
    cache2fm_req_q3.address ={cache_pipe_lu_q3.lu_tag, cache_pipe_lu_q3.lu_set, cache_pipe_lu_q3.lu_offset, 2'b00};
    cache2fm_req_q3.tq_id   = cache_pipe_lu_q3.lu_tq_id;
    cache2fm_req_q3.data    = '0; //Rd Request does not use data field
    cache2fm_req_q3.opcode  = FILL_REQ_OP;
end 
end

//======================
//    WRITE_DATA
//======================
assign lu_offset_q3 = cache_pipe_lu_q3.lu_offset;

always_comb begin
    data_array_data_q3                  =   rd_data_cl_rsp_q3; //the current CL in data array
    data_array_data_q3[lu_offset_q3]    =   cache_pipe_lu_q3.data; //overide the specific word
    wr_data_cl_q3                       =   '0;
    wr_data_cl_q3.data                  =   (cache_pipe_lu_q3.lu_op == FILL_LU)                             ? cache_pipe_lu_q3.cl_data  :
                                            (cache_pipe_lu_q3.lu_op == WR_LU)   && (cache_pipe_lu_q3.hit)   ? data_array_data_q3        : 
                                                                                                            '0; 
    wr_data_cl_q3.cl_address            =   cache_pipe_lu_q3.data_array_address;
    wr_data_cl_q3.valid                 =   (cache_pipe_lu_q3.lu_valid &&   
                                            ((cache_pipe_lu_q3.lu_op == WR_LU)|| (cache_pipe_lu_q3.lu_op == FILL_LU)));
end



endmodule
