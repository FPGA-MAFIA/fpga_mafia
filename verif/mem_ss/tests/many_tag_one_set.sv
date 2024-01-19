delay(1);  backdoor_fm_load();


//send 8 write requests that will all miss and send fills
// all requests are to the same set with different tags
// First for will fill the set: ) tags 01,02,03,04
delay(7); wr_req(20'h01_55_0, 32'h0000_1111, 5'd1); // write miss - send fill
delay(7); wr_req(20'h02_55_0, 32'h0000_2222, 5'd2); // write miss - send fill
delay(7); wr_req(20'h03_55_0, 32'h0000_3333, 5'd3); // write miss - send fill
delay(7); wr_req(20'h04_55_0, 32'h0000_4444, 5'd4); // write miss - send fill
// Second for will miss,and the fill will evict the first 4 requests. tags 05,06,07,08
delay(7); wr_req(20'h05_55_0, 32'h0000_5555, 5'd5); // write miss - send fill
delay(7); wr_req(20'h06_55_0, 32'h0000_6666, 5'd6); // write miss - send fill
delay(7); wr_req(20'h07_55_0, 32'h0000_7777, 5'd7); // write miss - send fill
delay(7); wr_req(20'h08_55_0, 32'h0000_8888, 5'd8); // write miss - send fill
// Next we read to make sure all is coherent
//First 4 reads will miss due to the evicts, then the fill will reallocate the tags 01,02,03,04
delay(7); rd_req(20'h01_55_0, 5'd9); // read hit
delay(7); rd_req(20'h02_55_0, 5'd10); // read hit
delay(7); rd_req(20'h03_55_0, 5'd11); // read hit
delay(7); rd_req(20'h04_55_0, 5'd12); // read hit
// Next 4 reads will hit or miss, depending on the on the fill latency.
delay(7); rd_req(20'h05_55_0, 5'd13); // read hit
delay(7); rd_req(20'h06_55_0, 5'd14); // read hit
delay(7); rd_req(20'h07_55_0, 5'd15); // read hit
delay(7); rd_req(20'h08_55_0, 5'd16); // read hit

