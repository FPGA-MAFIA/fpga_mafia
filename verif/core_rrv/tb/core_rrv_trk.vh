
integer trk_alu;
initial begin: trk_alu_gen
    $timeformat(-9, 1, " ", 6);
    trk_alu = $fopen({"../../../target/core_rrv/tests/",test_name,"/trk_alu.log"},"w");
    $fwrite(trk_alu,"---------------------------------------------------------\n");
    $fwrite(trk_alu,"Time\t|\tPC \t | AluIn1Q102H\t| AluIn2Q102H\t| AluOutQ102H\t|\n");
    $fwrite(trk_alu,"---------------------------------------------------------\n");  

end
//tracker on ALU operations
always @(posedge Clk) begin : alu_print
    $fwrite(trk_alu,"%t\t| %8h |%8h \t|%8h \t|%8h \t| \n", $realtime,PcQ102H, core_rrv_top.core_rrv.core_rrv_exe.AluIn1Q102H , core_rrv_top.core_rrv.core_rrv_exe.AluIn2Q102H, core_rrv_top.core_rrv.core_rrv_exe.AluOutQ102H);
end

integer trk_inst;
initial begin: trk_inst_gen
    $timeformat(-9, 1, " ", 6);
    trk_inst = $fopen({"../../../target/core_rrv/tests/",test_name,"/trk_inst.log"},"w");
    $fwrite(trk_inst,"---------------------------------------------------------\n");
    $fwrite(trk_inst,"PC \t | Instruction\t|\n");
    $fwrite(trk_inst,"---------------------------------------------------------\n");  

end
always @(posedge Clk) begin : inst_print
    if(core_rrv_top.core_rrv.core_rrv_ctrl.ValidInstQ105H)
        $fwrite(trk_inst,"%8h \t |%8h | \n", 
        core_rrv_top.core_rrv.core_rrv_ctrl.CtrlQ105H.Pc, 
        core_rrv_top.core_rrv.core_rrv_ctrl.CtrlQ105H.Instruction);
end
integer trk_fetch;
initial begin: trk_fetch_gen
    $timeformat(-9, 1, " ", 6);
    trk_fetch = $fopen({"../../../target/core_rrv/tests/",test_name,"/trk_fetch.log"},"w");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");
    $fwrite(trk_fetch,"Time\t|\tPC \t |Funct3 \t| Funct7 \t | Opcode|\n");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");  

end
//always @(posedge Clk) begin : fetch_print
//    $fwrite(trk_fetch,"%t\t| %8h \t |%3b \t |%7b\t |%7b| \n", $realtime,PcQ100H, core_rrv.Funct3Q101H, core_rrv.Funct7Q101H, core_rrv.OpcodeQ101H);
//end

integer trk_memory_access;
initial begin: trk_memory_access_gen
    $timeformat(-9, 1, " ", 6);
    trk_memory_access = $fopen({"../../../target/core_rrv/tests/",test_name,"/trk_memory_access.log"},"w");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_memory_access,"Time  |  PC   | Opcode  | Address  | Data  |\n");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");  
end

//
assign PcQ100H = core_rrv_top.PcQ100H;

logic DMemRdEnQ104H;
logic DMemWrEnQ104H;
logic [31:0] DMemAddressQ104H;
logic [31:0] DMemWrDataQ104H;

assign DMemWrEnQ104H = core_rrv_top.core_rrv.core_rrv_ctrl.CtrlQ104H.DMemWrEn;
assign DMemRdEnQ104H = core_rrv_top.core_rrv.core_rrv_ctrl.CtrlQ104H.DMemRdEn;
`MAFIA_DFF(DMemAddressQ104H, core_rrv_top.core_rrv_mem_wrap.DMemAddressQ103H , Clk)
`MAFIA_DFF(DMemWrDataQ104H,  core_rrv_top.core_rrv_mem_wrap.DMemWrDataQ103H  , Clk)


//tracker on memory_access operations
always @(posedge Clk) begin : memory_access_print
    if(DMemWrEnQ104H) begin
        $fwrite(trk_memory_access,"%t | %8h | write |%8h |%8h \n", $realtime, PcQ104H, DMemAddressQ104H, DMemWrDataQ104H);
    end
    if(DMemRdEnQ104H) begin
        $fwrite(trk_memory_access,"%t | %8h | read  |%8h |%8h \n", $realtime, PcQ104H, DMemAddressQ104H, core_rrv_top.core_rrv.core_rrv_rf.RegWrDataQ105H);
    end
end

integer trk_reg_write;
initial begin: trk_reg_write_gen
    $timeformat(-9, 1, " ", 6);
    trk_reg_write = $fopen({"../../../target/core_rrv/tests/",test_name,"/trk_reg_write.log"},"w");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");
    $fwrite(trk_reg_write," Time | PC |reg_dst|  X0   ,  X1   ,  X2   ,  X3    ,  X4    ,  X5    ,  X6    ,  X7    ,  X8    ,  X9    ,  X10    , X11    , X12    , X13    , X14    , X15    , X16    , X17    , X18    , X19    , X20    , X21    , X22    , X23    , X24    , X25    , X26    , X27    , X28    , X29    , X30    , X31 \n");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");  
end

always_ff @(posedge Clk ) begin
        $fwrite(trk_reg_write,"%6d | %4h | %2d | %8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h \n"
        ,$time,            
                           PcQ105H,
                           core_rrv_top.core_rrv.core_rrv_rf.Ctrl.RegDstQ105H,
                           core_rrv_top.core_rrv.core_rrv_rf.Register[0],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[1],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[2],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[3],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[4],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[5],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[6],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[7],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[8],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[9],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[10],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[11],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[12],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[13],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[14],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[15],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[16],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[17],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[18],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[19],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[20],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[21],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[22],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[23],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[24],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[25],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[26],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[27],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[28],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[29],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[30],
                           core_rrv_top.core_rrv.core_rrv_rf.Register[31]
                           );
end



// FIXME