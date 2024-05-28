// write and read partial words
delay(5);   wr_req(20'hE1_01_0, 32'h12312312 , 5'b0);
delay(5);   wr_req(20'hE2_01_0, 32'h23423423 , 5'b0);
delay(5);   wr_req(20'hE3_01_0, 32'h34534534 , 5'b0);
delay(5);   wr_req(20'hE4_01_0, 32'h45645645 , 5'b0);
delay(5);   wr_req(20'hE5_01_0, 32'h56756756 , 5'b0);

delay(30);   rd_req_lb(20'hE1_01_1, 5'd1);
