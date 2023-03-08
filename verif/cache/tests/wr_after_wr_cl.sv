delay(1);  backdoor_fm_load();

delay(3);  wr_req(20'h10_10_0, 32'hAAAA_AAAA, 5'd1); // write miss - send fill
delay(4);  wr_req(20'h10_10_4, 32'hBBBB_BBBB, 5'd2); // write miss - MB, no new fill request
delay(4);  wr_req(20'h10_10_8, 32'hCCCC_CCCC, 5'd3); // write miss/hit  - MB?, no new fill request
delay(4);  wr_req(20'h10_10_C, 32'hDDDD_DDDD, 5'd4); // write miss/hit  - MB?, no new fill request
/// wait then send reads to make sure the data is correct
delay(4);  rd_req(20'h10_10_0, 5'd5); //should hit Cache, should not send fill_req
delay(4);  rd_req(20'h10_10_4, 5'd6); //should hit Cache, should not send fill_req
delay(4);  rd_req(20'h10_10_8, 5'd7); //should hit Cache, should not send fill_req
delay(4);  rd_req(20'h10_10_C, 5'd8); //should hit Cache, should not send fill_req
