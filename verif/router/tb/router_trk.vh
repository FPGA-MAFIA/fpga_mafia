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
    $fwrite(router_top_trk," Time  || in/out || from/to: ||  ADDRESS   || opcode ||   DATA  ||   requestor_id  ||  next_tile \n");
    $fwrite(router_top_trk,"--------------------------------------------------------------------------------------------------\n");

end

t_cardinal [5:1] gen_cardinal;
assign gen_cardinal[1] = t_cardinal'(1);
assign gen_cardinal[2] = t_cardinal'(2);
assign gen_cardinal[3] = t_cardinal'(3);
assign gen_cardinal[4] = t_cardinal'(4);
assign gen_cardinal[5] = t_cardinal'(5);
always @(posedge clk) begin
//==================================================
// tracker of the fifo_arb Top Level Interface
//==================================================
    for(int i =1 ; i < 6; i++) begin
        if(input_gen_valid[i]) begin // if there is any valid req
            $fwrite(router_top_trk,"%t   input      %-7s     %h_%h       %-7s %h     %h      %-7s \n",
            $realtime, 
            gen_cardinal[i].name(),
            input_gen[i].address[31:24],  
            input_gen[i].address[23:0],  
            input_gen[i].opcode.name(), 
            input_gen[i].data , 
            input_gen[i].requestor_id,
            input_gen[i].next_tile_fifo_arb_id.name()
            );      
        end
        if(output_gen_valid[i]) begin // if there is any valid req
            $fwrite(router_top_trk,"%t   output     %-7s     %h_%h       %-7s %h     %h      %-7s \n",
            $realtime, 
            gen_cardinal[i].name(),
            output_gen[i].address[31:24],  
            output_gen[i].address[23:0],  
            output_gen[i].opcode.name(), 
            output_gen[i].data , 
            output_gen[i].requestor_id,
            output_gen[i].next_tile_fifo_arb_id.name()
            );      
        end
    end //for loop
end    


