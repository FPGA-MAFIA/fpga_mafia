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



integer mem_ss_top_trk;
integer mem_ss_ref_gold_trk;
integer mem_ss_ref_trk;
initial begin
    if ($value$plusargs ("STRING=%s", test_name))
        $display("creating tracker in test directory: target/cache/tests/%s", test_name);
    $timeformat(-12, 0, "", 6);
    
    mem_ss_top_trk      = $fopen({"../../../target/mem_ss/tests/",test_name,"/mem_ss_top_trk.log"},"w");
    $fwrite(mem_ss_top_trk, "==================================================================================\n");
    $fwrite(mem_ss_top_trk, "                      MEM_SS TOP TRACKER  -  Test: ",test_name,"\n");
    $fwrite(mem_ss_top_trk, "==================================================================================\n");
    $fwrite(mem_ss_top_trk,"-----------------------------------------------------------------------------------\n");
    $fwrite(mem_ss_top_trk," Time  ||  OPCODE        || address ||REG/TQ_ID|| tag  || Set ||    Data \n");
    $fwrite(mem_ss_top_trk,"-----------------------------------------------------------------------------------\n");


    mem_ss_ref_gold_trk = $fopen({"../../../target/mem_ss/tests/",test_name,"/mem_ss_ref_gold_trk.log"},"w");
    mem_ss_ref_trk      = $fopen({"../../../target/mem_ss/tests/",test_name,"/mem_ss_ref_trk.log"},"w");
end

always @(posedge clk) begin
//==================================================
// tracker of the mem_ss Top Level Interface
//==================================================
    if(dmem_core2cache_req.valid && (dmem_core2cache_req.opcode == RD_OP )) begin
        $fwrite(mem_ss_top_trk,"%t     CORE_RD_REQ       %h       %h        %h     %h      ( -- read request -- ) \n",
        $realtime, 
        dmem_core2cache_req.address, 
        dmem_core2cache_req.reg_id, 
        dmem_core2cache_req.address[MSB_TAG:LSB_TAG] , 
        dmem_core2cache_req.address[MSB_SET:LSB_SET]);      
    end
    if(dmem_core2cache_req.valid && (dmem_core2cache_req.opcode == WR_OP )) begin
        $fwrite(mem_ss_top_trk,"%t     CORE_WR_REQ       %h       %h        %h     %h      %h \n",
        $realtime, 
        dmem_core2cache_req.address, 
        dmem_core2cache_req.reg_id, 
        dmem_core2cache_req.address[MSB_TAG:LSB_TAG] , 
        dmem_core2cache_req.address[MSB_SET:LSB_SET],
        dmem_core2cache_req.data);      
    end
    if(dmem_cache2core_rsp.valid) begin
        $fwrite(mem_ss_top_trk,"%t     CACHE_RD_RSP      %h       %h        %h     %h      %h \n",
        $realtime, 
        dmem_cache2core_rsp.address, 
        dmem_cache2core_rsp.reg_id, 
        dmem_cache2core_rsp.address[MSB_TAG:LSB_TAG] , 
        dmem_cache2core_rsp.address[MSB_SET:LSB_SET], 
        dmem_cache2core_rsp.data);
    end

    if(cl_req_to_sram.valid && (cl_req_to_sram.opcode == DIRTY_EVICT_OP)) begin
        $fwrite(mem_ss_top_trk,"%t     CACHE_DIRTY_EVICT %h       %h         %h     %h      %h_%h_%h_%h  \n",
        $realtime, 
        cl_req_to_sram.address, 
        cl_req_to_sram.tq_id, 
        cl_req_to_sram.address[MSB_TAG:LSB_TAG] , 
        cl_req_to_sram.address[MSB_SET:LSB_SET], 
        cl_req_to_sram.data[127:96],
        cl_req_to_sram.data[95:64],
        cl_req_to_sram.data[63:32],
        cl_req_to_sram.data[31:0]
        );
    end

    if(cl_req_to_sram.valid && (cl_req_to_sram.opcode == FILL_REQ_OP)) begin
        $fwrite(mem_ss_top_trk,"%t     CACHE_FILL_REQ    %h       %h         %h     %h      ( -- read request -- ) \n",
        $realtime, 
        cl_req_to_sram.address, 
        cl_req_to_sram.tq_id, 
        cl_req_to_sram.address[MSB_TAG:LSB_TAG] , 
        cl_req_to_sram.address[MSB_SET:LSB_SET]);
    end
    if(cl_rsp_from_sram.valid) begin
        $fwrite(mem_ss_top_trk,"%t     FM_FILL_RSP       %h              ----   ----     %h_%h_%h_%h \n",
        $realtime, 
        cl_rsp_from_sram.address, 
        cl_rsp_from_sram.data[127:96], 
        cl_rsp_from_sram.data[95:64], 
        cl_rsp_from_sram.data[63:32], 
        cl_rsp_from_sram.data[31:0]);
    end


//==================================================
// tracker of reference model - core<->cache
//==================================================
    if(dmem_ref_cache2core_rsp.valid) begin
        $fwrite(mem_ss_ref_gold_trk,"     CACHE_RD_RSP      %h       %h        %h     %h      %h \n",
        dmem_ref_cache2core_rsp.address, 
        dmem_ref_cache2core_rsp.reg_id, 
        dmem_ref_cache2core_rsp.address[MSB_TAG:LSB_TAG] , 
        dmem_ref_cache2core_rsp.address[MSB_SET:LSB_SET], 
        dmem_ref_cache2core_rsp.data);
    end
//==================================================
// tracker of reference model - core<->cache
//==================================================
    if(dmem_cache2core_rsp.valid) begin
        $fwrite(mem_ss_ref_trk,"     CACHE_RD_RSP      %h       %h        %h     %h      %h \n",
        dmem_cache2core_rsp.address, 
        dmem_cache2core_rsp.reg_id, 
        dmem_cache2core_rsp.address[MSB_TAG:LSB_TAG] , 
        dmem_cache2core_rsp.address[MSB_SET:LSB_SET], 
        dmem_cache2core_rsp.data);
    end


end //always(posedge)
