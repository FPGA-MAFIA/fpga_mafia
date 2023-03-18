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


initial begin

    if ($value$plusargs ("STRING=%s", test_name))
        $display("creating tracker in test directory: target/fifo_arb/tests/%s", test_name);
    $timeformat(-12, 0, "", 6);
    
    fifo_arb_top_trk      = $fopen({"../../../target/fifo_arb/tests/",test_name,"/fifo_arb_top_trk.log"},"w");
    $fwrite(fifo_arb_top_trk, "==================================================================================\n");
    $fwrite(fifo_arb_top_trk, "                      FIFO_ARB TOP TRACKER  -  Test: ",test_name,"\n");
    $fwrite(fifo_arb_top_trk, "==================================================================================\n");
    $fwrite(fifo_arb_top_trk,"-----------------------------------------------------------------------------------\n");
    $fwrite(fifo_arb_top_trk," Time  ||  OPCODE        || address ||REG/TQ_ID|| tag  || Set ||    Data \n");
    $fwrite(fifo_arb_top_trk,"-----------------------------------------------------------------------------------\n");

end

always @(posedge clk) begin
//==================================================
// tracker of the fifo_arb Top Level Interface
//==================================================
    if(valid_alloc_req != '0) begin // if there is any valid req
        $fwrite(fifo_arb_top_trk,"%t     input from fifo %0d       %h       %h        %h     %h      %s \n",
        $realtime, 
        src_num,
        alloc_req[num_of_fifo].address,  
        alloc_req[num_of_fifo].opcode, 
        alloc_req[num_of_fifo].data , 
        alloc_req[num_of_fifo].requestor_id,
        alloc_req[num_of_fifo].next_tile_fifo_arb_id);      
    end
    if(winner_valid) begin
        $fwrite(fifo_arb_top_trk,"%t     OUTPUT-WINNER FIFO       %h       %h        %h     %h      %h \n",
        $realtime, 
        winner_req.address,  
        winner_req.opcode, 
        winner_req.data , 
        winner_req.requestor_id,
        winner_req.next_tile_fifo_arb_id);  
    end
    if(out_ready_fifo != 0) begin
        $fwrite(fifo_arb_top_trk,"%t     OUTPUT-FULL INDICATION      \n",
        $realtime, 
        out_ready_fifo
        );
    end
   
    end    



