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
        $fwrite(fabric_top_trk," Time  || Cardinal || from ||  to: ||  ADDRESS   || opcode ||   DATA  ||   requestor_id  ||  next_tile \n");
        $fwrite(fabric_top_trk,"--------------------------------------------------------------------------------------------------\n");
    end //if
end // initial


always @(posedge clk) begin
//==================================================
// tracker of the fabric Top Level Interface
//==================================================
for(int col =1 ; col < 4; col++) begin
    for(int row =1 ; row < 4; row++) begin
        if(v_in_north_valid[col][row])begin
            $fwrite(fabric_top_trk,"%t  Going South  [%0d,%0d]->[%0d,%0d]     %h       %-7s    %h     %h           %-7s \n",
            $realtime,
            col,
            row-1, // tile id 
            col,
            row, // tile id 
            v_in_north_req[col][row].address[31:0],  
            v_in_north_req[col][row].opcode.name(), 
            v_in_north_req[col][row].data , 
            v_in_north_req[col][row].requestor_id,
            v_in_north_req[col][row].next_tile_fifo_arb_id.name()
            );      
        end
        if(v_in_south_valid[col][row])begin
            $fwrite(fabric_top_trk,"%t  Going North  [%0d,%0d]->[%0d,%0d]     %h       %-7s    %h     %h           %-7s \n",
            $realtime,
            col,
            row+1, // tile id 
            col,
            row, // tile id 
            v_in_south_req[col][row].address[31:0],  
            v_in_south_req[col][row].opcode.name(), 
            v_in_south_req[col][row].data , 
            v_in_south_req[col][row].requestor_id,
            v_in_south_req[col][row].next_tile_fifo_arb_id.name()
            );      
        end
        if(v_in_west_valid[col][row])begin
            $fwrite(fabric_top_trk,"%t  Going East   [%0d,%0d]->[%0d,%0d]     %h       %-7s    %h     %h           %-7s \n",
            $realtime,
            col-1,
            row, // tile id 
            col,
            row, // tile id 
            v_in_west_req[col][row].address[31:0],  
            v_in_west_req[col][row].opcode.name(), 
            v_in_west_req[col][row].data , 
            v_in_west_req[col][row].requestor_id,
            v_in_west_req[col][row].next_tile_fifo_arb_id.name()
            );      
        end
        if(v_in_east_valid[col][row])begin
            $fwrite(fabric_top_trk,"%t  Going West   [%0d,%0d]->[%0d,%0d]     %h       %-7s    %h     %h           %-7s \n",
            $realtime,
            col+1,
            row, // tile id 
            col,
            row, // tile id 
            v_in_east_req[col][row].address[31:0],  
            v_in_east_req[col][row].opcode.name(), 
            v_in_east_req[col][row].data , 
            v_in_east_req[col][row].requestor_id,
            v_in_east_req[col][row].next_tile_fifo_arb_id.name()
            );      
        end

      end // for loop
    end //for loop
end

