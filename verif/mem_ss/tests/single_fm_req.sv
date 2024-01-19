delay(1);  backdoor_fm_load();
//This should miss the cache and go to FM.
delay(5);   rd_req(20'h10_10_0, 5'd1);
//This should hit the cache
delay(50);   rd_req(20'h10_10_0, 5'd1);