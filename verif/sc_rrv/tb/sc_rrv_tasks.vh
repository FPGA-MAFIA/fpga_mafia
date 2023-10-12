//======================================
// Track register task
//======================================
integer i;
task trk_rf();
    $fwrite(trk_rf_pointer,"{");
    for(i=0; i <32; i=i+1) begin
        $fwrite(trk_rf_pointer,"%1h, ", sc_top.core.Register[i]);
    end
    $fwrite(trk_rf_pointer, "}. Pc = %1h. Instruction: %h, time: %0t ns", sc_top.core.Pc, sc_top.core.Instruction, $time);
    $fdisplay(trk_rf_pointer, "\n");
endtask