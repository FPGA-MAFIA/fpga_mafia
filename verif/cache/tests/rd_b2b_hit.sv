delay(1);  backdoor_fm_load();

rd_req(20'h10_1_0, 5'd1);  // read miss - send fill

delay(20); //wait for fill

//send 2 read requests same CL B2B that will hit
delay(0); rd_req(20'h10_1_0, 5'd2); //should hit
delay(0); rd_req(20'h10_1_4, 5'd3); //should hit