//======================================
// Track register task
//======================================
integer i;
task trk_rf();
    $fwrite(trk_rf_pointer,"{");
    for(i=0; i <32; i=i+1) begin
        $fwrite(trk_rf_pointer,"%1h, ", sc_top.sc_core.Register[i]);
    end
    $fwrite(trk_rf_pointer, "}. Pc = %1h. Instruction: %h, time: %0t ns", sc_top.sc_core.Pc, sc_top.sc_core.Instruction, $time);
    $fdisplay(trk_rf_pointer, "\n");
endtask

//======================================
// D_Mem signal interface tracker task
//======================================
integer j;
task trk_dmem_signals(); 
    $fdisplay(trk_dmem_signals_pointer, "Pc = %1h. Instruction: %h, time: %0t ns", sc_top.sc_core.Pc, sc_top.sc_core.Instruction, $time );
    $fdisplay(trk_dmem_signals_pointer, "DMemAddress = %1h", sc_top.sc_core.DMemAddress);
    $fdisplay(trk_dmem_signals_pointer, "DMemData = %1h", sc_top.sc_core.DMemData);
    $fdisplay(trk_dmem_signals_pointer, "DMemByteEn = %1h", sc_top.sc_core.DMemByteEn);
    $fdisplay(trk_dmem_signals_pointer, "DMemWrEn = %1h", sc_top.sc_core.DMemWrEn);
    $fdisplay(trk_dmem_signals_pointer, "DMemRdEn = %1h", sc_top.sc_core.DMemRdEn);
    $fdisplay(trk_dmem_signals_pointer, "DMemRspData = %1h", sc_top.sc_core.DMemRspData);
    $fdisplay(trk_dmem_signals_pointer, "\n\n\n");
endtask


