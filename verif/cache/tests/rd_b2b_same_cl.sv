delay(1);  backdoor_fm_load();


//send 2 read requests same CL B2B, first one should miss, set stall and send fill
delay(0); rd_req(20'h10_1_0, 5'd1); // read miss - send fill + stall
delay(0); rd_req(20'h10_1_4, 5'd2);  //not suppose to happen, re-issue buffer, until stall disable

