//-----------------------------------------------------------------------------
// Title            : big_core_trk
// Project          : fpga_mafia
//-----------------------------------------------------------------------------
// File             : big_core_trk.vh
// Original Author  : Daniel Kaufman
// Code Owner       : 
// Created          : 01/2023
//-----------------------------------------------------------------------------
// Description :
// this file contain the trakers for big_core_tb   
//-----------------------------------------------------------------------------


integer trk_alu;
initial begin: trk_alu_gen
    $timeformat(-9, 1, " ", 6);
    trk_alu = $fopen({"../../../target/big_core/tests/",test_name,"/trk_alu.log"},"w");
    $fwrite(trk_alu,"-----------------------------------------------------------------------------\n");
    $fwrite(trk_alu,"Time    |    PC    | inst_op  | opcode |  AluIn1   |  AluIn2   | AluOut   |  \n");
    $fwrite(trk_alu,"-----------------------------------------------------------------------------\n");  

end
//tracker on ALU operations
always @(posedge Clk) begin : alu_print
    $fwrite(trk_alu,"%t  | %8h |  %-6s  | %-6s | %8h  | %8h  |%8h  | \n", $realtime,big_core_top.big_core.PcQ102H, big_core_top.big_core.OpcodeQ102H.name(), big_core_top.big_core.CtrlAluOpQ102H.name(), big_core_top.big_core.AluIn1Q102H, big_core_top.big_core.AluIn2Q102H, big_core_top.big_core.AluOutQ102H); // # FIXME
end

integer trk_inst;
initial begin: trk_inst_gen
    $timeformat(-9, 1, " ", 6);
    trk_inst = $fopen({"../../../target/big_core/tests/",test_name,"/trk_inst.log"},"w");
    $fwrite(trk_inst,"---------------------------------------------------------\n");
    $fwrite(trk_inst," Time  | PC       | Instruction                      |\n");
    $fwrite(trk_inst,"---------------------------------------------------------\n");  

end
always @(posedge Clk) begin : inst_print
    $fwrite(trk_inst,"%t | %8h | %32b | \n", $realtime,big_core_top.big_core.PcQ102H, InstructionQ102H);
end
integer trk_fetch;
initial begin: trk_fetch_gen
    $timeformat(-9, 1, " ", 6);
    trk_fetch = $fopen({"../../../target/big_core/tests/",test_name,"/trk_fetch.log"},"w");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");
    $fwrite(trk_fetch," Time  | PC       | Funct3 | Funct7  | Opcode  |\n");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");  

end
always @(posedge Clk) begin : fetch_print
    $fwrite(trk_fetch,"%t | %8h |   %3b  | %7b | %-6s | \n", $realtime,big_core_top.big_core.PcQ101H, big_core_top.big_core.Funct3Q101H, big_core_top.big_core.Funct7Q101H, big_core_top.big_core.OpcodeQ101H.name()); // # FIXME
end



logic [31:0] PcQ103H;
logic [31:0] PcQ104H;
logic [31:0] DMemAddressQ104H;
logic [31:0] DMemWrDataQ104H;
logic        DMemWrEnQ104H;
logic        DMemRdEnQ104H;
`MAFIA_DFF(DMemWrEnQ104H    , big_core_top.big_core.DMemWrEnQ103H   , Clk)
`MAFIA_DFF(DMemRdEnQ104H    , big_core_top.big_core.DMemRdEnQ103H   , Clk)
`MAFIA_DFF(PcQ103H          , big_core_top.big_core.PcQ102H         , Clk)
`MAFIA_DFF(PcQ104H          , PcQ103H         , Clk)
`MAFIA_DFF(DMemAddressQ104H , big_core_top.big_core.DMemAddressQ103H, Clk)
`MAFIA_DFF(DMemWrDataQ104H  , big_core_top.big_core.DMemWrDataQ103H , Clk)

integer trk_memory_access;
initial begin: trk_memory_access_gen
    $timeformat(-12, 1, " ", 6);
    trk_memory_access = $fopen({"../../../target/big_core/tests/",test_name,"/trk_memory_access.log"},"w");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_memory_access," Time  | PC       | Opcode | Adress   | Data     \n");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");  
end

//tracker on memory_access operations
always @(posedge Clk) begin : memory_access_print
    if( DMemWrEnQ104H) begin
    $fwrite(trk_memory_access,"%t | %8h | write  | %8h | %8h \n", $realtime, PcQ104H, DMemAddressQ104H, DMemWrDataQ104H);
    end
    if( DMemRdEnQ104H) begin
    $fwrite(trk_memory_access,"%t | %8h | read   | %8h | %8h \n", $realtime, PcQ104H, DMemAddressQ104H, big_core_top.big_core.DMemRdRspQ104H);
    end
end

integer trk_rf;
initial begin: trk_rf_gen
    trk_rf = $fopen({"../../../target/big_core/tests/",test_name,"/trk_rf.log"},"w");
    $fwrite(trk_rf,"--------------------------------------------------------------------\n");
    $fwrite(trk_rf,"   Time   | PC       |   reg_dst   | wr_data                               \n");
    $fwrite(trk_rf,"--------------------------------------------------------------------\n");  
end
always @(posedge Clk) begin : rf_print
    if(big_core_top.big_core.CtrlRegWrEnQ104H) begin
        $fwrite(trk_rf,"%8t | %8h |   %8h  | %8h          \n", 
        $realtime,
        PcQ104H,                                   // PC
        big_core_top.big_core.RegDstQ104H,         // reg_dst
        big_core_top.big_core.RegWrDataQ104H);      // wr_data
        //TODO - see how we can maybe detect what was the instruction that resulted in this write
    end
end

