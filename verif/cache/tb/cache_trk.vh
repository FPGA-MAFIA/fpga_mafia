//-----------------------------------------------------------------------------
// Title            : cache_trk
// Project          : riscv_manycore_mesh_fpga
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
initial begin
    $timeformat(-12, 1, "", 6);
    cache_top_trk      = $fopen({"../../target/cache/cache_top_trk.log"},"w");
    $fwrite(cache_top_trk,"-----------------------------------------------------------------------\n");
    $fwrite(cache_top_trk," Time  ||  OPCODE  ||   Adress  ||  REG_ID -> tag  || Set ||    Data \n");
    $fwrite(cache_top_trk,"-----------------------------------------------------------------------\n");

    cache_pipe_trk = $fopen({"../../target/cache/cache_pipe_trk.log"},"w");
    $fwrite(cache_pipe_trk,"-----------------------------------------------------------------------\n");
    $fwrite(cache_pipe_trk,"  Time  ||  OPCODE  ||  Adress  ||    Data\n");
    $fwrite(cache_pipe_trk,"-----------------------------------------------------------------------\n");
end

//==================================================
// tracker of the Cache Top Level Interface
//==================================================
always @(posedge clk) begin
    if(core2cache_req.valid && (core2cache_req.opcode == RD_OP )) begin
        $fwrite(cache_top_trk,"%t     RD_REQ      %h           %h -> %h       %h      ( -- read request -- ) \n",$realtime, core2cache_req.address, core2cache_req.reg_id, core2cache_req.address[MSB_TAG:LSB_TAG] , core2cache_req.address[MSB_SET:LSB_SET]);      
    end
    if(core2cache_req.valid && (core2cache_req.opcode == WR_OP )) begin
        $fwrite(cache_top_trk,"%t     WR_REQ      %h           %h -> %h       %h      %h \n",$realtime, core2cache_req.address, core2cache_req.reg_id, core2cache_req.address[MSB_TAG:LSB_TAG] , core2cache_req.address[MSB_SET:LSB_SET],core2cache_req.data);      
    end
    if(cache2core_rsp.valid) begin
        $fwrite(cache_top_trk,"%t     RD_RSP      %h           %h -> %h       %h      %h \n",$realtime, cache2core_rsp.address, cache2core_rsp.reg_id, cache2core_rsp.address[MSB_TAG:LSB_TAG] , cache2core_rsp.address[MSB_SET:LSB_SET], cache2core_rsp.data);
    end
end

//==================================================
// tracker on cache Pipe IO
//==================================================
always @(posedge clk) begin

 //===== Request Tracker =====   
    if(cache.cache_pipe_wrap.pipe_lu_req_q1.valid) begin
        $fwrite(cache_pipe_trk,"%t      %0s       %h        %h\n",
        $realtime,
        cache.cache_pipe_wrap.pipe_lu_req_q1.lu_op.name(), 
        cache.cache_pipe_wrap.pipe_lu_req_q1.address, 
        cache.cache_pipe_wrap.pipe_lu_req_q1.cl_data);     
    end

 //===== Response Tracker =====   
    if(cache.cache_pipe_wrap.pipe_lu_rsp_q3.valid) begin
        $fwrite(cache_pipe_trk,"%t      %0s       %h        %h\n",
        $realtime,
        cache.cache_pipe_wrap.pipe_lu_rsp_q3.lu_op.name(), 
        cache.cache_pipe_wrap.pipe_lu_rsp_q3.address, 
        cache.cache_pipe_wrap.pipe_lu_rsp_q3.cl_data);     
    end

 //===== FM Request Tracker =====   
    if(cache.cache_pipe_wrap.cache2fm_wr_req_q3.valid) begin
        $fwrite(cache_pipe_trk,"%t      FM WRITE Request        %h        %h\n",
        $realtime,
        cache.cache_pipe_wrap.cache2fm_wr_req_q3.address, 
        cache.cache_pipe_wrap.cache2fm_wr_req_q3.cl_data);     
    end

    if(cache.cache_pipe_wrap.cache2fm_rd_req_q3.valid) begin
        $fwrite(cache_pipe_trk,"%t      FM READ Request       %h        %h\n",
        $realtime,
        cache.cache_pipe_wrap.cache2fm_rd_req_q3.address, 
        cache.cache_pipe_wrap.cache2fm_rd_req_q3.cl_data);     
    end


end
