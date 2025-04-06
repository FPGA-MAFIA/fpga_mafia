integer trk_alu;
initial begin: trk_alu_gen
    #1
    $timeformat(-9, 1, " ", 6);
    trk_alu = $fopen({"../../../target/mini_core_di/tests/",test_name,"/trk_alu.log"},"w");
    $fwrite(trk_alu,"---------------------------------------------------------\n");
    $fwrite(trk_alu,"Time\t|\tPC1 \t |\tPC2 \t | AluIn1Q102H\t| AluIn2Q102H\t| AluOutQ102H\t|\n");
    $fwrite(trk_alu,"---------------------------------------------------------\n");  
end

always @(posedge Clk) begin : alu_print
    $fwrite(trk_alu,"%t\t| %8h | %8h |%8h \t|%8h \t|%8h \t| \n", $realtime,PcQ102H,PcQ202H, mini_core_di_top.mini_core_di.mini_core_dip_exe.AluIn1Q102H , mini_core_di_top.mini_core_di.mini_core_dip_exe.AluIn2Q102H, mini_core_di_top.mini_core_di.mini_core_dip_exe.AluOutQ102H);
end


integer trk_idu;
initial begin: trk_idu_gen
    #1
    $timeformat(-9, 1, " ", 6);
    trk_idu = $fopen({"../../../target/mini_core_di/tests/",test_name,"/trk_idu.log"},"w");
    $fwrite(trk_idu,"--------------------------------------------------------------------------------------------------------------------------------\n");
    $fwrite(trk_idu,"   Time |  PC1_in  |  PC2_in  | PC1_out  | PC2_out  | I2NV |           Instruction_1         |           Instruction_2         |\n");
    $fwrite(trk_idu,"--------------------------------------------------------------------------------------------------------------------------------\n");  
end

assign PreInstruction_1 = mini_core_di_top.mini_core_di.mini_core_di_idu.PreInstructionQ101H_issued;
assign PreInstruction_2 = mini_core_di_top.mini_core_di.mini_core_di_idu.PreInstructionQ201H_issued;

always @(posedge Clk) begin : idu_print
    $fwrite(trk_idu,"%t\t| %8h | %8h | %8h | %8h |  %1b   |%32b |%32b |  %1b   |\n", $realtime, mini_core_di_top.mini_core_di.mini_core_di_idu.PrePcQ101H, mini_core_di_top.mini_core_di.mini_core_di_idu.PrePcQ201H, mini_core_di_top.mini_core_di.mini_core_di_idu.PostPcQ101H, mini_core_di_top.mini_core_di.mini_core_di_idu.PostPcQ201H, mini_core_di_top.mini_core_di.mini_core_di_idu.issue2ValidN, PreInstruction_1, PreInstruction_2, mini_core_di_top.mini_core_di.mini_core_di_idu.BufferSel);
end


integer trk_inst;
initial begin: trk_inst_gen
    #1
    $timeformat(-9, 1, " ", 6);
    trk_inst = $fopen({"../../../target/mini_core_di/tests/",test_name,"/trk_inst.log"},"w");
    $fwrite(trk_inst,"--------------------------------------------------------------------------------------------------------\n");
    $fwrite(trk_inst,"  Time 	|     PC1    |           Instruction           |     PC2     |           Instruction           |\n");
    $fwrite(trk_inst,"--------------------------------------------------------------------------------------------------------\n");  
end
// Uncomment and update when needed
assign Instruction_1 = mini_core_di_top.mini_core_di.mini_core_di_ctrl.InstructionQ101H;
assign Instruction_2 = mini_core_di_top.mini_core_di.mini_core_di_ctrl.InstructionQ201H;

always @(posedge Clk) begin : inst_print
   $fwrite(trk_inst,"%t\t| %8h \t |%32b | %8h \t |%32b | \n", $realtime,PcQ101H, Instruction_1 ,PcQ201H, Instruction_2 );
end

integer trk_fetch;
initial begin: trk_fetch_gen
    #1
    $timeformat(-9, 1, " ", 6);
    trk_fetch = $fopen({"../../../target/mini_core_di/tests/",test_name,"/trk_fetch.log"},"w");
    $fwrite(trk_fetch,"--------------------------------------------------------------------\n");
    $fwrite(trk_fetch,"  Time	|	    PC1 	 |	   PC2 	   |Funct3 | Funct7  | Opcode| I2V |\n");
    $fwrite(trk_fetch,"--------------------------------------------------------------------\n");  
end
// Uncomment and update when needed
always @(posedge Clk) begin : fetch_print
   $fwrite(trk_fetch,"%t\t| %8h \t | %8h \t | %1b  |\n", $realtime, mini_core_di_top.mini_core_di.mini_core_di_if.PcQ100H, mini_core_di_top.mini_core_di.mini_core_di_if.PcQ200H, Issue2ValidNQ201H);
end

integer trk_memory_access;
initial begin: trk_memory_access_gen
    #1
    $timeformat(-9, 1, " ", 6);
    trk_memory_access = $fopen({"../../../target/mini_core_di/tests/",test_name,"/trk_memory_access.log"},"w");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_memory_access,"Time  |  PC1 | PC2   | Opcode  | Address  | Data  |\n");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");  
end

integer trk_ref_memory_access;
initial begin: trk_rf_memory_access_gen
    #1
    $timeformat(-9, 1, " ", 6);
    trk_ref_memory_access = $fopen({"../../../target/mini_core_di/tests/",test_name,"/trk_ref_memory_access.log"},"w");
    $fwrite(trk_ref_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_ref_memory_access,"Time  |  PC | Opcode  | Address  | Data  |\n");
    $fwrite(trk_ref_memory_access,"---------------------------------------------------------\n");  
end

assign PcQ100H = mini_core_di_top.PcQ100H;
assign PcQ200H = mini_core_di_top.PcQ200H;

logic DMemRdEnQ104H;
logic DMemWrEnQ104H;
logic [31:0] DMemAddressQ104H;
logic [31:0] DMemWrDataQ104H;

assign DMemWrEnQ104H = mini_core_di_top.mini_core_di.mini_core_di_ctrl.CtrlQ104H.DMemWrEn;
assign DMemRdEnQ104H = mini_core_di_top.mini_core_di.mini_core_di_ctrl.CtrlQ104H.DMemRdEn;
`MAFIA_DFF(DMemAddressQ104H, mini_core_di_top.mini_mem_di_wrap.DMemAddressQ103H , Clk)
`MAFIA_DFF(DMemWrDataQ104H,  mini_core_di_top.mini_mem_di_wrap.DMemWrDataQ103H  , Clk)

always @(posedge Clk) begin : memory_access_print
    if(DMemWrEnQ104H) begin
        $fwrite(trk_memory_access,"%t | %8h | write |%8h |%8h \n", $realtime, PcQ104H, DMemAddressQ104H, DMemWrDataQ104H);
    end
    if(DMemRdEnQ104H) begin
        $fwrite(trk_memory_access,"%t | %8h | read  |%8h |%8h \n", $realtime, PcQ104H, DMemAddressQ104H, mini_core_di_top.mini_core_di.mini_core_di_rf.RegWrDataQ104H);
    end
end

import rv32i_ref_pkg::*;
always @(posedge Clk) begin : memory_ref_access_print
    if(rv32i_ref.DMemWrEn) begin
        $fwrite(trk_ref_memory_access,"%t | %8h | write |%8h |%8h \n", $realtime, rv32i_ref.pc, rv32i_ref.mem_wr_addr, rv32i_ref.data_rd2);
    end
    if(rv32i_ref.DMemRdEn) begin
        $fwrite(trk_ref_memory_access,"%t | %8h | read  |%8h |%8h \n", $realtime, rv32i_ref.pc, rv32i_ref.mem_rd_addr, rv32i_ref.next_regfile[rv32i_ref.rd]);
    end
end

integer trk_reg_write;
initial begin: trk_reg_write_gen
    $timeformat(-9, 1, " ", 6);
    #1
    trk_reg_write = $fopen({"../../../target/mini_core_di/tests/",test_name,"/trk_reg_write_ref.log"},"w");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");
    $fwrite(trk_reg_write," Time | PC1 | PC2 |reg_dst|  X0   ,  X1   ,  X2   ,  X3    ,  X4    ,  X5    ,  X6    ,  X7    ,  X8    ,  X9    ,  X10    , X11    , X12    , X13    , X14    , X15    , X16    , X17    , X18    , X19    , X20    , X21    , X22    , X23    , X24    , X25    , X26    , X27    , X28    , X29    , X30    , X31 \n");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");  
end

always_ff @(posedge Clk ) begin
        $fwrite(trk_reg_write,"%6d | %8h | %8h | %2d | %8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h \n"
        ,$time,            
                           PcQ104H, PcQ204H,
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Ctrl.RegDstQ104H,
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[0],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[1],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[2],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[3],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[4],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[5],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[6],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[7],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[8],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[9],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[10],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[11],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[12],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[13],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[14],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[15],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[16],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[17],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[18],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[19],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[20],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[21],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[22],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[23],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[24],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[25],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[26],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[27],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[28],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[29],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[30],
                           mini_core_di_top.mini_core_di.mini_core_di_rf.Register[31]
                           );
end