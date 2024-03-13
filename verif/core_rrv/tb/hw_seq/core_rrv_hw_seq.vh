
//this is included in the main TB - will drive all the HW sequencer
// will note that in simple tests we use backdoor to drive the instruction memory of the core
// But in some cases, we want real HW IO to drive sequences of the CPU that are not "SW - instruction memory" driven.

initial begin
// initial values;
ps2_clk  = 1;
ps2_data = 1;
//Check which test we are running, then include the appropriate testbench
if ($value$plusargs ("STRING=%s", test_name)) begin
    $display("STRING value %s", test_name);
end

$display("================\n     START\n================\n");

if(test_name == "PS2_alive")   begin  
    $display("================\n   PS2_alive was included to the run  \n================\n");
    `include "PS2_alive.vh"    
end 

else if(test_name == "PS2_alive_2") begin
    $display("=====\n PS2_alive_2 was included to the run\n ====\n");   
    `include "PS2_alive_2.vh"  
end


else if(test_name == "PS2_long_shift") begin
    $display("=====\n PS2_long_shift was included to the run\n ====\n");   
    `include "PS2_long_shift.vh"  
end
else if(test_name == "PS2_compare") begin
    $display("=====\n PS2_long_shift was included to the run\n ====\n");   
    `include "PS2_compare.vh"  
end

else if(test_name == "PS2_fibbonacci") begin
    $display("=====\n PS2_fibbonacci was included to the run\n ====\n");   
    `include "PS2_fibbonacci.vh"  
end

else begin 
    $display("=====\n No HW sequence logic were included to the run\n ====\n");
end

end
