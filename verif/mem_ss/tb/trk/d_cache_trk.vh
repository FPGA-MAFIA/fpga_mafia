//-----------------------------------------------------------------------------
// Title            : cache_trk
// Project          : fpga_mafia
//-----------------------------------------------------------------------------
// File             : cache_trk.vh
// Original Author  : Noam Sabban
// Code Owner       : 
// Created          : 12/2022
//-----------------------------------------------------------------------------
// Description :
// Create the different Trackers for our Cache   
//-----------------------------------------------------------------------------





integer d_cache_top_trk;
integer d_cache_pipe_io_trk;
integer d_cache_tq_trk;
integer cache_ref_gold_trk;
integer cache_ref_trk;
integer d_cache_pipe_stages_trk;

initial begin
    #1
    if ($value$plusargs ("STRING=%s", test_name))
        $display("creating tracker in test directory: target/mem_ss/tests/%s", test_name);
    $timeformat(-12, 0, "", 6);
    
    d_cache_top_trk      = $fopen({"../../../target/mem_ss/tests/",test_name,"/d_cache_top_trk.log"},"w");
    $fwrite(d_cache_top_trk, "==================================================================================\n");
    $fwrite(d_cache_top_trk, "                      D_CACHE TOP TRACKER  -  Test: ",test_name,"\n");
    $fwrite(d_cache_top_trk, "==================================================================================\n");
    $fwrite(d_cache_top_trk,"-----------------------------------------------------------------------------------\n");
    $fwrite(d_cache_top_trk," Time  ||  OPCODE        || address ||REG/TQ_ID|| tag  || Set ||    Data \n");
    $fwrite(d_cache_top_trk,"-----------------------------------------------------------------------------------\n");

    d_cache_pipe_io_trk = $fopen({"../../../target/mem_ss/tests/",test_name,"/d_cache_pipe_io_trk.log"},"w");
    $fwrite(d_cache_pipe_io_trk,"==========================================================================================\n");
    $fwrite(d_cache_pipe_io_trk,"                      D_CACHE PIPE I/O TRACKER  -  Test: ",test_name,"\n"); 
    $fwrite(d_cache_pipe_io_trk,"==========================================================================================\n");
    $fwrite(d_cache_pipe_io_trk,"------------------------------------------------------------------------------------------\n");
    $fwrite(d_cache_pipe_io_trk,"  Time  ||REQ/RSP||  OPCODE  || TQ ID ||  address  || rd ind || wr ind || Data/Result ||   CL־Data \n");
    $fwrite(d_cache_pipe_io_trk,"------------------------------------------------------------------------------------------\n");

    d_cache_pipe_stages_trk = $fopen({"../../../target/mem_ss/tests/",test_name,"/d_cache_pipe_stages_trk.log"},"w");
    $fwrite(d_cache_pipe_stages_trk,"==========================================================================================================================================================================================================================================================================\n");
    $fwrite(d_cache_pipe_stages_trk,"                                                               D_CACHE PIPE STAGES TRACKER  -  Test: ",test_name,"\n"); 

    $fwrite(d_cache_pipe_stages_trk,"==========================================================================================================================================================================================================================================================================\n");
    $fwrite(d_cache_pipe_stages_trk,"-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n");
    $fwrite(d_cache_pipe_stages_trk,"Time || OPCODE || TQ || s_w_mru || hit|miss || mb_hit || tag ||set || offset ||   Data  || s_w_valid || s_w_modified ||   s_w_tags  ||  s_w_victim ||  s_w_hit  ||  fill  || fill || dirty ||           cl_data_q3               ||  data array|| cl_data          \n");
    $fwrite(d_cache_pipe_stages_trk,"                  ID                           cancel                                                                                                             modified    rd     evict                                            address                                                                \n");
    $fwrite(d_cache_pipe_stages_trk,"-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n");  

    d_cache_tq_trk      = $fopen({"../../../target/mem_ss/tests/",test_name,"/d_cache_tq_trk.log"},"w");
    $fwrite(d_cache_tq_trk,"====================================================================================================================\n");
    $fwrite(d_cache_tq_trk,"                      D_CACHE TQ TRACKER  -  Test: ",test_name,"\n");
    $fwrite(d_cache_tq_trk,"====================================================================================================================\n");
    $fwrite(d_cache_tq_trk,"--------------------------------------------------------------------------------------------------------------------\n");
    $fwrite(d_cache_tq_trk," Time ||ENTRY||    State      ||  RD  ||  WR  || cl address ||             MB DATA            || REG ID  || cl word offset   rd /wr hit\n");
    $fwrite(d_cache_tq_trk,"---------------------------------------------------------------------------------------------------------------------\n ");

    cache_ref_gold_trk = $fopen({"../../../target/mem_ss/tests/",test_name,"/cache_ref_gold_trk.log"},"w");
    $fwrite(cache_ref_gold_trk,"====================================================================================================================\n");
    $fwrite(cache_ref_gold_trk,"                      Core<->Cache  -  Test: ",test_name,"\n");
    $fwrite(cache_ref_gold_trk,"====================================================================================================================\n");
    $fwrite(cache_ref_gold_trk,"-----------------------------------------------------------------------------------\n");
    $fwrite(cache_ref_gold_trk,"   OPCODE        || address ||REG      || tag  || Set ||    Data \n");
    $fwrite(cache_ref_gold_trk,"-----------------------------------------------------------------------------------\n");
    cache_ref_trk      = $fopen({"../../../target/mem_sS/tests/",test_name,"/cache_ref_trk.log"},"w");
    $fwrite(cache_ref_trk,"====================================================================================================================\n");
    $fwrite(cache_ref_trk,"                      Core<->Cache  -  Test: ",test_name,"\n");
    $fwrite(cache_ref_trk,"====================================================================================================================\n");
    $fwrite(cache_ref_trk,"-----------------------------------------------------------------------------------\n");
    $fwrite(cache_ref_trk,"   OPCODE        || address ||REG      || tag  || Set ||    Data \n");
    $fwrite(cache_ref_trk,"-----------------------------------------------------------------------------------\n");


end

always @(posedge clk) begin
//==================================================
// tracker of the Cache Top Level Interface
//==================================================
    if(dmem_core2cache_req.valid && (dmem_core2cache_req.opcode == RD_OP )) begin
        $fwrite(d_cache_top_trk,"%t     CORE_RD_REQ       %h       %h        %h     %h      ( -- read request -- ) \n",
        $realtime, 
        dmem_core2cache_req.address, 
        dmem_core2cache_req.reg_id, 
        dmem_core2cache_req.address[MSB_TAG:LSB_TAG] , 
        dmem_core2cache_req.address[MSB_SET:LSB_SET]);      
    end
    if(dmem_core2cache_req.valid && (dmem_core2cache_req.opcode == WR_OP )) begin
        $fwrite(d_cache_top_trk,"%t     CORE_WR_REQ       %h       %h        %h     %h      %h \n",
        $realtime, 
        dmem_core2cache_req.address, 
        dmem_core2cache_req.reg_id, 
        dmem_core2cache_req.address[MSB_TAG:LSB_TAG] , 
        dmem_core2cache_req.address[MSB_SET:LSB_SET],
        dmem_core2cache_req.data);      
    end
    if(dmem_cache2core_rsp.valid) begin
        $fwrite(d_cache_top_trk,"%t     CACHE_RD_RSP      %h       %h        %h     %h      %h \n",
        $realtime, 
        dmem_cache2core_rsp.address, 
        dmem_cache2core_rsp.reg_id, 
        dmem_cache2core_rsp.address[MSB_TAG:LSB_TAG] , 
        dmem_cache2core_rsp.address[MSB_SET:LSB_SET], 
        dmem_cache2core_rsp.data);
    end

    if(dmem_cache2fm_req_q3.valid && (dmem_cache2fm_req_q3.opcode == DIRTY_EVICT_OP)) begin
        $fwrite(d_cache_top_trk,"%t     CACHE_DIRTY_EVICT %h       %h         %h     %h      %h_%h_%h_%h  \n",
        $realtime, 
        dmem_cache2fm_req_q3.address, 
        dmem_cache2fm_req_q3.tq_id, 
        dmem_cache2fm_req_q3.address[MSB_TAG:LSB_TAG] , 
        dmem_cache2fm_req_q3.address[MSB_SET:LSB_SET], 
        dmem_cache2fm_req_q3.data[127:96],
        dmem_cache2fm_req_q3.data[95:64],
        dmem_cache2fm_req_q3.data[63:32],
        dmem_cache2fm_req_q3.data[31:0]
        );
    end

    if(dmem_cache2fm_req_q3.valid && (dmem_cache2fm_req_q3.opcode == FILL_REQ_OP)) begin
        $fwrite(d_cache_top_trk,"%t     CACHE_FILL_REQ    %h       %h         %h     %h      ( -- read request -- ) \n",
        $realtime, 
        dmem_cache2fm_req_q3.address, 
        dmem_cache2fm_req_q3.tq_id, 
        dmem_cache2fm_req_q3.address[MSB_TAG:LSB_TAG] , 
        dmem_cache2fm_req_q3.address[MSB_SET:LSB_SET]);
    end
    if(fm2cache_rd_rsp.valid) begin
        $fwrite(d_cache_top_trk,"%t     FM_FILL_RSP        %h                   ----   ----     %h_%h_%h_%h \n",
        $realtime, 
        fm2cache_rd_rsp.address, 
        fm2cache_rd_rsp.data[127:96], 
        fm2cache_rd_rsp.data[95:64], 
        fm2cache_rd_rsp.data[63:32], 
        fm2cache_rd_rsp.data[31:0]);
    end

//==================================================
// tracker on cache Pipe IO
//==================================================

 //===== Request Tracker =====   
    if(d_cache.d_cache_pipe_wrap.pipe_lu_req_q1.valid) begin
        $fwrite(d_cache_pipe_io_trk,"%t      Request   %-7s    %h        %h        %h         %h        %h      %h\n",
        $realtime,
        d_cache.d_cache_pipe_wrap.pipe_lu_req_q1.lu_op.name(), 
        d_cache.d_cache_pipe_wrap.pipe_lu_req_q1.tq_id, 
        d_cache.d_cache_pipe_wrap.pipe_lu_req_q1.address, 
        d_cache.d_cache_pipe_wrap.pipe_lu_req_q1.rd_indication,
        d_cache.d_cache_pipe_wrap.pipe_lu_req_q1.wr_indication,
        d_cache.d_cache_pipe_wrap.pipe_lu_req_q1.data,
        d_cache.d_cache_pipe_wrap.pipe_lu_req_q1.cl_data);  

    end

 //===== Response Tracker =====   
    if(d_cache.d_cache_pipe_wrap.pipe_lu_rsp_q3.valid) begin
        $fwrite(d_cache_pipe_io_trk,"%t      Response  %-7s    %h        %h      (---lu resp---)         %-4h       %h\n",
        $realtime,
        d_cache.d_cache_pipe_wrap.pipe_lu_rsp_q3.lu_op.name(),
        d_cache.d_cache_pipe_wrap.pipe_lu_rsp_q3.tq_id,
        d_cache.d_cache_pipe_wrap.pipe_lu_rsp_q3.address,
        d_cache.d_cache_pipe_wrap.pipe_lu_rsp_q3.lu_result.name(), 
        d_cache.d_cache_pipe_wrap.pipe_lu_rsp_q3.cl_data);     
    end


// //==================================================
// // tracker on Pipe Stages
// //==================================================
if(d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.lu_valid) begin
      $fwrite(d_cache_pipe_stages_trk,"%t   %-7s  %h    {%h,%h,%h,%h}   %h     %h       %h       %h     %h      %h      %h   {%h,%h,%h,%h}     {%h,%h,%h,%h}      {%h,%h,%h,%h}    {%h,%h,%h,%h}     {%h,%h,%h,%h}       %h       %h        %h     %h    %h      %h\n",
      $realtime,
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.lu_op.name(),
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.lu_tq_id,
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_mru[0],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_mru[1],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_mru[2],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_mru[3],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.hit,
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.miss,
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.mb_hit_cancel, 
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.lu_tag,
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.lu_set,
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.lu_offset,
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.data,
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_valid[0],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_valid[1],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_valid[2],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_valid[3],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_modified[0],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_modified[1],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_modified[2],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_modified[3],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_tags[0],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_tags[1],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_tags[2],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_tags[3],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_victim[0],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_victim[1],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_victim[2],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_victim[3],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_hit[0],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_hit[1],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_hit[2],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.set_ways_hit[3],
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.fill_modified,
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.fill_rd,
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.dirty_evict,
      d_cache.d_cache_pipe_wrap.pipe_lu_rsp_q3.cl_data,
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.data_array_address,
      d_cache.d_cache_pipe_wrap.d_cache_pipe.cache_pipe_lu_q3.cl_data
      );     
  end
// //==================================================
// // tracker on TQ
// //==================================================
    for (int i=0; i< NUM_TQ_ENTRY; ++i) begin
        if ((d_cache.d_cache_tq.tq_entry[i].state != d_cache.d_cache_tq.next_tq_entry[i].state) ||
             ((d_cache.d_cache_tq.tq_entry[i].state != S_IDLE) &&  dmem_core2cache_req.valid && (d_cache.d_cache_tq.rd_req_hit_mb[i] || d_cache.d_cache_tq.wr_req_hit_mb[i]) )
             ) begin
        $fwrite(d_cache_tq_trk,"%t Entry[%1d]  %-15s   %h       %h       %h      %h     %h            %h              \n",
        $realtime,
        i,
        d_cache.d_cache_tq.next_tq_entry[i].state.name       ,     
        d_cache.d_cache_tq.next_tq_entry[i].rd_indication    ,     
        d_cache.d_cache_tq.next_tq_entry[i].wr_indication    ,         
        d_cache.d_cache_tq.next_tq_entry[i].cl_address       ,
        d_cache.d_cache_tq.next_tq_entry[i].merge_buffer_data,      
        d_cache.d_cache_tq.next_tq_entry[i].cl_word_offset   ,     
        d_cache.d_cache_tq.next_tq_entry[i].reg_id           
        );


        end
    end    
end //always(posedge)


always @(posedge clk) begin
//==================================================
// tracker of reference model - core<->cache
//==================================================
    if(ref_cache2core_rsp.valid) begin
        $fwrite(cache_ref_gold_trk,"     CACHE_RD_RSP      %h       %h        %h     %h      %h \n",
        ref_cache2core_rsp.address, 
        ref_cache2core_rsp.reg_id, 
        ref_cache2core_rsp.address[MSB_TAG:LSB_TAG] , 
        ref_cache2core_rsp.address[MSB_SET:LSB_SET], 
        ref_cache2core_rsp.data);
    end
//==================================================
// tracker of reference model - core<->cache
//==================================================
    if(dmem_cache2core_rsp.valid) begin
        $fwrite(cache_ref_trk,"     CACHE_RD_RSP      %h       %h        %h     %h      %h \n",
        dmem_cache2core_rsp.address, 
        dmem_cache2core_rsp.reg_id, 
        dmem_cache2core_rsp.address[MSB_TAG:LSB_TAG] , 
        dmem_cache2core_rsp.address[MSB_SET:LSB_SET], 
        dmem_cache2core_rsp.data);
    end
    


end //always(posedge)
