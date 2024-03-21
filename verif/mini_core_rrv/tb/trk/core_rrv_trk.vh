integer reg_file;
initial begin: reg_file_gen
    reg_file = $fopen({"../../../target/mini_core_rrv/tests/",test_name,"/reg_file.log"},"w");
    $fwrite(reg_file, "-----------------------------------------\n");
    $fwrite(reg_file, "Pc|         |RedDst|    |RegWrData| \t \n");
    $fwrite(reg_file, "-----------------------------------------\n");
end

always @(posedge Clock) begin : reg_file_gen_trk
    if(mini_core_rrv_top.mini_core_rrv.mini_core_rrv_ctrl.CtrlRf.RegWrEnQ102H)
        $fwrite(reg_file,"%8h    %8h   %8h\n",
        mini_core_rrv_top.mini_core_rrv.mini_core_rrv_wb.PcQ102H,
        mini_core_rrv_top.mini_core_rrv.mini_core_rrv_ctrl.CtrlRf.RegDstQ102H,
        mini_core_rrv_top.mini_core_rrv.mini_core_rrv_wb.RegWrDataQ102H
       );

end


integer alu_file;
initial begin: alu_file_gen
    alu_file = $fopen({"../../../target/mini_core_rrv/tests/",test_name,"/alu_file.log"},"w");
    $fwrite(alu_file, "-----------------------------------------\n");
    $fwrite(alu_file, "Pc|         |AluIn1|    |AluIn2| \t \n");
    $fwrite(alu_file, "-----------------------------------------\n");
end

always @(posedge Clock) begin : alu_file_gen_trk
        $fwrite(alu_file,"%8h    %8h   %8h\n",
        mini_core_rrv_top.mini_core_rrv.mini_core_rrv_alu.PcQ101H,
        mini_core_rrv_top.mini_core_rrv.mini_core_rrv_alu.AluIn1Q101H,
        mini_core_rrv_top.mini_core_rrv.mini_core_rrv_alu.AluIn2Q101H
        
       );

end