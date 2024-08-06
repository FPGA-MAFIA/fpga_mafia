integer pmon_file;
real instret_high_low_real;
real cycle_high_low_real;
real result_ipc, result_cpi;

logic InstCommit;
assign InstCommit = accel_core_top.mini_core.mini_core_ctrl.ValidInstQ104H;
real cycle_count;
real valid_inst_count;

//task count_inst_and_clk();
  //  begin
    //      end
//endtask
always @(posedge Clk) begin
      if(Rst) begin
            cycle_count = 0;
            valid_inst_count = 0;
      end
      else begin
            cycle_count = cycle_count + 1;
            if (InstCommit) begin
                  valid_inst_count = valid_inst_count + 1;
            end
      end
end


 task track_performance();
 pmon_file = $fopen({"../../../target/accel_core/tests/",test_name,"/trk_cpi_ipc.log"},"w"); 
       $fdisplay(pmon_file,"===========================================");
       $fdisplay(pmon_file,"PMON tracker for ", test_name, " test");
       $fdisplay(pmon_file,"Monitoring IPC and CPI");
       $fdisplay(pmon_file,"==========================================");
       $fdisplay(pmon_file,"\nSummary report");
       $fdisplay(pmon_file,"---------------------");
       $fdisplay(pmon_file, "Number of cycles: %1d\nNumber of valid instructions: %1d",cycle_count, valid_inst_count);
       
       // calculatin IPC and CPI
       instret_high_low_real = valid_inst_count;
       cycle_high_low_real = cycle_count;
       result_ipc = instret_high_low_real / cycle_high_low_real;
       result_cpi = cycle_high_low_real / instret_high_low_real;
       $fdisplay(pmon_file, "IPC(instruction per cycles) =  %f", $sformatf("%.3f", result_ipc));
       $fdisplay(pmon_file, "IPC[%%] =  %f", $sformatf("%.3f", result_ipc*100));
       $fdisplay(pmon_file, "CPI(cycles per instruction) =  %f", $sformatf("%.3f", result_cpi));
       $fclose(pmon_file);
 endtask;     
 
