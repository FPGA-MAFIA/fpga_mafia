
integer trk_alu;
initial begin: trk_alu_gen
    $timeformat(-9, 1, " ", 6);
    trk_alu = $fopen({"../../../target/mini_core_accel/tests/",test_name,"/trk_alu.log"},"w");
    $fwrite(trk_alu,"---------------------------------------------------------\n");
    $fwrite(trk_alu,"Time\t|\tPC \t | AluIn1Q102H\t| AluIn2Q102H\t| AluOutQ102H\t|\n");
    $fwrite(trk_alu,"---------------------------------------------------------\n");  

end
//tracker on ALU operations
always @(posedge Clk) begin : alu_print
    $fwrite(trk_alu,"%t\t| %8h |%8h \t|%8h \t|%8h \t| \n", $realtime,PcQ102H, mini_core_accel_top.mini_core.mini_core_exe.AluIn1Q102H , mini_core_accel_top.mini_core.mini_core_exe.AluIn2Q102H, mini_core_accel_top.mini_core.mini_core_exe.AluOutQ102H);
end

//tracker on instruction generator in stage Q101H
logic [31:0] InstructionQ101H;
assign InstructionQ101H = mini_core_accel_top.mini_core.mini_core_ctrl.InstructionQ101H;

integer trk_inst;
initial begin: trk_inst_gen
    $timeformat(-9, 1, " ", 6);
    trk_inst = $fopen({"../../../target/mini_core_accel/tests/",test_name,"/trk_inst.log"},"w");
    $fwrite(trk_inst,"---------------------------------------------------------\n");
    $fwrite(trk_inst,"Time\t|\tPC \t | Instruction\t|\n");
    $fwrite(trk_inst,"---------------------------------------------------------\n");  

end

always @(posedge Clk) begin : trk_inst_gen_print
        $fwrite(trk_inst,"%t | %8h | %8h \n", $realtime, PcQ101H, InstructionQ101H);
end

// generated instruction in Q101H in more details
integer trk_fetch;
initial begin: trk_fetch_gen
    $timeformat(-9, 1, " ", 6);
    trk_fetch = $fopen({"../../../target/mini_core_accel/tests/",test_name,"/trk_fetch.log"},"w");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");
    $fwrite(trk_fetch,"Time\t|\tPC \t |Funct3 \t| Funct7 \t | Opcode|\n");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");  

end

always @(posedge Clk) begin : trk_fetch_gen_print
        $fwrite(trk_fetch,"%t | %8h | %8h | %8h | %8h \n", $realtime, PcQ101H, InstructionQ101H[14:12], InstructionQ101H[31:25], InstructionQ101H[6:0]);
end

integer trk_memory_access;
initial begin: trk_memory_access_gen
    $timeformat(-9, 1, " ", 6);
    trk_memory_access = $fopen({"../../../target/mini_core_accel/tests/",test_name,"/trk_memory_access.log"},"w");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_memory_access,"Time  |  PC   | Opcode  | Address  | Data  |\n");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");  
end
integer trk_ref_memory_access;
initial begin: trk_rf_memory_access_gen
    $timeformat(-9, 1, " ", 6);
    trk_ref_memory_access = $fopen({"../../../target/mini_core_accel/tests/",test_name,"/trk_ref_memory_access.log"},"w");
    $fwrite(trk_ref_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_ref_memory_access,"Time  |  PC   | Opcode  | Address  | Data  |\n");
    $fwrite(trk_ref_memory_access,"---------------------------------------------------------\n");  
end
//
assign PcQ100H = mini_core_accel_top.PcQ100H;

logic DMemRdEnQ104H;
logic DMemWrEnQ104H;
logic [31:0] DMemAddressQ104H;
logic [31:0] DMemWrDataQ104H;

assign DMemWrEnQ104H = mini_core_accel_top.mini_core.mini_core_ctrl.CtrlQ104H.DMemWrEn;
assign DMemRdEnQ104H = mini_core_accel_top.mini_core.mini_core_ctrl.CtrlQ104H.DMemRdEn;
`MAFIA_DFF(DMemAddressQ104H, mini_core_accel_top.mini_core_accel_mem_wrap.DMemAddressQ103H , Clk)
`MAFIA_DFF(DMemWrDataQ104H,  mini_core_accel_top.mini_core_accel_mem_wrap.DMemWrDataQ103H  , Clk)


//tracker on memory_access operations
always @(posedge Clk) begin : memory_access_print
    if(DMemWrEnQ104H) begin
        $fwrite(trk_memory_access,"%t | %8h | write |%8h |%8h \n", $realtime, PcQ104H, DMemAddressQ104H, DMemWrDataQ104H);
    end
    if(DMemRdEnQ104H) begin
        $fwrite(trk_memory_access,"%t | %8h | read  |%8h |%8h \n", $realtime, PcQ104H, DMemAddressQ104H, mini_core_accel_top.mini_core.mini_core_rf.RegWrDataQ104H);
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
    trk_reg_write = $fopen({"../../../target/mini_core_accel/tests/",test_name,"/trk_reg_write_ref.log"},"w");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");
    $fwrite(trk_reg_write," Time | PC |reg_dst|  X0   ,  X1   ,  X2   ,  X3    ,  X4    ,  X5    ,  X6    ,  X7    ,  X8    ,  X9    ,  X10    , X11    , X12    , X13    , X14    , X15    , X16    , X17    , X18    , X19    , X20    , X21    , X22    , X23    , X24    , X25    , X26    , X27    , X28    , X29    , X30    , X31 \n");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");  
end

/*
integer trk_performance;
initial begin: trk_performance_gen
    $timeformat(-9, 1, " ", 6);
    trk_performance = $fopen({"../../../target/mini_core_accel/tests/",test_name,"/trk_performance.log"},"w");
    $fwrite(trk_performance,"---------------------------------------------------------\n");
    $fwrite(trk_performance,"               Performance monitor                       \n");
    $fwrite(trk_performance,"---------------------------------------------------------\n");  
end

//tracker performance monitor operations
logic [31:0] ClockCounter;
logic [31:0] ValidInstQ104HCounter;

always @(posedge Clk) begin : trk_performance_gen_calc
    if(Rst) begin
        ClockCounter          <= 32'b0;
        ValidInstQ104HCounter <= 32'b0;
    end
    else if (mini_core_accel_top.mini_core.mini_core_ctrl.ValidInstQ104H == 1'b1) begin
            ValidInstQ104HCounter <= ValidInstQ104HCounter + 32'b1;
            ClockCounter <= ClockCounter + 32'b1;
    end
    else begin
        ClockCounter <= ClockCounter + 32'b1;
    end

end
    
always @(posedge Clk) begin : trk_performance_gen_print
    if(mini_core_accel_top.mini_core.mini_core_ctrl.ebreak_was_calledQ101H == 1'b1) begin
        $fwrite(trk_performance,"Test name: ", test_name, " test\n");
        $fwrite(trk_performance,"The number of valid instructions is: %1d\n", ValidInstQ104HCounter);
        $fwrite(trk_performance,"The number of Cycles is: %1d\n", ClockCounter);
    end

end
*/
always_ff @(posedge Clk ) begin
        $fwrite(trk_reg_write,"%6d | %4h | %2d | %8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h \n"
        ,$time,            
                           PcQ104H,
                           mini_core_accel_top.mini_core.mini_core_rf.Ctrl.RegDstQ104H,
                           mini_core_accel_top.mini_core.mini_core_rf.Register[0],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[1],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[2],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[3],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[4],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[5],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[6],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[7],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[8],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[9],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[10],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[11],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[12],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[13],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[14],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[15],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[16],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[17],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[18],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[19],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[20],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[21],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[22],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[23],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[24],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[25],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[26],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[27],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[28],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[29],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[30],
                           mini_core_accel_top.mini_core.mini_core_rf.Register[31]
                           );
end



// FIXME