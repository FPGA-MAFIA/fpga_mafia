// reg_file tracking
integer reg_file;
initial begin: reg_file_gen
    reg_file = $fopen({"../../../target/ex_core/tests/", test_name, "/reg_file.log"}, "w");
    $fwrite(reg_file, "-----------------------------------------\n");
    $fwrite(reg_file, "Pc|         |RegDst|    |RegWrData| \t \n");
    $fwrite(reg_file, "-----------------------------------------\n");
end

always @(posedge Clk) begin: reg_file_gen_trk
    if (ex_core.RegWrEnQ102H) begin
        $fwrite(reg_file, "%8h    %8h   %8h\n",
                ex_core.PcQ100H,
                ex_core.RegDstQ102H,
                ex_core.RegWrDataQ102H);
    end
end

// alu_file tracking
integer alu_file;
initial begin: alu_file_gen
    alu_file = $fopen({"../../../target/ex_core/tests/", test_name, "/alu_file.log"}, "w");
    $fwrite(alu_file, "--------------------------------------------\n");
    $fwrite(alu_file, "Pc|         |AluIn1|    |AluIn2|    |AluOut| \t \n");
    $fwrite(alu_file, "---------------------------------------------\n");
end

always @(posedge Clk) begin: alu_file_gen_trk
    $fwrite(alu_file, "%8h    %8h   %8h   %8h\n",
            ex_core.PcQ100H,
            ex_core.AluIn1Q101H,
            ex_core.AluIn2Q101H,
            ex_core.AluOutQ102H);
end
