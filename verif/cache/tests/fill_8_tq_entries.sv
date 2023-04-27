delay(1);  backdoor_fm_load();


//send 8 write requests that will all miss and send fills
delay(0); wr_req(20'h10_01_0, 32'h0000_1111, 5'd1); // write miss - send fill
delay(0); wr_req(20'h10_02_0, 32'h0000_2222, 5'd2); // write miss - send fill
delay(0); wr_req(20'h10_03_0, 32'h0000_3333, 5'd3); // write miss - send fill
delay(0); wr_req(20'h10_04_0, 32'h0000_4444, 5'd4); // write miss - send fill
delay(0); wr_req(20'h10_05_0, 32'h0000_5555, 5'd5); // write miss - send fill
delay(0); wr_req(20'h10_06_0, 32'h0000_6666, 5'd6); // write miss - send fill
delay(0); wr_req(20'h10_07_0, 32'h0000_7777, 5'd7); // write miss - send fill
delay(0); wr_req(20'h10_08_0, 32'h0000_8888, 5'd8); // write miss - send fill
delay(0); wr_req(20'h10_09_0, 32'h0000_9999, 5'd8); // write miss - send fill
delay(0); wr_req(20'h10_0A_0, 32'h0000_AAAA, 5'd8); // write miss - send fill

//delay(20);
//read the data back
//FIXME - we still have to debug this to put back on delay 0
delay(0); rd_req(20'h10_01_0, 5'd9);  // read hit
delay(0); rd_req(20'h10_02_0, 5'd10); // read hit
delay(0); rd_req(20'h10_03_0, 5'd11); // read hit
delay(0); rd_req(20'h10_04_0, 5'd12); // read hit
delay(0); rd_req(20'h10_05_0, 5'd13); // read hit
delay(0); rd_req(20'h10_06_0, 5'd14); // read hit
delay(0); rd_req(20'h10_07_0, 5'd15); // read hit
delay(0); rd_req(20'h10_08_0, 5'd16); // read hit
delay(0); rd_req(20'h10_09_0, 5'd16); // read hit
delay(0); rd_req(20'h10_0A_0, 5'd16); // read hit

