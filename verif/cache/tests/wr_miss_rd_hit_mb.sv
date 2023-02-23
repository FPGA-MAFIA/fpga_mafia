delay(1);  backdoor_fm_load();

delay(5);   wr_req(20'h10_10_8, 32'hDEAD_BEEF, 5'd1);
delay(6);  rd_req(20'h10_10_8, 5'd2);