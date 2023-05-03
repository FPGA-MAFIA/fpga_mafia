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
// Create the differents Trackers for our Cache   
//-----------------------------------------------------------------------------





integer cache_top_trk;
integer cache_pipe_io_trk;
integer cache_tq_trk;
integer cache_ref_gold_trk;
integer cache_ref_trk;
integer cache_pipe_stages_trk;

initial begin
    if ($value$plusargs ("STRING=%s", test_name))
        $display("creating tracker in test directory: target/cache/tests/%s", test_name);
    $timeformat(-12, 0, "", 6);
    
    cache_top_trk      = $fopen({"../../../target/cache/tests/",test_name,"/cache_top_trk.log"},"w");
    $fwrite(cache_top_trk, "==================================================================================\n");
    $fwrite(cache_top_trk, "                      CACHE TOP TRACKER  -  Test: ",test_name,"\n");
    $fwrite(cache_top_trk, "==================================================================================\n");
    $fwrite(cache_top_trk,"-----------------------------------------------------------------------------------\n");
    $fwrite(cache_top_trk," Time  ||  OPCODE        || address ||REG/TQ_ID|| tag  || Set ||    Data \n");
    $fwrite(cache_top_trk,"-----------------------------------------------------------------------------------\n");

    cache_pipe_io_trk = $fopen({"../../../target/cache/tests/",test_name,"/cache_pipe_io_trk.log"},"w");
    $fwrite(cache_pipe_io_trk,"==========================================================================================\n");
    $fwrite(cache_pipe_io_trk,"                      CACHE PIPE I/O TRACKER  -  Test: ",test_name,"\n"); 
    $fwrite(cache_pipe_io_trk,"==========================================================================================\n");
    $fwrite(cache_pipe_io_trk,"------------------------------------------------------------------------------------------\n");
    $fwrite(cache_pipe_io_trk,"  Time  ||REQ/RSP||  OPCODE  || TQ ID ||  address  || rd ind || wr ind || Data/Result ||   CL־Data \n");
    $fwrite(cache_pipe_io_trk,"------------------------------------------------------------------------------------------\n");

    cache_pipe_stages_trk = $fopen({"../../../target/cache/tests/",test_name,"/cache_pipe_stages_trk.log"},"w");
    $fwrite(cache_pipe_stages_trk,"==========================================================================================================================================================================================================================================================================\n");
    $fwrite(cache_pipe_stages_trk,"                                                               CACHE PIPE STAGES TRACKER  -  Test: ",test_name,"\n"); 
    $fwrite(cache_pipe_stages_trk,"==========================================================================================================================================================================================================================================================================\n");
    $fwrite(cache_pipe_stages_trk,"-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n");
    $fwrite(cache_pipe_stages_trk,"Time || OPCODE || TQ || s_w_mru || hit|miss || mb_hit || tag ||set || offset ||   Data  || s_w_valid || s_w_modified ||   s_w_tags  ||  s_w_victim ||  s_w_hit  ||  fill  || fill || dirty || data array|| cl_data          \n");
    $fwrite(cache_pipe_stages_trk,"                  ID                           cancel                                                                                                             modified    rd     evict     address                                                                \n");
    $fwrite(cache_pipe_stages_trk,"-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n");  

    cache_tq_trk      = $fopen({"../../../target/cache/tests/",test_name,"/cache_tq_trk.log"},"w");
    $fwrite(cache_tq_trk,"====================================================================================================================\n");
    $fwrite(cache_tq_trk,"                      CACHE TQ TRACKER  -  Test: ",test_name,"\n");
    $fwrite(cache_tq_trk,"====================================================================================================================\n");
    $fwrite(cache_tq_trk,"--------------------------------------------------------------------------------------------------------------------\n");
    $fwrite(cache_tq_trk," Time ||ENTRY||    State      ||  RD  ||  WR  || cl adress ||             MB DATA            || REG ID  || cl word offset   rd /wr hit\n");
    $fwrite(cache_tq_trk,"---------------------------------------------------------------------------------------------------------------------\n ");

    cache_ref_gold_trk = $fopen({"../../../target/cache/tests/",test_name,"/cache_ref_gold_trk.log"},"w");
    cache_ref_trk      = $fopen({"../../../target/cache/tests/",test_name,"/cache_ref_trk.log"},"w");
    $fwrite(cache_ref_gold_trk,"====================================================================================================================\n");
    $fwrite(cache_ref_gold_trk,"                      Core<->Cache  -  Test: ",test_name,"\n");
    $fwrite(cache_ref_gold_trk,"====================================================================================================================\n");
    $fwrite(cache_ref_gold_trk,"-----------------------------------------------------------------------------------\n");
    $fwrite(cache_ref_gold_trk,"   OPCODE        || address ||REG      || tag  || Set ||    Data \n");
    $fwrite(cache_ref_gold_trk,"-----------------------------------------------------------------------------------\n");
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
    if(core2cache_req.valid && (core2cache_req.opcode == RD_OP )) begin
        $fwrite(cache_top_trk,"%t     CORE_RD_REQ       %h       %h        %h     %h      ( -- read request -- ) \n",
        $realtime, 
        core2cache_req.address, 
        core2cache_req.reg_id, 
        core2cache_req.address[MSB_TAG:LSB_TAG] , 
        core2cache_req.address[MSB_SET:LSB_SET]);      
    end
    if(core2cache_req.valid && (core2cache_req.opcode == WR_OP )) begin
        $fwrite(cache_top_trk,"%t     CORE_WR_REQ       %h       %h        %h     %h      %h \n",
        $realtime, 
        core2cache_req.address, 
        core2cache_req.reg_id, 
        core2cache_req.address[MSB_TAG:LSB_TAG] , 
        core2cache_req.address[MSB_SET:LSB_SET],
        core2cache_req.data);      
    end
    if(cache2core_rsp.valid) begin
        $fwrite(cache_top_trk,"%t     CACHE_RD_RSP      %h       %h        %h     %h      %h \n",
        $realtime, 
        cache2core_rsp.address, 
        cache2core_rsp.reg_id, 
        cache2core_rsp.address[MSB_TAG:LSB_TAG] , 
        cache2core_rsp.address[MSB_SET:LSB_SET], 
        cache2core_rsp.data);
    end
    if(cache2fm_req_q3.valid && (cache2fm_req_q3.opcode == DIRTY_EVICT_OP)) begin
        $fwrite(cache_top_trk,"%t     CACHE_DIRTY_EVICT %h       %h         %h     %h      %h \n",
        $realtime, 
        cache2fm_req_q3.address, 
        cache2fm_req_q3.tq_id, 
        cache2fm_req_q3.address[MSB_TAG:LSB_TAG] , 
        cache2fm_req_q3.address[MSB_SET:LSB_SET], 
        cache2fm_req_q3.data);
    end
    if(cache2fm_req_q3.valid && (cache2fm_req_q3.opcode == FILL_REQ_OP)) begin
        $fwrite(cache_top_trk,"%t     CACHE_FILL_REQ    %h       %h         %h     %h      ( -- read request -- ) \n",
        $realtime, 
        cache2fm_req_q3.address, 
        cache2fm_req_q3.tq_id, 
        cache2fm_req_q3.address[MSB_TAG:LSB_TAG] , 
        cache2fm_req_q3.address[MSB_SET:LSB_SET]);
    end
    if(fm2cache_rd_rsp.valid) begin
        $fwrite(cache_top_trk,"%t     FM_FILL_RSP     (see tq_id)   %h        ----   ----     %h_%h_%h_%h \n",
        $realtime, 
        fm2cache_rd_rsp.tq_id, 
        fm2cache_rd_rsp.data[127:96], 
        fm2cache_rd_rsp.data[95:64], 
        fm2cache_rd_rsp.data[63:32], 
        fm2cache_rd_rsp.data[31:0]);
    end

//==================================================
// tracker on cache Pipe IO
//==================================================

 //===== Request Tracker =====   
    if(cache.cache_pipe_wrap.pipe_lu_req_q1.valid) begin
        $fwrite(cache_pipe_io_trk,"%t      Request   %-7s    %h        %h        %h         %h        %h      %h\n",
        $realtime,
        cache.cache_pipe_wrap.pipe_lu_req_q1.lu_op.name(), 
        cache.cache_pipe_wrap.pipe_lu_req_q1.tq_id, 
        cache.cache_pipe_wrap.pipe_lu_req_q1.address, 
        cache.cache_pipe_wrap.pipe_lu_req_q1.rd_indication,
        cache.cache_pipe_wrap.pipe_lu_req_q1.wr_indication,
        cache.cache_pipe_wrap.pipe_lu_req_q1.data,
        cache.cache_pipe_wrap.pipe_lu_req_q1.cl_data);  

    end

 //===== Response Tracker =====   
    if(cache.cache_pipe_wrap.pipe_lu_rsp_q3.valid) begin
        $fwrite(cache_pipe_io_trk,"%t      Response  %-7s    %h        %h      (---lu resp---)         %-4h       %h\n",
        $realtime,
        cache.cache_pipe_wrap.pipe_lu_rsp_q3.lu_op.name(),
        cache.cache_pipe_wrap.pipe_lu_rsp_q3.tq_id,
        cache.cache_pipe_wrap.pipe_lu_rsp_q3.address,
        cache.cache_pipe_wrap.pipe_lu_rsp_q3.lu_result.name(), 
        cache.cache_pipe_wrap.pipe_lu_rsp_q3.cl_data);     
    end


// //==================================================
// // tracker on Pipe Stages
// //==================================================
if(cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.lu_valid) begin
      $fwrite(cache_pipe_stages_trk,"%t   %-7s  %h    {%h,%h,%h,%h}   %h     %h       %h       %h     %h      %h      %h   {%h,%h,%h,%h}     {%h,%h,%h,%h}      {%h,%h,%h,%h}    {%h,%h,%h,%h}     {%h,%h,%h,%h}       %h       %h        %h         %h      %h\n",
      $realtime,
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.lu_op.name(),
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.lu_tq_id,
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_mru[0],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_mru[1],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_mru[2],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_mru[3],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.hit,
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.miss,
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.mb_hit_cancel, 
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.lu_tag,
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.lu_set,
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.lu_offset,
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.data,
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_valid[0],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_valid[1],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_valid[2],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_valid[3],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_modified[0],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_modified[1],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_modified[2],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_modified[3],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_tags[0],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_tags[1],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_tags[2],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_tags[3],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_victim[0],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_victim[1],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_victim[2],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_victim[3],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_hit[0],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_hit[1],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_hit[2],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.set_ways_hit[3],
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.fill_modified,
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.fill_rd,
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.dirty_evict,
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.data_array_address,
      cache.cache_pipe_wrap.cache_pipe.cache_pipe_lu_q2.cl_data
      );     
  end
// //==================================================
// // tracker on TQ
// //==================================================
    for (int i=0; i< NUM_TQ_ENTRY; ++i) begin
        if ((cache.cache_tq.tq_state[i] != cache.cache_tq.next_tq_state[i]) ||
             ((cache.cache_tq.tq_state[i] != S_IDLE) &&  core2cache_req.valid && (cache.cache_tq.rd_req_hit_mb[i] || cache.cache_tq.wr_req_hit_mb[i]) )
             ) begin
        //$fwrite(cache_tq_trk,"%t    %-15s     %h       %h       %h              %h           %h       %h\n",
        $fwrite(cache_tq_trk,"%t Entry[%1d]  %-15s   %h       %h       %h      %h     %h            %h              \n",
        $realtime,
        i,
        cache.cache_tq.next_tq_state              [i].name,     
        cache.cache_tq.next_tq_rd_indication      [i],     
        cache.cache_tq.next_tq_wr_indication      [i],         
        cache.cache_tq.next_tq_cl_address         [i],
        cache.cache_tq.next_tq_merge_buffer_data  [i],      
        cache.cache_tq.next_tq_cl_word_offset     [i],     
        cache.cache_tq.next_tq_reg_id             [i],
        //cache.cache_tq.any_rd_hit_mb,
        //cache.cache_tq.any_wr_hit_mb
        );


        end
    end    


//==================================================
// tracker of reference model - core<->cache
//==================================================
    if(core2cache_req.valid && (core2cache_req.opcode == RD_OP )) begin
        $fwrite(cache_ref_gold_trk,"     CORE_RD_REQ       %h       %h        %h     %h      ( -- read request -- ) \n",
        core2cache_req.address, 
        core2cache_req.reg_id, 
        core2cache_req.address[MSB_TAG:LSB_TAG] , 
        core2cache_req.address[MSB_SET:LSB_SET]);      
    end
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
    if(core2cache_req.valid && (core2cache_req.opcode == RD_OP )) begin
        $fwrite(cache_ref_trk,"     CORE_RD_REQ       %h       %h        %h     %h      ( -- read request -- ) \n",
        core2cache_req.address, 
        core2cache_req.reg_id, 
        core2cache_req.address[MSB_TAG:LSB_TAG] , 
        core2cache_req.address[MSB_SET:LSB_SET]);      
    end
    if(cache2core_rsp.valid) begin
        $fwrite(cache_ref_trk,"     CACHE_RD_RSP      %h       %h        %h     %h      %h \n",
        cache2core_rsp.address, 
        cache2core_rsp.reg_id, 
        cache2core_rsp.address[MSB_TAG:LSB_TAG] , 
        cache2core_rsp.address[MSB_SET:LSB_SET], 
        cache2core_rsp.data);
    end


end //always(posedge)
