// generating non deterministic back pressure at non deterministic times

delay(30);
random = $urandom_range(1, 10);

$display("%d", random);
for(int i=0; i <random; i++) begin
    $display("Back presure activated at: %t", $time);
    force big_core_top.big_core_mem_wrap.DMemReady = 1'b0; 
    delay(10*random);
    $display("Back presure deactivated at: %t", $time);
    release big_core_top.big_core_mem_wrap.DMemReady;
end

