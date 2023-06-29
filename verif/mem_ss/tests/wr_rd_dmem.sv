//add here the alive tasks that you want to run
delay(20);   dmem_wr_req(20'h18_01_0, 32'h0000_1111, 5'd1);
delay(20);   dmem_wr_req(20'h18_01_4, 32'h0000_2222, 5'd2);
delay(20);   dmem_wr_req(20'h18_01_8, 32'h0000_3333, 5'd3);
delay(20);   dmem_wr_req(20'h18_01_C, 32'h0000_4444, 5'd4);
delay(20);   dmem_wr_req(20'h18_01_0, 32'h0000_5555, 5'd5);


delay(20);   dmem_rd_req(20'h18_01_0, 5'd6);
delay(20);   dmem_rd_req(20'h18_01_4, 5'd7);
delay(20);   dmem_rd_req(20'h18_01_8, 5'd8);
delay(20);   dmem_rd_req(20'h18_01_C, 5'd9);
delay(20);   dmem_rd_req(20'h18_01_0, 5'd10);


delay(20);