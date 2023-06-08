//add here the alive tasks that you want to run
delay(5);   dmem_wr_req(20'h18_01_0, 32'hDEAD_BEAF , 5'b0);
delay(5);   dmem_rd_req(20'h18_01_0, 5'd1);
delay(20);