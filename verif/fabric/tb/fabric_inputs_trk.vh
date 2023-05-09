//-----------------------------------------------------------------------------
//Project          : fpga_mafia
//-----------------------------------------------------------------------------
// File             : fabric_trk.vh
// Original Author  : shmuel sfez
// Code Owner       : 
// Created          : 5/2023
//-----------------------------------------------------------------------------
// Description :
// 
//-----------------------------------------------------------------------------





integer fabric_top_trk;

initial begin
    delay(1); // wait for the test to start
    if(fabric_test_true) begin
        if ($value$plusargs ("STRING=%s", test_name))
            $display("creating tracker in test directory: target/fabric/tests/%s", test_name);
        $timeformat(-12, 0, "", 6);
    
        fabric_top_trk    = $fopen({"../../../target/fabric/tests/",test_name,"/fabric_top_trk.log"},"w");
        $fwrite(fabric_top_trk, "==================================================================================\n");
        $fwrite(fabric_top_trk, "                      FABRIC TOP TRACKER  -  Test: ", test_name,"\n");
        $fwrite(fabric_top_trk, "==================================================================================\n");
        $fwrite(fabric_top_trk,"--------------------------------------------------------------------------------------------------\n");
        $fwrite(fabric_top_trk," Time  || Tile || in/out || from/to: ||  ADDRESS   || opcode ||   DATA  ||   requestor_id  ||  next_tile \n");
        $fwrite(fabric_top_trk,"--------------------------------------------------------------------------------------------------\n");
    end //if
end // initial


always @(posedge clk) begin
//==================================================
// tracker of the fabric Top Level Interface
//==================================================
for(int i =1 ; i < 6; i++) begin
    for(int j =1 ; j < 6; j++) begin
        if(v_in_north_valid[i][j] || v_in_south_valid[i][j] || v_in_east_valid[i][j] || v_in_west_valid[i][j])begin// || fabric.in_south_req_valid(i,j) || fabric.in_east_req_valid(i,j) || fabric.in_west_req_valid(i,j)) begin // if there is any valid req
            $fwrite(fabric_top_trk,"%t  [%d,%d] input       %h       %-7s %h     %h      %-7s \n",
            $realtime,
            i,
            j, // tile id 
            v_in_north_req[i][j].address[23:0],  
            v_in_north_req[i][j].opcode.name(), 
            v_in_north_req[i][j].data , 
            v_in_north_req[i][j].requestor_id,
            v_in_north_req[i][j].next_tile_fifo_arb_id.name()
            );      
        end
      end // for loop
    end //for loop
end

