// write and read partial words
delay(0);   wr_req_sb(20'hE8_01_0, 32'hDEAD_BEAF , 5'b0);
delay(0);   wr_req_sh(20'hE9_01_0, 32'hABCD_1234 , 5'b1);
delay(0);   rd_req_lbu(20'hE8_01_0, 5'd1); 
delay(0);   rd_req_lb(20'hE8_01_0, 5'd1);
delay(0);   rd_req_lhu(20'hE9_01_0, 5'd2); 
delay(0);   rd_req_lh(20'hE9_01_0, 5'd2);
