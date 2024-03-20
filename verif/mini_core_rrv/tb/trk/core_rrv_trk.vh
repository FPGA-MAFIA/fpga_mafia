integer reg_file;
initial begin: reg_file_gen
    reg_file = $fopen({"../../../target/mini_core_rrv/tests/",test_name,"/trk_inst.log"},"w");
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