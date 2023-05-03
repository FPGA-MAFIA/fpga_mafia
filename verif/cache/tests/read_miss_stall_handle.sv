delay(1);  backdoor_fm_load();

// in this sequence will need to make sure the no new request are served until the a read miss is completed

// first writing to the cache to address 0x10_10_0 - will miss and fill to 0x10_10_0
delay(1);  wr_req(20'h10_10_0, 32'hAAAA_AAAA, 5'd1); // write miss/hit  - MB?, no new fill request
//delay(0);  wr_req(20'h10_10_4, 32'hBBBB_BBBB, 5'd2); // write miss/hit  - MB?, no new fill request
//delay(0);  wr_req(20'h10_10_8, 32'hCCCC_CCCC, 5'd3); // write miss/hit  - MB?, no new fill request
//delay(0);  wr_req(20'h10_10_c, 32'hDDDD_DDDD, 5'd4); // write miss/hit  - MB?, no new fill request

// =======================================================================
// Reading a different address 0x11_11_0 - will miss and fill to 0x11_11_0
delay(15);  rd_req(20'h11_11_0, 5'd5); //should hit Cache, should not send fill_req

// with a low delay we will read the same address 0x10_10_0 - will hit the cache 
delay(1);  rd_req(20'h10_10_0, 5'd6); //should hit Cache, - but only handle after the previous read miss is completed
//delay(0);  rd_req(20'h10_10_4, 5'd6); //should hit Cache, - but only handle after the previous read miss is completed
//delay(0);  rd_req(20'h10_10_8, 5'd6); //should hit Cache, - but only handle after the previous read miss is completed
//delay(0);  rd_req(20'h10_10_c, 5'd6); //should hit Cache, - but only handle after the previous read miss is completed

delay(10);