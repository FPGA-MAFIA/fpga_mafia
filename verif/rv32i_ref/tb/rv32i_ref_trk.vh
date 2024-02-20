integer trk_ref_memory_access;
initial begin: trk_rf_memory_access_gen
    #1
    trk_ref_memory_access = $fopen({"../../../target/rv32i_ref/tests/",test_name,"/trk_ref_memory_access.log"},"w");
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

//==================================================================================================

integer trk_instret_time;
initial begin: trk_instret_time_gen
    $timeformat(-11, 1, ":", 8);
    trk_instret_time = $fopen({"../../../target/rv32i_ref/tests/",test_name,"/trk_instret_time.log"},"w");
    $fwrite(trk_instret_time,"---------------------------------------------------------\n");
    $fwrite(trk_instret_time,"Time     |  PC   | INSTRET  | inst_type \n");
    $fwrite(trk_instret_time,"---------------------------------------------------------\n");  
end

always_ff @(posedge Clk) begin
    if(rv32i_ref.run) begin
        $fwrite(trk_instret_time,"%t | %8h | %8h | %s    \n", $realtime, rv32i_ref.pc, rv32i_ref.instruction, rv32i_ref.instr_type.name());
    end
end

//==================================================================================================
//
//integer trk_instret;
//initial begin: trk_instret_gen
//    $timeformat(-11, 1, ":", 8);
//    trk_instret= $fopen({"../../../target/rv32i_ref/tests/",test_name,"/trk_instret.log"},"w");
//    $fwrite(trk_instret,"---------------------------------------------------------\n");
//    $fwrite(trk_instret," PC   | INSTRET  |\n");
//    $fwrite(trk_instret,"---------------------------------------------------------\n");  
//end
//
//always_ff @(posedge Clk) begin
//    if(rv32i_ref.run) begin
//        $fwrite(trk_instret," %8h | %8h \n", rv32i_ref.pc, rv32i_ref.instruction);
//    end
//end


//==================================================================================================
integer trk_reg_write;
initial begin: trk_inst_gen
    trk_reg_write = $fopen({"../../../target/rv32i_ref/tests/",test_name,"/trk_reg_write_ref.log"},"w");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");
    $fwrite(trk_reg_write," Time | PC |Instruction|  ENUM |reg_dst|  X0   ,  X1   ,  X2   ,  X3    ,  X4    ,  X5    ,  X6    ,  X7    ,  X8    ,  X9    ,  X10    , X11    , X12    , X13    , X14    , X15    , X16    , X17    , X18    , X19    , X20    , X21    , X22    , X23    , X24    , X25    , X26    , X27    , X28    , X29    , X30    , X31 \n");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");  
end

always_ff @(posedge Clk ) begin
        $fwrite(trk_reg_write,"%6d | %4h |  %8h |%7s | %2d | %8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h \n"
        ,$time,            
                           rv32i_ref.pc,
                           rv32i_ref.instruction,
                           rv32i_ref.instr_type,
                           rv32i_ref.rd,
                           rv32i_ref.regfile[0],
                           rv32i_ref.regfile[1],
                           rv32i_ref.regfile[2],
                           rv32i_ref.regfile[3],
                           rv32i_ref.regfile[4],
                           rv32i_ref.regfile[5],
                           rv32i_ref.regfile[6],
                           rv32i_ref.regfile[7],
                           rv32i_ref.regfile[8],
                           rv32i_ref.regfile[9],
                           rv32i_ref.regfile[10],
                           rv32i_ref.regfile[11],
                           rv32i_ref.regfile[12],
                           rv32i_ref.regfile[13],
                           rv32i_ref.regfile[14],
                           rv32i_ref.regfile[15],
                           rv32i_ref.regfile[16],
                           rv32i_ref.regfile[17],
                           rv32i_ref.regfile[18],
                           rv32i_ref.regfile[19],
                           rv32i_ref.regfile[20],
                           rv32i_ref.regfile[21],
                           rv32i_ref.regfile[22],
                           rv32i_ref.regfile[23],
                           rv32i_ref.regfile[24],
                           rv32i_ref.regfile[25],
                           rv32i_ref.regfile[26],
                           rv32i_ref.regfile[27],
                           rv32i_ref.regfile[28],
                           rv32i_ref.regfile[29],
                           rv32i_ref.regfile[30],
                           rv32i_ref.regfile[31]
                           );
end

