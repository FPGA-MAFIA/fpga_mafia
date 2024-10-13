integer trk_ref_memory_access;
initial begin: trk_rf_memory_access_gen
    #1
    trk_ref_memory_access = $fopen({"../../../target/big_core_cachel1/tests/",test_name,"/trk_ref_memory_access.log"},"w");
    $fwrite(trk_ref_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_ref_memory_access,"Time  |  PC   | Opcode  | Address  | Data  |\n");
    $fwrite(trk_ref_memory_access,"---------------------------------------------------------\n");  
end

always @(posedge Clk) begin : memory_ref_access_print
    if(rv32i_ref.DMemWrEn) begin
        $fwrite(trk_ref_memory_access,"%t | %8h | write |%8h |%8h \n", $realtime, rv32i_ref.pc, rv32i_ref.mem_wr_addr, rv32i_ref.data_rd2);
    end
    if(rv32i_ref.DMemRdEn) begin
        $fwrite(trk_ref_memory_access,"%t | %8h | read  |%8h |%8h \n", $realtime, rv32i_ref.pc, rv32i_ref.mem_rd_addr, rv32i_ref.next_regfile[rv32i_ref.rd]);
    end
end

// new tracker for all writes to the register file 
// track PC, register destination, and the data written to the register
integer trk_ref_reg_write_data;

initial begin: trk_ref_reg_write_data_gen
#1
    trk_ref_reg_write_data = $fopen({"../../../target/big_core_cachel1/tests/",test_name,"/trk_ref_reg_write_data.log"},"w");
    $fwrite(trk_ref_reg_write_data,"---------------------------------------------------------\n");
    $fwrite(trk_ref_reg_write_data," PC | reg_dst | data \n");
    $fwrite(trk_ref_reg_write_data,"---------------------------------------------------------\n");  
end

always_ff @(posedge Clk ) begin
    if(rv32i_ref.run && rv32i_ref.reg_wr_en) begin
        $fwrite(trk_ref_reg_write_data,"%4h | %2d | %8h \n"
        ,rv32i_ref.pc
        ,rv32i_ref.rd
        ,rv32i_ref.reg_wr_data
        );
    end
end
