delay(1);  backdoor_fm_load();
//This should miss the cache and go to FM.
delay(5);  rd_req(20'h10_10_4, 5'd1);
//This should hit the cache
delay(50); rd_req(20'h10_10_4, 5'd2);

//This should hit the CL and write new data in offset word 1 (byte 4)
delay(5);  wr_req(20'h10_10_4, 32'hABBA_BABA, 5'd3);


//This should hit the cache line
delay(5);  rd_req(20'h10_10_0, 5'd4);
//This should hit the cache line -return new data!
delay(5);  rd_req(20'h10_10_4, 5'd5);
//This should hit the cache line
delay(5);  rd_req(20'h10_10_8, 5'd6);