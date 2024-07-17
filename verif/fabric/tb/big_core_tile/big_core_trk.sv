integer trk_tile_1_1_input;
initial begin: trk_tile_1_1_input_gen
    $timeformat(-9, 1, " ", 6);
    trk_tile_1_1_input = $fopen({"../../../target/fabric/tests/",test_name,"/trk_tile_1_1_input.log"},"w");
    $fwrite(trk_tile_1_1_input,"---------------------------------------------------------\n");
    $fwrite(trk_tile_1_1_input,"Time  | requestor_id |  opcode | address  |   data   | \n");
    $fwrite(trk_tile_1_1_input,"---------------------------------------------------------\n");  
end

always_ff @(posedge clk) begin
    if(fabric_big_cores.col[1].row[1].big_core_tile_ins.big_core_top.big_core_mem_wrap.InFabricValidQ503H) begin
        $fwrite(trk_tile_1_1_input,"%t|    %h       |  %s     | %h |  %h  | \n", $realtime, 
                                                fabric_big_cores.col[1].row[1].big_core_tile_ins.big_core_top.big_core_mem_wrap.InFabricQ503H.requestor_id,
                                                fabric_big_cores.col[1].row[1].big_core_tile_ins.big_core_top.big_core_mem_wrap.InFabricQ503H.opcode,
                                                fabric_big_cores.col[1].row[1].big_core_tile_ins.big_core_top.big_core_mem_wrap.InFabricQ503H.address,
                                                fabric_big_cores.col[1].row[1].big_core_tile_ins.big_core_top.big_core_mem_wrap.InFabricQ503H.data
                                                
                                                );
    end
end
    
