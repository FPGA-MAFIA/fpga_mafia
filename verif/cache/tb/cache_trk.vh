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
integer cache_pipe_trk;
integer cache_tq_trk;

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

    cache_pipe_trk = $fopen({"../../../target/cache/tests/",test_name,"/cache_pipe_trk.log"},"w");
    $fwrite(cache_pipe_trk,"==========================================================================================\n");
    $fwrite(cache_pipe_trk,"                      CACHE PIPE TRACKER  -  Test: ",test_name,"\n"); 
    $fwrite(cache_pipe_trk,"==========================================================================================\n");
    $fwrite(cache_pipe_trk,"------------------------------------------------------------------------------------------\n");
    $fwrite(cache_pipe_trk,"  Time  ||  OPCODE  || TQ ID ||  address  || rd ind || wr ind || Data/Result ||   CL־Data \n");
    $fwrite(cache_pipe_trk,"------------------------------------------------------------------------------------------\n");

    cache_tq_trk      = $fopen({"../../../target/cache/tests/",test_name,"/cache_tq_trk.log"},"w");
    $fwrite(cache_tq_trk,"====================================================================================================================\n");
    $fwrite(cache_tq_trk,"                      CACHE TQ TRACKER  -  Test: ",test_name,"\n");
    $fwrite(cache_tq_trk,"====================================================================================================================\n");
    $fwrite(cache_tq_trk,"--------------------------------------------------------------------------------------------------------------------\n");
    //$fwrite(cache_tq_trk," Time  ||     State      ||  RD  ||  WR  || cl adress || cl word offset|| REG ID || MB DATA  \n");
    $fwrite(cache_tq_trk," Time ||ENTRY||    State      ||  RD  ||  WR  || cl adress ||             MB DATA            || REG ID  || cl word offset   \n");
    $fwrite(cache_tq_trk,"---------------------------------------------------------------------------------------------------------------------\n");

end

//==================================================
// tracker of the Cache Top Level Interface
//==================================================
always @(posedge clk) begin
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
        $fwrite(cache_top_trk,"%t  CACHE_DIRTY_EVICT   %h       %h        %h     %h      %h \n",
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
        $fwrite(cache_pipe_trk,"%t       %-7s    %h        %h        %h         %h        %h      %h\n",
        $realtime,
        cache.cache_pipe_wrap.pipe_lu_req_q1.lu_op.name(), 
        cache.cache_pipe_wrap.pipe_lu_req_q1.tq_id, 
        cache.cache_pipe_wrap.pipe_lu_req_q1.address, 
        cache.cache_pipe_wrap.pipe_lu_req_q1.rd_indication,
        cache.cache_pipe_wrap.pipe_lu_req_q1.wr_indication,
        cache.cache_pipe_wrap.pipe_lu_req_q1.data,
        cache.cache_pipe_wrap.pipe_lu_req_q1.cl_data,);  

    end

 //===== Response Tracker =====   
    if(cache.cache_pipe_wrap.pipe_lu_rsp_q3.valid) begin
        $fwrite(cache_pipe_trk,"%t      %-7s    %h        %h      (---lu resp---)         %-4h       %h\n",
        $realtime,
        cache.cache_pipe_wrap.pipe_lu_rsp_q3.lu_op.name(),
        cache.cache_pipe_wrap.pipe_lu_rsp_q3.tq_id,
        cache.cache_pipe_wrap.pipe_lu_rsp_q3.address,
        cache.cache_pipe_wrap.pipe_lu_rsp_q3.lu_result.name(), 
        cache.cache_pipe_wrap.pipe_lu_rsp_q3.cl_data);     
    end


// //==================================================
// // tracker on TQ
// //==================================================
    for (int i=0; i< NUM_TQ_ENTRY; ++i) begin
        if (cache.cache_tq.tq_state[i] != cache.cache_tq.next_tq_state[i]) begin
        //$fwrite(cache_tq_trk,"%t    %-15s     %h       %h       %h              %h           %h       %h\n",
        $fwrite(cache_tq_trk,"%t Entry[%1d]  %-15s   %h       %h       %h      %h     %h            %h\n",
        $realtime,
        i,
        cache.cache_tq.tq_state[i].name,     
        cache.cache_tq.tq_rd_indication      [i],     
        cache.cache_tq.tq_wr_indication      [i],         
        cache.cache_tq.tq_cl_address         [i],
        cache.cache_tq.tq_merge_buffer_data  [i],      
        cache.cache_tq.tq_cl_word_offset     [i],     
        cache.cache_tq.tq_reg_id             [i]
            
        );


        end
    end    

end //always(posedge)
