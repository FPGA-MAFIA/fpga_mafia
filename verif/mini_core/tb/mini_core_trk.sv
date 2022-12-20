
logic [31:0] PcQ101H;             // To I_MEM
logic [31:0] PcQ102H;             // To I_MEM
logic [31:0] PcQ103H;             // To I_MEM
logic [31:0] PcQ104H;             // To I_MEM
integer trk_alu;
initial begin: trk_alu_gen
    $timeformat(-9, 1, " ", 6);
    trk_alu = $fopen({"../../target/mini_core/trk_alu.log"},"w");
    $fwrite(trk_alu,"---------------------------------------------------------\n");
    $fwrite(trk_alu,"Time\t|\tPC \t | AluIn1Q102H\t| AluIn2Q102H\t| AluOutQ102H\t|\n");
    $fwrite(trk_alu,"---------------------------------------------------------\n");  

end
//tracker on ALU operations
always @(posedge Clk) begin : alu_print
    $fwrite(trk_alu,"%t\t| %8h |%8h \t|%8h \t|%8h \t| \n", $realtime,PcQ102H, mini_top.mini_core.AluIn1Q102H , mini_top.mini_core.AluIn2Q102H, mini_top.mini_core.AluOutQ102H);
end

integer trk_inst;
initial begin: trk_inst_gen
    $timeformat(-9, 1, " ", 6);
    trk_inst = $fopen({"../../target/mini_core/trk_inst.log"},"w");
    $fwrite(trk_inst,"---------------------------------------------------------\n");
    $fwrite(trk_inst,"Time\t|\tPC \t | Instraction\t|\n");
    $fwrite(trk_inst,"---------------------------------------------------------\n");  

end
//always @(posedge Clk) begin : inst_print
//    $fwrite(trk_inst,"%t\t| %8h \t |%32b | \n", $realtime,PcQ100H, Instruction);
//end
integer trk_fetch;
initial begin: trk_fetch_gen
    $timeformat(-9, 1, " ", 6);
    trk_fetch = $fopen({"../../target/mini_core/trk_fetch.log"},"w");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");
    $fwrite(trk_fetch,"Time\t|\tPC \t |Funct3 \t| Funct7 \t | Opcode|\n");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");  

end
//always @(posedge Clk) begin : fetch_print
//    $fwrite(trk_fetch,"%t\t| %8h \t |%3b \t |%7b\t |%7b| \n", $realtime,PcQ100H, mini_core.Funct3Q101H, mini_core.Funct7Q101H, mini_core.OpcodeQ101H);
//end

integer trk_memory_access;
initial begin: trk_memory_access_gen
    $timeformat(-9, 1, " ", 6);
    trk_memory_access = $fopen({"../../target/mini_core/trk_memory_access.log"},"w");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_memory_access,"Time\t|\tPC \t | Opcode\t| Adress\t| Data\t|\n");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");  

end
//
assign PcQ100H = mini_top.PcQ100H;
`RVC_DFF(PcQ101H,  PcQ100H , Clk)
`RVC_DFF(PcQ102H,  PcQ101H , Clk)
`RVC_DFF(PcQ103H,  PcQ102H , Clk)
//`RVC_DFF(PcQ104H,  PcQ103H , Clk)
////tracker on memory_access operations
//always @(posedge Clk) begin : memory_access_print
//    if(DMemWrEn) begin
//    $fwrite(trk_memory_access,"%t\t| %8h \t write \t|%8h \t|%8h \n", $realtime, PcQ104H, DMemAddressQ104H, DMemDataQ104H);
//    end
//    if(DMemRdEn) begin
//    $fwrite(trk_memory_access,"%t\t| %8h \t|read \t|%8h \t|%8h \n", $realtime, PcQ104H, DMemAddressQ104H, DMemDataQ104H);
//    end
//end
// FIXME