import accel_core_pkg::*;

integer trk_alu;
initial begin: trk_alu_gen
    $timeformat(-9, 1, " ", 6);
    trk_alu = $fopen({"../../../target/accel_core/tests/",test_name,"/trk_alu.log"},"w");
    $fwrite(trk_alu,"---------------------------------------------------------\n");
    $fwrite(trk_alu,"Time\t|\tPC \t | AluIn1Q102H\t| AluIn2Q102H\t| AluOutQ102H\t|\n");
    $fwrite(trk_alu,"---------------------------------------------------------\n");  

end
//tracker on ALU operations
always @(posedge Clk) begin : alu_print
    $fwrite(trk_alu,"%t\t| %8h |%8h \t|%8h \t|%8h \t| \n", $realtime,PcQ102H, accel_core_top.mini_core.mini_core_exe.AluIn1Q102H , accel_core_top.mini_core.mini_core_exe.AluIn2Q102H, accel_core_top.mini_core.mini_core_exe.AluOutQ102H);
end

integer trk_inst;
initial begin: trk_inst_gen
    $timeformat(-9, 1, " ", 6);
    trk_inst = $fopen({"../../../target/accel_core/tests/",test_name,"/trk_inst.log"},"w");
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
    trk_fetch = $fopen({"../../../target/accel_core/tests/",test_name,"/trk_fetch.log"},"w");
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
    trk_memory_access = $fopen({"../../../target/accel_core/tests/",test_name,"/trk_memory_access.log"},"w");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_memory_access,"Time  |  PC   | Opcode  | Address  | Data  |\n");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");  
end

integer trk_ref_memory_access;
initial begin: trk_rf_memory_access_gen
    $timeformat(-9, 1, " ", 6);
    trk_ref_memory_access = $fopen({"../../../target/accel_core/tests/",test_name,"/trk_ref_memory_access.log"},"w");
    $fwrite(trk_ref_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_ref_memory_access,"Time  |  PC   | Opcode  | Address  | Data  |\n");
    $fwrite(trk_ref_memory_access,"---------------------------------------------------------\n");  
end

integer trk_accel_mul_data;
initial begin: trk_accel_mul_data_gen
    $timeformat(-9, 1, " ", 6);
    trk_accel_mul_data = $fopen({"../../../target/accel_core/tests/",test_name,"/trk_accel_mul_data.log"},"w");
end
//
assign PcQ100H = accel_core_top.PcQ100H;

logic DMemRdEnQ104H;
logic DMemWrEnQ104H;
logic [31:0] DMemAddressQ104H;
logic [31:0] DMemWrDataQ104H;

assign DMemWrEnQ104H = accel_core_top.mini_core.mini_core_ctrl.CtrlQ104H.DMemWrEn;
assign DMemRdEnQ104H = accel_core_top.mini_core.mini_core_ctrl.CtrlQ104H.DMemRdEn;
`MAFIA_DFF(DMemAddressQ104H, accel_core_top.accel_core_mem_wrap.DMemAddressQ103H , Clk)
`MAFIA_DFF(DMemWrDataQ104H,  accel_core_top.accel_core_mem_wrap.DMemWrDataQ103H  , Clk)


//tracker on memory_access operations
always @(posedge Clk) begin : memory_access_print
    if(DMemWrEnQ104H) begin
        $fwrite(trk_memory_access,"%t | %8h | write |%8h |%8h \n", $realtime, PcQ104H, DMemAddressQ104H, DMemWrDataQ104H);
    end
    if(DMemRdEnQ104H) begin
        $fwrite(trk_memory_access,"%t | %8h | read  |%8h |%8h \n", $realtime, PcQ104H, DMemAddressQ104H, accel_core_top.mini_core.mini_core_rf.RegWrDataQ104H);
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
    trk_reg_write = $fopen({"../../../target/accel_core/tests/",test_name,"/trk_reg_write_ref.log"},"w");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");
    $fwrite(trk_reg_write," Time | PC |reg_dst|  X0   ,  X1   ,  X2   ,  X3    ,  X4    ,  X5    ,  X6    ,  X7    ,  X8    ,  X9    ,  X10    , X11    , X12    , X13    , X14    , X15    , X16    , X17    , X18    , X19    , X20    , X21    , X22    , X23    , X24    , X25    , X26    , X27    , X28    , X29    , X30    , X31 \n");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");  
end

always_ff @(posedge Clk ) begin
        $fwrite(trk_reg_write,"%6d | %4h | %2d | %8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h \n"
        ,$time,            
                           PcQ104H,
                           accel_core_top.mini_core.mini_core_rf.Ctrl.RegDstQ104H,
                           accel_core_top.mini_core.mini_core_rf.Register[0],
                           accel_core_top.mini_core.mini_core_rf.Register[1],
                           accel_core_top.mini_core.mini_core_rf.Register[2],
                           accel_core_top.mini_core.mini_core_rf.Register[3],
                           accel_core_top.mini_core.mini_core_rf.Register[4],
                           accel_core_top.mini_core.mini_core_rf.Register[5],
                           accel_core_top.mini_core.mini_core_rf.Register[6],
                           accel_core_top.mini_core.mini_core_rf.Register[7],
                           accel_core_top.mini_core.mini_core_rf.Register[8],
                           accel_core_top.mini_core.mini_core_rf.Register[9],
                           accel_core_top.mini_core.mini_core_rf.Register[10],
                           accel_core_top.mini_core.mini_core_rf.Register[11],
                           accel_core_top.mini_core.mini_core_rf.Register[12],
                           accel_core_top.mini_core.mini_core_rf.Register[13],
                           accel_core_top.mini_core.mini_core_rf.Register[14],
                           accel_core_top.mini_core.mini_core_rf.Register[15],
                           accel_core_top.mini_core.mini_core_rf.Register[16],
                           accel_core_top.mini_core.mini_core_rf.Register[17],
                           accel_core_top.mini_core.mini_core_rf.Register[18],
                           accel_core_top.mini_core.mini_core_rf.Register[19],
                           accel_core_top.mini_core.mini_core_rf.Register[20],
                           accel_core_top.mini_core.mini_core_rf.Register[21],
                           accel_core_top.mini_core.mini_core_rf.Register[22],
                           accel_core_top.mini_core.mini_core_rf.Register[23],
                           accel_core_top.mini_core.mini_core_rf.Register[24],
                           accel_core_top.mini_core.mini_core_rf.Register[25],
                           accel_core_top.mini_core.mini_core_rf.Register[26],
                           accel_core_top.mini_core.mini_core_rf.Register[27],
                           accel_core_top.mini_core.mini_core_rf.Register[28],
                           accel_core_top.mini_core.mini_core_rf.Register[29],
                           accel_core_top.mini_core.mini_core_rf.Register[30],
                           accel_core_top.mini_core.mini_core_rf.Register[31]
                           );
end

// accel_mul_trk
t_buffer_inout input_vec;
t_buffer_inout output_vec;
t_buffer_weights w1;
t_buffer_weights w2;
t_buffer_weights w3;
integer mul_trk_file;
logic unsigned [7:0] matrix_col_num; 
// Assign vectors to specific instances within the module hierarchy
assign input_vec = accel_core_top.accel_core_farm.mul_inputs.input_vec;
assign output_vec = accel_core_top.accel_core_farm.mul_outputs.output_vec;
assign w1 = accel_core_top.accel_core_farm.mul_inputs.w1;
assign w2 = accel_core_top.accel_core_farm.mul_inputs.w2;
assign w3 = accel_core_top.accel_core_farm.mul_inputs.w3;
logic input_vec_in_use_ps; 
logic w1_in_use_ps; 
logic w2_in_use_ps;
logic w3_in_use_ps;
always_ff @(posedge Clk) begin
    if (Rst) begin
        input_vec_in_use_ps <= 1'b0;
        w1_in_use_ps <= 1'b0;
        w2_in_use_ps <= 1'b0;
        w3_in_use_ps <= 1'b0;
    end else begin 
        input_vec_in_use_ps <= input_vec.meta_data.in_use_by_accel;
        w1_in_use_ps <= w1.meta_data.in_use;
        w2_in_use_ps <= w2.meta_data.in_use;
        w3_in_use_ps <= w3.meta_data.in_use;
        if (!input_vec_in_use_ps &&  input_vec.meta_data.in_use_by_accel) begin
            $fwrite(trk_accel_mul_data,"*************************************************************\n");
            $fwrite(trk_accel_mul_data, "Matrix size: %0d x %0d\n",
                    input_vec.meta_data.matrix_row_num,
                    input_vec.meta_data.matrix_col_num);
            $fwrite(trk_accel_mul_data,"Input Vector is: ");
            for (int i = 0; i < input_vec.meta_data.matrix_row_num - 1; i++) begin
                $fwrite(trk_accel_mul_data, "%0d, ", input_vec.data[i]);
            end
            $fwrite(trk_accel_mul_data, "%0d\n", input_vec.data[input_vec.meta_data.matrix_row_num - 1]);
            matrix_col_num <= input_vec.meta_data.matrix_col_num;
            
        end
        if (!w1_in_use_ps &&  w1.meta_data.in_use) begin
            $fwrite(trk_accel_mul_data,"W1 Data is: ");
            for (int i = 0; i < w1.meta_data.data_len - 1; i++) begin
               $fwrite(trk_accel_mul_data,"%0d, ", w1.data[i]);
            end
            $fwrite(trk_accel_mul_data,"Bias: %0d \n", w1.data[w1.meta_data.data_len - 1]);
        end
        if (!w2_in_use_ps &&  w2.meta_data.in_use) begin
            $fwrite(trk_accel_mul_data,"W2 Data is: ");
            for (int i = 0; i < w2.meta_data.data_len - 1; i++) begin
               $fwrite(trk_accel_mul_data,"%0d, ", w2.data[i]);
            end
            $fwrite(trk_accel_mul_data,"Bias: %0d \n", w2.data[w2.meta_data.data_len - 1]);
        end
        if (!w3_in_use_ps &&  w3.meta_data.in_use) begin
            $fwrite(trk_accel_mul_data,"W3 Data is: ");
            for (int i = 0; i < w3.meta_data.data_len - 1; i++) begin
               $fwrite(trk_accel_mul_data,"%0d, ", w3.data[i]);
            end
            $fwrite(trk_accel_mul_data,"Bias: %0d \n", w3.data[w3.meta_data.data_len - 1]);
        end
        if (input_vec_in_use_ps &&  !input_vec.meta_data.in_use_by_accel) begin
           
            $fwrite(trk_accel_mul_data,"Output Vector is: ");
            for (int i = 0; i < matrix_col_num - 1; i++) begin
                $fwrite(trk_accel_mul_data, "%0d, ",output_vec.data[i]);
            end
            $fwrite(trk_accel_mul_data, "%0d\n",output_vec.data[matrix_col_num - 1]);
            $fwrite(trk_accel_mul_data,"*************************************************************\n");
        end
    end
end


// FIXME