


integer trk_tile_1_1_input;
initial begin: trk_tile_1_1_input_gen
    $timeformat(-9, 1, " ", 6);
    trk_tile_1_1_input = $fopen({"../../../target/fabric/tests/",test_name,"/trk_tile_1_1_input.log"},"w");
    $fwrite(trk_tile_1_1_input,"---------------------------------------------------------\n");
    $fwrite(trk_tile_1_1_input,"Time  | requestor_id |  opcode | address  |   data   | \n");
    $fwrite(trk_tile_1_1_input,"---------------------------------------------------------\n");  
end

always_ff @(posedge clk) begin
    if(fabric.col[1].row[1].mini_core_tile_ins.mini_core_top.mini_mem_wrap.InFabricValidQ503H) begin
        $fwrite(trk_tile_1_1_input,"%t|    %h       |  %s     | %h |  %h  | \n", $realtime, 
                                                fabric.col[1].row[1].mini_core_tile_ins.mini_core_top.mini_mem_wrap.InFabricQ503H.requestor_id,
                                                fabric.col[1].row[1].mini_core_tile_ins.mini_core_top.mini_mem_wrap.InFabricQ503H.opcode,
                                                fabric.col[1].row[1].mini_core_tile_ins.mini_core_top.mini_mem_wrap.InFabricQ503H.address,
                                                fabric.col[1].row[1].mini_core_tile_ins.mini_core_top.mini_mem_wrap.InFabricQ503H.data
                                                
                                                );
    end
end
    
//integer trk_alu;
//initial begin: trk_alu_gen
//    $timeformat(-9, 1, " ", 6);
//    for(int i = 1 ; i< V_COL; i++) begin
//        for(int j = 1 ; j< V_ROW; j++)begin
//            trk_alu = $fopen({"../../../target/fabric/tests/",test_name,"/trk_alu_cores/trk_alu%d%d.log",i,j},"w");
//            $fwrite(trk_alu,"---------------------------------------------------------\n");
//            $fwrite(trk_alu,"Time\t|\tPC \t | AluIn1Q102H\t| AluIn2Q102H\t| AluOutQ102H\t|\n");
//            $fwrite(trk_alu,"---------------------------------------------------------\n");  
//        end
//    end
//
//end
//tracker on ALU operations
/*always @(posedge clk) begin : alu_print
    $fwrite(trk_alu,"%t\t| %8h |%8h \t|%8h \t|%8h \t| \n", $realtime,PcQ102H, mini_core_top.mini_core.AluIn1Q102H , mini_core_top.mini_core.AluIn2Q102H, mini_core_top.mini_core.AluOutQ102H);
end

integer trk_inst;
initial begin: trk_inst_gen
    $timeformat(-9, 1, " ", 6);
    trk_inst = $fopen({"../../../target/mini_core/tests/",test_name,"/trk_inst.log"},"w");
    $fwrite(trk_inst,"---------------------------------------------------------\n");
    $fwrite(trk_inst,"Time\t|\tPC \t | Instruction\t|\n");
    $fwrite(trk_inst,"---------------------------------------------------------\n");  

end
//always @(posedge Clk) begin : inst_print
//    $fwrite(trk_inst,"%t\t| %8h \t |%32b | \n", $realtime,PcQ100H, Instruction);
//end
integer trk_fetch;
initial begin: trk_fetch_gen
    $timeformat(-9, 1, " ", 6);
    trk_fetch = $fopen({"../../../target/mini_core/tests/",test_name,"/trk_fetch.log"},"w");
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
    trk_memory_access = $fopen({"../../../target/mini_core/tests/",test_name,"/trk_memory_access.log"},"w");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_memory_access,"Time  |  PC   | Opcode  | Address  | Data  |\n");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");  
end
integer trk_ref_memory_access;
initial begin: trk_rf_memory_access_gen
    $timeformat(-9, 1, " ", 6);
    trk_ref_memory_access = $fopen({"../../../target/mini_core/tests/",test_name,"/trk_ref_memory_access.log"},"w");
    $fwrite(trk_ref_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_ref_memory_access,"Time  |  PC   | Opcode  | Address  | Data  |\n");
    $fwrite(trk_ref_memory_access,"---------------------------------------------------------\n");  
end
//
assign PcQ100H = mini_core_top.PcQ100H;
`MAFIA_DFF(PcQ101H,  PcQ100H , clk)
`MAFIA_DFF(PcQ102H,  PcQ101H , clk)
`MAFIA_DFF(PcQ103H,  PcQ102H , clk)
`MAFIA_DFF(PcQ104H,  PcQ103H , clk)

logic DMemRdEnQ104H;
logic DMemWrEnQ104H;
logic [31:0] DMemAddressQ104H;
logic [31:0] DMemWrDataQ104H;

`MAFIA_DFF(DMemWrEnQ104H,    mini_core_top.mini_mem_wrap.DMemWrEnQ103H    , clk)
`MAFIA_DFF(DMemRdEnQ104H,    mini_core_top.mini_mem_wrap.DMemRdEnQ103H    , clk)
`MAFIA_DFF(DMemAddressQ104H, mini_core_top.mini_mem_wrap.DMemAddressQ103H , clk)
`MAFIA_DFF(DMemWrDataQ104H,  mini_core_top.mini_mem_wrap.DMemWrDataQ103H  , clk)
//tracker on memory_access operations
always @(posedge clk) begin : memory_access_print
    if(DMemWrEnQ104H) begin
        $fwrite(trk_memory_access,"%t | %8h | write |%8h |%8h \n", $realtime, PcQ104H, DMemAddressQ104H, DMemWrDataQ104H);
    end
    if(DMemRdEnQ104H) begin
        $fwrite(trk_memory_access,"%t | %8h | read  |%8h |%8h \n", $realtime, PcQ104H, DMemAddressQ104H, mini_core_top.mini_core.mini_core_rf.RegWrDataQ104H);
    end
end

import rv32i_ref_pkg::*;
always @(posedge clk) begin : memory_ref_access_print
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
    trk_reg_write = $fopen({"../../../target/mini_core/tests/",test_name,"/trk_reg_write_ref.log"},"w");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");
    $fwrite(trk_reg_write," Time | PC |reg_dst|  X0   ,  X1   ,  X2   ,  X3    ,  X4    ,  X5    ,  X6    ,  X7    ,  X8    ,  X9    ,  X10    , X11    , X12    , X13    , X14    , X15    , X16    , X17    , X18    , X19    , X20    , X21    , X22    , X23    , X24    , X25    , X26    , X27    , X28    , X29    , X30    , X31 \n");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");  
end

always_ff @(posedge clk ) begin
        $fwrite(trk_reg_write,"%6d | %4h | %2d | %8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h \n"
        ,$time,            
                           PcQ104H,
                           mini_core_top.mini_core.mini_core_rf.Ctrl.RegDstQ104H,
                           mini_core_top.mini_core.mini_core_rf.Register[0],
                           mini_core_top.mini_core.mini_core_rf.Register[1],
                           mini_core_top.mini_core.mini_core_rf.Register[2],
                           mini_core_top.mini_core.mini_core_rf.Register[3],
                           mini_core_top.mini_core.mini_core_rf.Register[4],
                           mini_core_top.mini_core.mini_core_rf.Register[5],
                           mini_core_top.mini_core.mini_core_rf.Register[6],
                           mini_core_top.mini_core.mini_core_rf.Register[7],
                           mini_core_top.mini_core.mini_core_rf.Register[8],
                           mini_core_top.mini_core.mini_core_rf.Register[9],
                           mini_core_top.mini_core.mini_core_rf.Register[10],
                           mini_core_top.mini_core.mini_core_rf.Register[11],
                           mini_core_top.mini_core.mini_core_rf.Register[12],
                           mini_core_top.mini_core.mini_core_rf.Register[13],
                           mini_core_top.mini_core.mini_core_rf.Register[14],
                           mini_core_top.mini_core.mini_core_rf.Register[15],
                           mini_core_top.mini_core.mini_core_rf.Register[16],
                           mini_core_top.mini_core.mini_core_rf.Register[17],
                           mini_core_top.mini_core.mini_core_rf.Register[18],
                           mini_core_top.mini_core.mini_core_rf.Register[19],
                           mini_core_top.mini_core.mini_core_rf.Register[20],
                           mini_core_top.mini_core.mini_core_rf.Register[21],
                           mini_core_top.mini_core.mini_core_rf.Register[22],
                           mini_core_top.mini_core.mini_core_rf.Register[23],
                           mini_core_top.mini_core.mini_core_rf.Register[24],
                           mini_core_top.mini_core.mini_core_rf.Register[25],
                           mini_core_top.mini_core.mini_core_rf.Register[26],
                           mini_core_top.mini_core.mini_core_rf.Register[27],
                           mini_core_top.mini_core.mini_core_rf.Register[28],
                           mini_core_top.mini_core.mini_core_rf.Register[29],
                           mini_core_top.mini_core.mini_core_rf.Register[30],
                           mini_core_top.mini_core.mini_core_rf.Register[31]
                           );
end



// FIXME*/