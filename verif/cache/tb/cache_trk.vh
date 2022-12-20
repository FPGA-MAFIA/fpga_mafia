
integer cache_trk;
integer cache_pipe_trk;
initial begin
    $timeformat(-12, 1, "", 6);
    cache_trk      = $fopen({"../../target/cache/cache_trk.log"},"w");
    cache_pipe_trk = $fopen({"../../target/cache/cache_pipe_trk.log"},"w");
end

//==================================================
// tracker of the Cache Top Level Interface
//==================================================
always @(posedge clk) begin
    if(core2cache_req.valid && (core2cache_req.opcode == RD_OP )) begin
        $fwrite(cache_trk,"%t) RD_REQ  | address: %h | REG_ID: %h -> tag: %h | set: %h | data: ( -- read request -- ) \n",$realtime, core2cache_req.address, core2cache_req.reg_id, core2cache_req.address[MSB_TAG:LSB_TAG] , core2cache_req.address[MSB_SET:LSB_SET]);      
    end
    if(core2cache_req.valid && (core2cache_req.opcode == WR_OP )) begin
        $fwrite(cache_trk,"%t) WR_REQ  | address: %h | REG_ID: %h -> tag: %h | set: %h | data: %h \n",$realtime, core2cache_req.address, core2cache_req.reg_id, core2cache_req.address[MSB_TAG:LSB_TAG] , core2cache_req.address[MSB_SET:LSB_SET],core2cache_req.data);      
    end
    if(cache2core_rsp.valid) begin
        $fwrite(cache_trk,"%t) RD_RSP  | address: %h | REG_ID: %h -> tag: %h | set: %h | data: %h \n",$realtime, cache2core_rsp.address, cache2core_rsp.reg_id, cache2core_rsp.address[MSB_TAG:LSB_TAG] , cache2core_rsp.address[MSB_SET:LSB_SET], cache2core_rsp.data);
    end
end

//==================================================
// tracker on cache Pipe IO
//==================================================
always @(posedge clk) begin
    if(cache.cache_pipe_wrap.pipe_lu_req_q1.valid && (cache.cache_pipe_wrap.pipe_lu_req_q1.lu_op == WR_LU )) begin
        $fwrite(cache_pipe_trk,"%t) WR_LU  | address: %h | data:  %h\n",
        $realtime, 
        cache.cache_pipe_wrap.pipe_lu_req_q1.address, 
        cache.cache_pipe_wrap.pipe_lu_req_q1.cl_data);      
    end
end

