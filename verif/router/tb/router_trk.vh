//-----------------------------------------------------------------------------
// Title            : router_trk
// Project          : fpga_mafia
//-----------------------------------------------------------------------------
// File             : router_trk.vh
// Original Author  : 
// Code Owner       : 
// Created          : 3/2023
//-----------------------------------------------------------------------------
// Description :
// 
//-----------------------------------------------------------------------------





integer router_top_trk;

initial begin

    if ($value$plusargs ("STRING=%s", test_name))
        $display("creating tracker in test directory: target/router/tests/%s", test_name);
    $timeformat(-12, 0, "", 6);
    
    router_top_trk    = $fopen({"../../../target/router/tests/",test_name,"/router_top_trk.log"},"w");
    $fwrite(router_top_trk, "==================================================================================\n");
    $fwrite(router_top_trk, "                      ROUTER TOP TRACKER  -  Test: ",test_name,"\n");
    $fwrite(router_top_trk, "==================================================================================\n");
    $fwrite(router_top_trk,"--------------------------------------------------------------------------------------------------\n");
    $fwrite(router_top_trk," Time  || input Cardinal: ||  ADDRESS   || opcode ||   DATA  ||   requestor_id  ||  next_tile \n");
    $fwrite(router_top_trk,"--------------------------------------------------------------------------------------------------\n");

end

always @(posedge clk) begin
//==================================================
// tracker of the fifo_arb Top Level Interface
//==================================================
    for(int i =1 ; i < 6; i++) begin
        if(input_gen_valid[i]) begin // if there is any valid req
            $fwrite(router_top_trk,"%t     input to fifo     %0d    %h       %-7s %h     %h      %s \n",
            $realtime, 
            t_cardinal'(i).name(),
            input_gen[i].address,  
            input_gen[i].opcode.name(), 
            input_gen[i].data , 
            input_gen[i].requestor_id,
            input_gen[i].next_tile_fifo_arb_id.name()
            );      
        end
    end //for loop
end    


