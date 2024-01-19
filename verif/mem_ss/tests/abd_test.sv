//preload Cache
delay(5);   wr_req(20'hE8_01_0, 32'hDEAD_BEAF , 5'b0);

delay(20);   wr_req(20'hE8_01_4, 32'h4444_4444 , 5'b1);
delay(0);   rd_req(20'hE8_01_C, 5'd2);