// generating non deterministic back pressure at non deterministic times

    random = $urandom_range(10, 100); // Set the number of back pressure events

    // random = 7'd65; // Set the number of back pressure events
    $display("Back pressure will be activated: %1d times", random);
    for (i = 0; i < random; i++) begin
        $display("Loop iteration: %d, Time: %t", i, $time);
        repeat (random) @(posedge Clk); // Reduce the number for debugging
        $display("Back pressure activated at: %t", $time);
        force big_core_top.big_core_mem_wrap.DMemReady = 1'b0;
        
        repeat (random) @(posedge Clk); // Reduce the number for debugging
        $display("Back pressure deactivated at: %t", $time);
        release big_core_top.big_core_mem_wrap.DMemReady;
        
        repeat (random) @(posedge Clk); // Ensure we have a shorter loop for debugging
    end





