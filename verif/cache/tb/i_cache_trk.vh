//-----------------------------------------------------------------------------
// Title            : i_cache_trk
// Project          : fpga_mafia
//-----------------------------------------------------------------------------
// File             : i_cache_trk.vh
// Original Author  : Noam Sabban
// Code Owner       : 
// Created          : 12/2022
//-----------------------------------------------------------------------------
// Description :
// Create the differents Trackers for our i_Cache   
//-----------------------------------------------------------------------------





integer i_cache_top_trk;
integer i_cache_pipe_io_trk;
integer i_cache_tq_trk;
integer cache_ref_gold_trk;
integer cache_ref_trk;
integer i_cache_pipe_stages_trk;

initial begin
    if ($value$plusargs ("STRING=%s", test_name))
        $display("creating tracker in test directory: target/cache/tests/%s", test_name);
    $timeformat(-12, 0, "", 6);
    
    i_cache_top_trk      = $fopen({"../../../target/cache/tests/",test_name,"/i_cache_top_trk.log"},"w");
    $fwrite(i_cache_top_trk, "==================================================================================\n");
    $fwrite(i_cache_top_trk, "                      I_CACHE TOP TRACKER  -  Test: ",test_name,"\n");
    $fwrite(i_cache_top_trk, "==================================================================================\n");
    $fwrite(i_cache_top_trk,"-----------------------------------------------------------------------------------\n");
    $fwrite(i_cache_top_trk," Time  ||  OPCODE        || address ||REG/TQ_ID|| tag  || Set ||    Data \n");
    $fwrite(i_cache_top_trk,"-----------------------------------------------------------------------------------\n");

    i_cache_pipe_io_trk = $fopen({"../../../target/cache/tests/",test_name,"/i_cache_pipe_io_trk.log"},"w");
    $fwrite(i_cache_pipe_io_trk,"==========================================================================================\n");
    $fwrite(i_cache_pipe_io_trk,"                      I_CACHE PIPE I/O TRACKER  -  Test: ",test_name,"\n"); 
    $fwrite(i_cache_pipe_io_trk,"==========================================================================================\n");
    $fwrite(i_cache_pipe_io_trk,"------------------------------------------------------------------------------------------\n");
    $fwrite(i_cache_pipe_io_trk,"  Time  ||REQ/RSP||  OPCODE  || TQ ID ||  address  || rd ind || Data/Result ||   CL־Data \n");
    $fwrite(i_cache_pipe_io_trk,"------------------------------------------------------------------------------------------\n");

    i_cache_pipe_stages_trk = $fopen({"../../../target/cache/tests/",test_name,"/i_cache_pipe_stages_trk.log"},"w");
    $fwrite(i_cache_pipe_stages_trk,"==========================================================================================================================================================================================================================================================================\n");
    $fwrite(i_cache_pipe_stages_trk,"                                                               I_CACHE PIPE STAGES TRACKER  -  Test: ",test_name,"\n"); 
    $fwrite(i_cache_pipe_stages_trk,"==========================================================================================================================================================================================================================================================================\n");
    $fwrite(i_cache_pipe_stages_trk,"-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n");
    $fwrite(i_cache_pipe_stages_trk,"Time || OPCODE || TQ || s_w_mru || hit|miss || mb_hit || tag ||set || offset ||   Data  || s_w_valid ||  s_w_tags  ||  s_w_victim ||  s_w_hit  || fill ||           cl_data_q3               ||  data array|| cl_data          \n");
    $fwrite(i_cache_pipe_stages_trk,"                  ID                           cancel                                                                                              rd                                             address                                                                \n");
    $fwrite(i_cache_pipe_stages_trk,"-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n");  

    i_cache_tq_trk      = $fopen({"../../../target/cache/tests/",test_name,"/i_cache_tq_trk.log"},"w");
    $fwrite(i_cache_tq_trk,"====================================================================================================================\n");
    $fwrite(i_cache_tq_trk,"                      I_CACHE TQ TRACKER  -  Test: ",test_name,"\n");
    $fwrite(i_cache_tq_trk,"====================================================================================================================\n");
    $fwrite(i_cache_tq_trk,"--------------------------------------------------------------------------------------------------------------------\n");
    $fwrite(i_cache_tq_trk," Time ||ENTRY||    State      ||  RD  || cl adress ||             MB DATA            || REG ID  || cl word offset   rd hit\n");
    $fwrite(i_cache_tq_trk,"---------------------------------------------------------------------------------------------------------------------\n ");

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
    if(imem_core2cache_req.valid && (imem_core2cache_req.opcode == RD_OP )) begin
        $fwrite(i_cache_top_trk,"%t     CORE_RD_REQ       %h       %h        %h     %h      ( -- read request -- ) \n",
        $realtime, 
        imem_core2cache_req.address, 
        imem_core2cache_req.reg_id, 
        imem_core2cache_req.address[MSB_TAG:LSB_TAG] , 
        imem_core2cache_req.address[MSB_SET:LSB_SET]);      
    end
    if(imem_core2cache_req.valid && (imem_core2cache_req.opcode == WR_OP )) begin
        $fwrite(i_cache_top_trk,"%t     CORE_WR_REQ       %h       %h        %h     %h      %h \n",
        $realtime, 
        imem_core2cache_req.address, 
        imem_core2cache_req.reg_id, 
        imem_core2cache_req.address[MSB_TAG:LSB_TAG] , 
        imem_core2cache_req.address[MSB_SET:LSB_SET],
        imem_core2cache_req.data);      
    end
    if(imem_cache2core_rsp.valid) begin
        $fwrite(i_cache_top_trk,"%t     CACHE_RD_RSP      %h       %h        %h     %h      %h \n",
        $realtime, 
        imem_cache2core_rsp.address, 
        imem_cache2core_rsp.reg_id, 
        imem_cache2core_rsp.address[MSB_TAG:LSB_TAG] , 
        imem_cache2core_rsp.address[MSB_SET:LSB_SET], 
        imem_cache2core_rsp.data);
    end
    if(imem_cache2fm_req_q3.valid && (imem_cache2fm_req_q3.opcode == DIRTY_EVICT_OP)) begin
        $fwrite(i_cache_top_trk,"%t     CACHE_DIRTY_EVICT %h       %h         %h     %h      %h_%h_%h_%h  \n",
        $realtime, 
        imem_cache2fm_req_q3.address, 
        imem_cache2fm_req_q3.tq_id, 
        imem_cache2fm_req_q3.address[MSB_TAG:LSB_TAG] , 
        imem_cache2fm_req_q3.address[MSB_SET:LSB_SET], 
        imem_cache2fm_req_q3.data[127:96],
        imem_cache2fm_req_q3.data[95:64],
        imem_cache2fm_req_q3.data[63:32],
        imem_cache2fm_req_q3.data[31:0]
        );
    end
    if(imem_cache2fm_req_q3.valid && (imem_cache2fm_req_q3.opcode == FILL_REQ_OP)) begin
        $fwrite(i_cache_top_trk,"%t     CACHE_FILL_REQ    %h       %h         %h     %h      ( -- read request -- ) \n",
        $realtime, 
        imem_cache2fm_req_q3.address, 
        imem_cache2fm_req_q3.tq_id, 
        imem_cache2fm_req_q3.address[MSB_TAG:LSB_TAG] , 
        imem_cache2fm_req_q3.address[MSB_SET:LSB_SET]);
    end
    if(fm2cache_rd_rsp.valid) begin
        $fwrite(i_cache_top_trk,"%t     FM_FILL_RSP      %h               ----   ----     %h_%h_%h_%h \n",
        $realtime, 
        fm2cache_rd_rsp.address, 
        fm2cache_rd_rsp.data[127:96], 
        fm2cache_rd_rsp.data[95:64], 
        fm2cache_rd_rsp.data[63:32], 
        fm2cache_rd_rsp.data[31:0]);
    end

//==================================================
// tracker on i_cache Pipe IO
//==================================================

 //===== Request Tracker =====   
    if(i_cache.i_cache_pipe_wrap.pipe_lu_req_q1.valid) begin
        $fwrite(i_cache_pipe_io_trk,"%t      Request   %-7s    %h        %h       %h      %h\n",
        $realtime,
        i_cache.i_cache_pipe_wrap.pipe_lu_req_q1.lu_op.name(), 
        i_cache.i_cache_pipe_wrap.pipe_lu_req_q1.tq_id, 
        i_cache.i_cache_pipe_wrap.pipe_lu_req_q1.address, 
        i_cache.i_cache_pipe_wrap.pipe_lu_req_q1.rd_indication,
        i_cache.i_cache_pipe_wrap.pipe_lu_req_q1.data,
        i_cache.i_cache_pipe_wrap.pipe_lu_req_q1.cl_data);  

    end

 //===== Response Tracker =====   
    if(i_cache.i_cache_pipe_wrap.pipe_lu_rsp_q3.valid) begin
        $fwrite(i_cache_pipe_io_trk,"%t      Response  %-7s    %h        %h      (---lu resp---)         %-4h       %h\n",
        $realtime,
        i_cache.i_cache_pipe_wrap.pipe_lu_rsp_q3.lu_op.name(),
        i_cache.i_cache_pipe_wrap.pipe_lu_rsp_q3.tq_id,
        i_cache.i_cache_pipe_wrap.pipe_lu_rsp_q3.address,
        i_cache.i_cache_pipe_wrap.pipe_lu_rsp_q3.lu_result.name(), 
        i_cache.i_cache_pipe_wrap.pipe_lu_rsp_q3.cl_data);     
    end


// //==================================================
// // tracker on Pipe Stages
// //==================================================
if(i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.lu_valid) begin
      $fwrite(i_cache_pipe_stages_trk,"%t   %-7s  %h    {%h,%h,%h,%h}   %h     %h       %h       %h     %h      %h      %h   {%h,%h,%h,%h}      {%h,%h,%h,%h}    {%h,%h,%h,%h}     {%h,%h,%h,%h}        %h     %h    %h      %h\n",
      $realtime,
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.lu_op.name(),
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.lu_tq_id,
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_mru[0],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_mru[1],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_mru[2],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_mru[3],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.hit,
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.miss,
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.mb_hit_cancel, 
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.lu_tag,
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.lu_set,
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.lu_offset,
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.data,
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_valid[0],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_valid[1],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_valid[2],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_valid[3],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_tags[0],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_tags[1],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_tags[2],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_tags[3],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_victim[0],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_victim[1],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_victim[2],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_victim[3],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_hit[0],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_hit[1],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_hit[2],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.set_ways_hit[3],
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.fill_rd,
      i_cache.i_cache_pipe_wrap.pipe_lu_rsp_q3.cl_data,
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.data_array_address,
      i_cache.i_cache_pipe_wrap.i_cache_pipe.cache_pipe_lu_q2.cl_data
      );     
  end
// //==================================================
// // tracker on TQ
// //==================================================
    for (int i=0; i< NUM_TQ_ENTRY; ++i) begin
        if ((i_cache.i_cache_tq.tq_state[i] != i_cache.i_cache_tq.next_tq_state[i]) ||
             ((i_cache.i_cache_tq.tq_state[i] != S_IDLE) &&  imem_core2cache_req.valid && i_cache.i_cache_tq.rd_req_hit_mb[i] )
             ) begin
        $fwrite(i_cache_tq_trk,"%t Entry[%1d]  %-15s   %h       %h       %h       %h            %h              \n",
        $realtime,
        i,
        i_cache.i_cache_tq.next_tq_state              [i].name,     
        i_cache.i_cache_tq.next_tq_rd_indication      [i],     
        i_cache.i_cache_tq.next_tq_cl_address         [i],
        i_cache.i_cache_tq.next_tq_merge_buffer_data  [i],      
        i_cache.i_cache_tq.next_tq_cl_word_offset     [i],     
        i_cache.i_cache_tq.next_tq_reg_id             [i]
        );


        end
    end    


//==================================================
// tracker of reference model - core<->i_cache
//==================================================
    if(imem_core2cache_req.valid && (imem_core2cache_req.opcode == RD_OP )) begin
        $fwrite(cache_ref_gold_trk,"     CORE_RD_REQ       %h       %h        %h     %h      ( -- read request -- ) \n",
        imem_core2cache_req.address, 
        imem_core2cache_req.reg_id, 
        imem_core2cache_req.address[MSB_TAG:LSB_TAG] , 
        imem_core2cache_req.address[MSB_SET:LSB_SET]);      
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
// tracker of reference model - core<->i_cache
//==================================================
    if(imem_core2cache_req.valid && (imem_core2cache_req.opcode == RD_OP )) begin
        $fwrite(cache_ref_trk,"     CORE_RD_REQ       %h       %h        %h     %h      ( -- read request -- ) \n",
        imem_core2cache_req.address, 
        imem_core2cache_req.reg_id, 
        imem_core2cache_req.address[MSB_TAG:LSB_TAG] , 
        imem_core2cache_req.address[MSB_SET:LSB_SET]);      
    end
    if(imem_cache2core_rsp.valid) begin
        $fwrite(cache_ref_trk,"     CACHE_RD_RSP      %h       %h        %h     %h      %h \n",
        imem_cache2core_rsp.address, 
        imem_cache2core_rsp.reg_id, 
        imem_cache2core_rsp.address[MSB_TAG:LSB_TAG] , 
        imem_cache2core_rsp.address[MSB_SET:LSB_SET], 
        imem_cache2core_rsp.data);
    end


end //always(posedge)
