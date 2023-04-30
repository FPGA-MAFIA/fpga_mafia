//-----------------------------------------------------------------------------
// Title            : 
// Project          : fpga_mafia
//-----------------------------------------------------------------------------
// File             : .vh
// Original Author  : Daniel Kaufman
// Code Owner       : 
// Created          : 01/2023
//-----------------------------------------------------------------------------
// Description :
// this file contain the trakers for 
//-----------------------------------------------------------------------------


integer trk_alu;
initial begin: trk_alu_gen
    $timeformat(-9, 1, " ", 6);
    trk_alu = $fopen({"../../../target/sc_core/tests/",test_name,"/trk_alu.log"},"w");
    $fwrite(trk_alu,"-----------------------------------------------------------------------------\n");
    $fwrite(trk_alu,"Time    |    PC    | inst_op  | opcode |  AluIn1   |  AluIn2   | AluOut   |  \n");
    $fwrite(trk_alu,"-----------------------------------------------------------------------------\n");  

end
//tracker on ALU operations
always @(posedge Clk) begin : alu_print
    $fwrite(trk_alu,"%t  | %8h |  %-6s  | %-6s | %8h  | %8h  |%8h  | \n", $realtime,sc_core.Pc, sc_core.Opcode.name(), sc_core.CtrlAluOp.name(), sc_core.AluIn1, sc_core.AluIn2, sc_core.AluOut); // # FIXME
end

integer trk_inst;
initial begin: trk_inst_gen
    $timeformat(-9, 1, " ", 6);
    trk_inst = $fopen({"../../../target/sc_core/tests/",test_name,"/trk_inst.log"},"w");
    $fwrite(trk_inst,"----------------------------------------------------------------\n");
    $fwrite(trk_inst," Time  |   PC     | opcode  | ALU_OP | Instruction              |\n");
    $fwrite(trk_inst,"----------------------------------------------------------------\n");  

end
always @(posedge Clk) begin : inst_print
    $fwrite(trk_inst,"%t | %8h |  %-6s | %-6s |%7b_%5b_%5b_%3b_%5b_%7b | \n", $realtime,sc_core.Pc, sc_core.Opcode.name(), sc_core.CtrlAluOp.name(), sc_core.Instruction[31:25],sc_core.Instruction[24:20], sc_core.Instruction[19:15], sc_core.Instruction[14:12], sc_core.Instruction[11:7], sc_core.Instruction[6:0]);
end
integer trk_fetch;
initial begin: trk_fetch_gen
    $timeformat(-9, 1, " ", 6);
    trk_fetch = $fopen({"../../../target/sc_core/tests/",test_name,"/trk_fetch.log"},"w");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");
    $fwrite(trk_fetch," Time  | PC       | Funct3 | Funct7  | Opcode  |\n");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");  

end
always @(posedge Clk) begin : fetch_print
    $fwrite(trk_fetch,"%t | %8h |   %3b  | %7b | %-6s | \n", $realtime,sc_core.Pc, sc_core.Funct3, sc_core.Funct7, sc_core.Opcode.name()); // # FIXME
end



integer trk_memory_access;
initial begin: trk_memory_access_gen
    $timeformat(-12, 1, " ", 6);
    trk_memory_access = $fopen({"../../../target/sc_core/tests/",test_name,"/trk_memory_access.log"},"w");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_memory_access," Time  | PC       | Opcode | Address   | Data     \n");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");  
end

//tracker on memory_access operations
always @(posedge Clk) begin : memory_access_print
    if( DMemWrEn) begin
    $fwrite(trk_memory_access,"%t | %8h | write  | %8h | %8h \n", $realtime, Pc, DMemAddress, DMemData);
    end
    if( DMemRdEn) begin
    $fwrite(trk_memory_access,"%t | %8h | read   | %8h | %8h \n", $realtime, Pc, DMemAddress, sc_core.DMemRspData);
    end
end


integer trk_rf;
initial begin: trk_rf_gen
    trk_rf = $fopen({"../../../target/sc_core/tests/",test_name,"/trk_rf.log"},"w");
    $fwrite(trk_rf,"--------------------------------------------------------------------\n");
    $fwrite(trk_rf,"   Time   | PC       |   reg_dst   | wr_data                               \n");
    $fwrite(trk_rf,"--------------------------------------------------------------------\n");  
end
always @(posedge Clk) begin : rf_print
    if(sc_core.CtrlRegWrEn) begin
        $fwrite(trk_rf,"%8t | %8h |   %8h  | %8h          \n", 
        $realtime,
        Pc,                                   // PC
        sc_core.RegDst,         // reg_dst
        sc_core.RegWrData);      // wr_data
        //TODO - see how we can maybe detect what was the instruction that resulted in this write
    end
end