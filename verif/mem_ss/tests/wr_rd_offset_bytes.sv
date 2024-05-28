// write and in data in offsets

// load cache
delay(5);   wr_req(20'hE8_01_0, 32'hDEAD_BEAF , 5'b0); // write word
delay(5);   wr_req_sh(20'hE9_01_1, 32'hAAAA_FEDC , 5'b1); // write half byte offset 1
delay(5);   wr_req_sb(20'hE9_01_3, 32'hAAAA_AA12 , 5'b1); // write byte to offset 3

delay(5);   rd_req(20'hE8_01_0, 5'd1);
delay(5);   rd_req_lhu(20'hE9_01_1, 5'd2); 
delay(5);   rd_req_lh(20'hE9_01_1, 5'd2);

delay(5);   rd_req_lbu(20'hE8_01_3, 5'd1); 
delay(5);   rd_req_lb(20'hE8_01_3, 5'd1);


