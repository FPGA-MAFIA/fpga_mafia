//$display("Finished elaborating the design...");
t_tile_trans wr_rd_data_in;
t_tile_trans wr_rd_data_out;
//sending direct requests
wait(tile_ready[1][1]==5'b11111);
send_req(.source_id(8'h1_1), .target_id(8'h3_3), .opcode(WR));
wr_rd_data_in.data = origin_trans_fab[1][1].data;
$display("#### data_wr is %0h",wr_rd_data_in.data);
wait(tile_ready[1][1]==5'b11111);
delay(20);
wait(tile_ready[1][1]==5'b11111);
send_req(.source_id(8'h1_1), .target_id(8'h3_3), .opcode(RD));
wait(valid_local[1][1] == 1'b1);
wr_rd_data_out.data = target_trans[1][1].data;
$display("#### data_rd is %0h",wr_rd_data_out.data);
delay(20);
if(wr_rd_data_in.data != wr_rd_data_out.data) $error("data of trans wrong");
else $display("data trans is correct");


delay(500);