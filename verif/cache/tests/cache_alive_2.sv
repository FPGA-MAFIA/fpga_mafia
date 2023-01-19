//preload Cache
delay(1); backdoor_cache_load();
delay(5);   wr_req(20'hE8_01_0, 32'hDEAD_BEAF , 5'b0);
delay(5);   wr_req(20'hE9_01_0, 32'hFAFA_FAFA , 5'b1);
delay(5);   wr_req(20'hEA_01_0, 32'hBABA_BABA , 5'b1);
delay(5);   rd_req(20'hE8_01_0, 5'd1);
delay(5);   rd_req(20'hE9_01_0, 5'd2);
delay(5);   rd_req(20'hEA_01_0, 5'd3);
// Same CL (same TAG 'E8', SAME SET '5'), different words (1,2,3):
delay(5);   wr_req(20'hE8_05_4, 32'h4444_4444 , 5'b0);
delay(5);   wr_req(20'hE8_05_8, 32'h8888_8888 , 5'b1);
delay(5);   wr_req(20'hE8_05_C, 32'hCCCC_CCCC , 5'b1);
delay(5);   rd_req(20'hE8_05_4, 5'd1);
delay(5);   rd_req(20'hE8_05_8, 5'd2);
delay(5);   rd_req(20'hE8_05_C, 5'd3);