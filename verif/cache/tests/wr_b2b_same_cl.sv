delay(1);  backdoor_fm_load();


//send 2 write requests same CL B2B that will all miss and send a single fill
delay(0); wr_req(20'h10_1_0, 32'h0000_1111, 5'd1); // write miss - send fill
delay(0); wr_req(20'h10_1_4, 32'h0000_2222, 5'd2); // write miss - Dont send fill

delay(15);
//Make sure data is read correctly:
delay(4); rd_req(20'h10_1_0, 5'd3); // read hit
delay(4); rd_req(20'h10_1_4, 5'd4); // read hit


delay(15);
//send 2 write requests same CL B2B that will hit CL
delay(0); wr_req(20'h10_1_8, 32'h0000_3333, 5'd5); // Write Hit
delay(0); wr_req(20'h10_1_C, 32'h0000_4444, 5'd6); // Write Hit

delay(15);
//Make sure data is read correctly:
delay(4); rd_req(20'h10_1_8, 5'd7); // read hit
delay(4); rd_req(20'h10_1_C, 5'd8); // read hit
