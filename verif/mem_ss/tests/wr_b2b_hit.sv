delay(1);  backdoor_fm_load();

wr_req(20'h10_1_0, 32'h0000_1111, 5'd1);  // write miss - send fill

delay(20); //wait for fill

//send 2 write requests same CL B2B that will hit
delay(0); wr_req(20'h10_1_0, 32'h0000_1111, 5'd2); //should hit
delay(0); wr_req(20'h10_1_4, 32'h0000_2222, 5'd3); //should hit