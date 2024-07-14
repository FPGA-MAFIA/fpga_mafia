//tracker performance monitor operations

integer trk_performance;
logic [31:0] ClockCounter;
logic [31:0] ValidInstQ104HCounter;
real result_ipc;

initial begin
    trk_performance = $fopen({"../../../target/mini_core_accel/tests/",test_name,"/trk_performance.log"},"w");
end

always_ff @(posedge Clk) begin : trk_performance_gen_calc
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

task print_performance();
    $fwrite(trk_performance,"---------------------------------------------------------\n");
    $fwrite(trk_performance,"               Performance monitor                       \n");
    $fwrite(trk_performance,"---------------------------------------------------------\n");  
    $fwrite(trk_performance,"Test name: ", test_name, "\n");
    $fwrite(trk_performance,"The number of valid instructions is: %1d\n", ValidInstQ104HCounter);
    $fwrite(trk_performance,"The number of Cycles is: %1d\n", ClockCounter);
    result_ipc = $itor(ValidInstQ104HCounter) / $itor(ClockCounter);
    $fwrite(trk_performance,"IPC(instruction per cycles) =  %f", $sformatf("%.3f", result_ipc));
endtask