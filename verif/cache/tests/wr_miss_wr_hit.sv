delay(1);  backdoor_fm_load();


delay(6);  wr_req(20'h10_10_8, 32'hBBBB_BECC, 5'd1); // write miss - send fill
delay(6); wr_req(20'h10_10_4, 32'hCCCC_CCCC, 5'd2); // write miss - MB, no new fill request

//Extra delay to the rd_req to let the time to the wr_fill to complete
delay(20); rd_req(20'h10_10_4, 5'd3); //should hit Cache, should return CCCC_CCCC

