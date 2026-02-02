
integer trk_alu;
initial begin: trk_alu_gen
    #1
    $timeformat(-9, 1, " ", 6);
    trk_alu = $fopen({"../../../target/mini_core_smt/tests/",test_name,"/trk_alu.log"},"w");
    $fwrite(trk_alu,"---------------------------------------------------------\n");
    $fwrite(trk_alu,"Time\t|\tPC \t | AluIn1Q102H\t| AluIn2Q102H\t| AluOutQ102H\t|\n");
    $fwrite(trk_alu,"---------------------------------------------------------\n");  

end
//tracker on ALU operations
always @(posedge Clk) begin : alu_print
    $fwrite(trk_alu,"%t\t| %8h |%8h \t|%8h \t|%8h \t| \n", $realtime,PcQ102H, mini_core_smt_top.mini_core_smt.mini_core_smt_exe.AluIn1Q102H , mini_core_smt_top.mini_core_smt.mini_core_smt_exe.AluIn2Q102H, mini_core_smt_top.mini_core_smt.mini_core_smt_exe.AluOutQ102H);
end

integer trk_inst;
initial begin: trk_inst_gen
    #1
    $timeformat(-9, 1, " ", 6);
    trk_inst = $fopen({"../../../target/mini_core_smt/tests/",test_name,"/trk_inst.log"},"w");
    $fwrite(trk_inst,"---------------------------------------------------------\n");
    $fwrite(trk_inst,"Time\t|\tPC \t | Instruction\t|\n");
    $fwrite(trk_inst,"---------------------------------------------------------\n");  

end

assign PcQ100H = mini_core_smt_top.PcQ100H;
//always @(posedge Clk) begin : inst_print
//    $fwrite(trk_inst,"%t\t| %8h \t |%32b | \n", $realtime,PcQ100H, Instruction);
//end
integer trk_fetch;
initial begin: trk_fetch_gen
    #1
    $timeformat(-9, 1, " ", 6);
    trk_fetch = $fopen({"../../../target/mini_core_smt/tests/",test_name,"/trk_fetch.log"},"w");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");
    $fwrite(trk_fetch,"Time\t|\tPC \t |Funct3 \t| Funct7 \t | Opcode|\n");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");  

end
always @(posedge Clk) begin : fetch_print
    $fwrite(trk_fetch,"%t\t| %8h \t |%3b \t |%7b\t |%7b| \n", $realtime,PcQ100H, mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.Funct3Q101H, mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.Funct7Q101H,  mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.OpcodeQ101H);
end

integer trk_memory_access;
initial begin: trk_memory_access_gen
    #1
    $timeformat(-9, 1, " ", 6);
    trk_memory_access = $fopen({"../../../target/mini_core_smt/tests/",test_name,"/trk_memory_access.log"},"w");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_memory_access,"Time  |  PC   | Opcode  | Address  | Data  |\n");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");  
end
integer trk_ref_memory_access;
initial begin: trk_rf_memory_access_gen
    #1
    $timeformat(-9, 1, " ", 6);
    trk_ref_memory_access = $fopen({"../../../target/mini_core_smt/tests/",test_name,"/trk_ref_memory_access.log"},"w");
    $fwrite(trk_ref_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_ref_memory_access,"Time  |  PC   | Opcode  | Address  | Data  |\n");
    $fwrite(trk_ref_memory_access,"---------------------------------------------------------\n");  
end
//


logic DMemRdEnQ104H;
logic DMemWrEnQ104H;
logic [31:0] DMemAddressQ104H;
logic [31:0] DMemWrDataQ104H;

assign DMemWrEnQ104H = mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.CtrlQ104H.DMemWrEn;
assign DMemRdEnQ104H = mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.CtrlQ104H.DMemRdEn;
`MAFIA_DFF(DMemAddressQ104H, mini_core_smt_top.mini_smt_mem_wrap.DMemAddressQ103H , Clk)
`MAFIA_DFF(DMemWrDataQ104H,  mini_core_smt_top.mini_smt_mem_wrap.DMemWrDataQ103H  , Clk)


//tracker on memory_access operations
always @(posedge Clk) begin : memory_access_print
    if(DMemWrEnQ104H) begin
        $fwrite(trk_memory_access,"%t | %8h | write |%8h |%8h \n", $realtime, PcQ104H, DMemAddressQ104H, DMemWrDataQ104H);
    end
    if(DMemRdEnQ104H) begin
        $fwrite(trk_memory_access,"%t | %8h | read  |%8h |%8h \n", $realtime, PcQ104H, DMemAddressQ104H, mini_core_smt_top.mini_core_smt.rf_thread0.RegWrDataQ104H);
        $fwrite(trk_memory_access,"%t | %8h | read  |%8h |%8h \n", $realtime, PcQ104H, DMemAddressQ104H, mini_core_smt_top.mini_core_smt.rf_thread1.RegWrDataQ104H);

    end
end

//import rv32i_ref_pkg::*;
//always @(posedge Clk) begin : memory_ref_access_print
    //if(rv32i_ref.DMemWrEn) begin
        //$fwrite(trk_ref_memory_access,"%t | %8h | write |%8h |%8h \n", $realtime, rv32i_ref.pc, rv32i_ref.mem_wr_addr, rv32i_ref.data_rd2);
    //end
    //if(rv32i_ref.DMemRdEn) begin
        //$fwrite(trk_ref_memory_access,"%t | %8h | read  |%8h |%8h \n", $realtime, rv32i_ref.pc, rv32i_ref.mem_rd_addr, rv32i_ref.next_regfile[rv32i_ref.rd]);
    //end
//end

integer trk_reg_write_t0, trk_reg_write_t1;

initial begin: trk_reg_write_gen
    $timeformat(-9, 1, " ", 6);
    #1
    trk_reg_write_t0 = $fopen({"../../../target/mini_core_smt/tests/",test_name,"/trk_reg_write_ref_t0.log"},"w");
    trk_reg_write_t1 = $fopen({"../../../target/mini_core_smt/tests/",test_name,"/trk_reg_write_ref_t1.log"},"w");

    $fwrite(trk_reg_write_t0, "---------------------------------------------------------\n");
    $fwrite(trk_reg_write_t0, " Time | PC | PCQ100H | ReadyQ100H | ReadyQ101H | CurrThread | pcThread0 | pcThread1 | reg_dst| X0, X1, ..., X31 \n");
    $fwrite(trk_reg_write_t0, "---------------------------------------------------------\n");

    $fwrite(trk_reg_write_t1, "---------------------------------------------------------\n");
    $fwrite(trk_reg_write_t1, " Time | PC | PCQ100H | ReadyQ100H | ReadyQ101H | CurrThread | pcThread0 | pcThread1 | reg_dst| X0, X1, ..., X31 \n");
    $fwrite(trk_reg_write_t1, "---------------------------------------------------------\n");

end
always_ff @(posedge Clk) begin
    //if (mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.ThreadIDQ104H == 1'b0) begin
        $fwrite(trk_reg_write_t0, "%6t | %8h | %8h | %1d | %1d | %1d | %8h | %2d |%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h\n",
            $time,
            PcQ104H,
            PcQ100H,
            mini_core_smt_top.mini_core_smt.mini_core_smt_if.ReadyQ100H,
            mini_core_smt_top.mini_core_smt.mini_core_smt_if.ReadyQ101H,
            CurrThread,
            mini_core_smt_top.mini_core_smt.mini_core_smt_if.PC_thread0,
            mini_core_smt_top.mini_core_smt.rf_thread0.Ctrl.RegDstQ104H,
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[0],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[1],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[2],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[3],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[4],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[5],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[6],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[7],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[8],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[9],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[10],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[11],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[12],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[13],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[14],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[15],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[16],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[17],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[18],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[19],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[20],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[21],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[22],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[23],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[24],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[25],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[26],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[27],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[28],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[29],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[30],
            mini_core_smt_top.mini_core_smt.rf_thread0.Register[31]
        );


    //end else if (mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.ThreadIDQ104H == 1'b1) begin
        $fwrite(trk_reg_write_t1, "%6t | %8h | %8h | %1d | %1d | %1d | %8h | %2d |%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h\n",
            $time,
            PcQ104H,
            PcQ100H,
            mini_core_smt_top.mini_core_smt.mini_core_smt_if.ReadyQ100H,
            mini_core_smt_top.mini_core_smt.mini_core_smt_if.ReadyQ101H,
            CurrThread,
            mini_core_smt_top.mini_core_smt.mini_core_smt_if.PC_thread1,
            mini_core_smt_top.mini_core_smt.rf_thread1.Ctrl.RegDstQ104H,
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[0],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[1],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[2],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[3],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[4],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[5],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[6],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[7],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[8],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[9],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[10],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[11],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[12],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[13],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[14],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[15],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[16],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[17],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[18],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[19],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[20],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[21],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[22],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[23],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[24],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[25],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[26],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[27],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[28],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[29],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[30],
            mini_core_smt_top.mini_core_smt.rf_thread1.Register[31]
        );

    //end
end





// FIXME