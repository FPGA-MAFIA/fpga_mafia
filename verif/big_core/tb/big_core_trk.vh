//-----------------------------------------------------------------------------
// Title            : big_core_trk
// Project          : riscv_manycore_mesh_fpga
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
    trk_alu = $fopen({"../../target/big_core/",test_name,"/trk_alu.log"},"w");
    $fwrite(trk_alu,"---------------------------------------------------------\n");
    $fwrite(trk_alu,"Time    |    PC    | inst_op | opcode |  AluIn1   |  AluIn2   | AluOut   |  \n");
    $fwrite(trk_alu,"---------------------------------------------------------\n");  

end
//tracker on ALU operations
always @(posedge Clk) begin : alu_print
    $fwrite(trk_alu,"%t  | %8h |  %5s  | %6s | %8h  | %8h  |%8h  | \n", $realtime,big_core_top.big_core.PcQ102H, big_core_top.big_core.OpcodeQ102H.name(), big_core_top.big_core.CtrlAluOpQ102H.name(), big_core_top.big_core.AluIn1Q102H, big_core_top.big_core.AluIn2Q102H, big_core_top.big_core.AluOutQ102H); // # FIXME
end

integer trk_inst;
initial begin: trk_inst_gen
    $timeformat(-9, 1, " ", 6);
    trk_inst = $fopen({"../../target/big_core/",test_name,"/trk_inst.log"},"w");
    $fwrite(trk_inst,"---------------------------------------------------------\n");
    $fwrite(trk_inst," Time  | PC       | Instraction                      |\n");
    $fwrite(trk_inst,"---------------------------------------------------------\n");  

end
always @(posedge Clk) begin : inst_print
    $fwrite(trk_inst,"%t | %8h | %32b | \n", $realtime,big_core_top.big_core.PcQ102H, big_core_top.big_core.InstructionQ102H);
end
integer trk_fetch;
initial begin: trk_fetch_gen
    $timeformat(-9, 1, " ", 6);
    trk_fetch = $fopen({"../../target/big_core/",test_name,"/trk_fetch.log"},"w");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");
    $fwrite(trk_fetch," Time  | PC       | Funct3 | Funct7  | Opcode  |\n");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");  

end
always @(posedge Clk) begin : fetch_print
    $fwrite(trk_fetch,"%t | %8h |   %3b  | %7b | %7b | \n", $realtime,big_core_top.big_core.PcQ101H, big_core_top.big_core.Funct3Q101H, big_core_top.big_core.Funct7Q101H, big_core_top.big_core.OpcodeQ101H); // # FIXME
end

integer trk_memory_access;
initial begin: trk_memory_access_gen
    $timeformat(-9, 1, " ", 6);
    trk_memory_access = $fopen({"../../target/big_core/",test_name,"/trk_memory_access.log"},"w");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_memory_access," Time  | PC       | Opcode | Adress   | Data     \n");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");  

end
//tracker on memory_access operations
always @(posedge Clk) begin : memory_access_print
    if( big_core_top.big_core.DMemWrEnQ103H) begin
    $fwrite(trk_memory_access,"%t | %8h | write  | %8h | %8h \n", $realtime, big_core_top.big_core.PcQ103H, big_core_top.big_core.DMemAddressQ103H, big_core_top.big_core.DMemWrDataQ103H);
    end
    if( big_core_top.big_core.DMemRdEnQ103H) begin
    $fwrite(trk_memory_access,"%t | %8h | read   | %8h | %8h \n", $realtime, big_core_top.big_core.PcQ103H, big_core_top.big_core.DMemAddressQ103H, big_core_top.big_core.DMemWrDataQ103H);
    end
end