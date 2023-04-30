//-----------------------------------------------------------------------------
// Title            : fifo_arb_trk
// Project          : fpga_mafia
//-----------------------------------------------------------------------------
// File             : fifo_arb_trk.vh
// Original Author  : Shmuel Sfez
// Code Owner       : 
// Created          : 3/2023
//-----------------------------------------------------------------------------
// Description :
// Create the differents Trackers for our fifo_arb   
//-----------------------------------------------------------------------------





integer fifo_arb_top_trk;
integer full_empty_trk;

logic [3:0] sample_empty;
logic [3:0] empty_changed;


initial begin
    delay(1); // wait for the test to start
    if(fifo_arb_test_true) begin
        if ($value$plusargs ("STRING=%s", test_name))
            $display("creating tracker in test directory: target/router/tests/%s", test_name);
        $timeformat(-12, 0, "", 6);

        fifo_arb_top_trk    = $fopen({"../../../target/router/tests/",test_name,"/fifo_arb_top_trk.log"},"w");
        full_empty_trk      = $fopen({"../../../target/router/tests/",test_name,"/full_empty_trk.log"},"w");
        $fwrite(fifo_arb_top_trk, "==================================================================================\n");
        $fwrite(fifo_arb_top_trk, "                      FIFO_ARB TOP TRACKER  -  Test: ",test_name,"\n");
        $fwrite(fifo_arb_top_trk, "==================================================================================\n");
        $fwrite(fifo_arb_top_trk,"-----------------------------------------------------------------------------------\n");
        $fwrite(fifo_arb_top_trk," Time  || input from fifo: ||  ADDRESS        || opcode ||DATA|| requestor_id  || next_tile \n");
        $fwrite(fifo_arb_top_trk,"-----------------------------------------------------------------------------------\n");
    end// if fifo_arb_test_true
end //initial begin

always @(posedge clk) begin
//==================================================
// tracker of the fifo_arb Top Level Interface
//==================================================
    for(int i =0 ; i < 4; i++) begin
        if(valid_alloc_req[i] != '0) begin // if there is any valid req
            $fwrite(fifo_arb_top_trk,"%t     input to fifo     %0d    %h       %-7s %h     %h      %s \n",
            $realtime, 
            i,
            alloc_req[i].address,  
            alloc_req[i].opcode.name(), 
            alloc_req[i].data , 
            alloc_req[i].requestor_id,
            alloc_req[i].next_tile_fifo_arb_id);      
        end
    end //for loop
    if(winner_req_valid) begin
        $fwrite(fifo_arb_top_trk,"%t     output from fifo %4b  %h       %-7s %h     %h      %s \n",
        $realtime, 
        fifo_arb_ins.fifo_pop,
        winner_req.address,  
        winner_req.opcode.name(), 
        winner_req.data , 
        winner_req.requestor_id,
        winner_req.next_tile_fifo_arb_id);  
    end
    for(int i =0 ; i < 4; i++) begin
        if(!out_ready_fifo[i]) begin
            $fwrite(full_empty_trk,"%t     FULL INDICATION  - FIFO[%0h] \n",
            $realtime,
            i
            );
        end //if !out_ready_fifo[i]
        //access the empty signal using XMR - Cross Module Reference
        if (empty_changed[i]) begin
            $fwrite(full_empty_trk,"%t     EMPTY INDICATION Update - FIFO[%0h]  | fifo_arb_ins.empty[%0h] = %0h  \n",
            $realtime, 
            i,
            i,
            fifo_arb_ins.empty[i]
            );
        end //if empty_changed[i]
    end //for loop
    end    

`MAFIA_DFF(sample_empty, fifo_arb_ins.empty,clk)
assign empty_changed = sample_empty ^ fifo_arb_ins.empty;

