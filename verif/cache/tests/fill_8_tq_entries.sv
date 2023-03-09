delay(1);  backdoor_fm_load();


//send 8 write requests that will all miss and send fills
delay(0); wr_req(20'h10_1_0, 32'h0000_1111, 5'd1); // write miss - send fill
delay(0); wr_req(20'h10_2_0, 32'h0000_2222, 5'd2); // write miss - send fill
delay(0); wr_req(20'h10_3_0, 32'h0000_3333, 5'd3); // write miss - send fill
delay(0); wr_req(20'h10_4_0, 32'h0000_4444, 5'd4); // write miss - send fill
delay(0); wr_req(20'h10_5_0, 32'h0000_5555, 5'd5); // write miss - send fill
delay(0); wr_req(20'h10_6_0, 32'h0000_6666, 5'd6); // write miss - send fill
delay(0); wr_req(20'h10_7_0, 32'h0000_7777, 5'd7); // write miss - send fill
delay(0); wr_req(20'h10_8_0, 32'h0000_8888, 5'd8); // write miss - send fill

delay(10);
//read the data back
delay(0); rd_req(20'h10_1_0, 5'd9); // read hit
delay(0); rd_req(20'h10_2_0, 5'd10); // read hit
delay(0); rd_req(20'h10_3_0, 5'd11); // read hit
delay(0); rd_req(20'h10_4_0, 5'd12); // read hit
delay(0); rd_req(20'h10_5_0, 5'd13); // read hit
delay(0); rd_req(20'h10_6_0, 5'd14); // read hit
delay(0); rd_req(20'h10_7_0, 5'd15); // read hit
delay(0); rd_req(20'h10_8_0, 5'd16); // read hit

