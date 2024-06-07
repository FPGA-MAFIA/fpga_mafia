// generating non deterministic back pressure at non deterministic times

delay(30);
random = $urandom_range(1, 10);

$display("Back pressure will be activated :%1d times", random);
for(int i=0; i <random; i++) begin
    #(50*random)  // deactivate back pressure time
    $display("Back presure activated at: %t", $time);
    force big_core_top.big_core_mem_wrap.DMemReady = 1'b0; 
    #(10*random)  // deactivate back pressure time
    $display("Back presure deactivated at: %t", $time);
    release big_core_top.big_core_mem_wrap.DMemReady;
end

