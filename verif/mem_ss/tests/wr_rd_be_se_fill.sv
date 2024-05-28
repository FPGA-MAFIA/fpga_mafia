// write and read partial words
delay(5);   wr_req(20'hE1_01_0, 32'h1111_1111 , 5'b0);
delay(5);   wr_req(20'hE2_01_0, 32'h2222_2222 , 5'b0);
delay(5);   wr_req(20'hE3_01_0, 32'h3333_3333 , 5'b0);
delay(5);   wr_req(20'hE4_01_0, 32'h4444_4444 , 5'b0);
delay(5);   wr_req(20'hE5_01_0, 32'h5555_5555 , 5'b0);

delay(5);   rd_req_lb(20'hE1_01_0, 5'd1);
