$display("Finished elaborating the design...");
 // for(int i = 1; i<= V_COL; i++) begin
 //   for(int j = 1; j<= V_ROW; j++) begin
 //        automatic int col = i;
 //        automatic int row = j;
 //        fork begin
 //           automatic t_tile_id source;
 //           automatic int rand_cycles;
 //           automatic int cnt_wr;
 //           source[7:4] = col;
 //           source[3:0] = row;
 //          // $display("this is ceil, V_REQ = %0d, V_REQ/2_ceil = %0d",V_REQUESTS,$ceil(V_REQUESTS/2));
 //          mini_core_ready_bit[col][row] = 1'b0;
 //          force mini_core_ready = mini_core_ready_bit;
 //           for(int i=0; i< $ceil(V_REQUESTS/2); i++) begin
 //               cnt_wr = cnt_wr + 1;
 //               //$display("time: %0t trans cnt_wr1 = %0d",$time,cnt_wr);
 //               wait(tile_ready[col][row] == 5'b11111);// naive implementation only when all ready are 1 we can insert a new trans.
 //               rand_cycles = $urandom_range(10,V_NUM_CYCLES+10);//TODO - need to see how to implement stress mode, for now not working very good. 
 //               //if WR and RD_RSP are coming together at the same time the checker dont know how to handle it very well.
 //               send_rand_req_from_tile(source,cnt_wr);
 //               delay(rand_cycles);
 //           end
 //           release mini_core_ready[col][row];
 //           for(int i=0; i< $ceil(V_REQUESTS/2); i++) begin
 //               cnt_wr = cnt_wr + 1;
 //               //$display("time: %0t trans cnt_wr2 = %0d",$time,cnt_wr);
 //               wait(tile_ready[col][row] == 5'b11111);// naive implementation only when all ready are 1 we can insert a new trans.
 //               rand_cycles = $urandom_range(10,V_NUM_CYCLES+10);//TODO - need to see how to implement stress mode, for now not working very good. 
 //               //if WR and RD_RSP are coming together at the same time the checker dont know how to handle it very well.
 //               send_rand_req_from_tile(source,cnt_wr);
 //               delay(rand_cycles);
 //           end
 //        end  join
 //   end
 // end
 //sending direct requests

//sending random requests

//for(int i=0; i< $ceil(V_REQUESTS); i++) begin
//    wait(tile_ready[3][3] == 5'b11111);
//    send_rand_req_from_tile(.source(8'h3_3),.cnt_wr(1));
//    delay(10);
//end
//force mini_core_ready[3][3] = 1'b1;
//delay(1);
//for(int i=0; i< $ceil(V_REQUESTS); i++) begin
//    wait(tile_ready[3][3] == 5'b11111);
//    send_rand_req_from_tile(.source(8'h3_3),.cnt_wr(1));
//    $display("send_req_force at time %0t",$time);
//    delay(1);
//end
//
////force mini_core_ready[3][3] = 1'b1;
//release mini_core_ready[3][3];
//for(int i=0; i< $ceil(V_REQUESTS); i++) begin
//    wait(tile_ready[3][3] == 5'b11111);
//    send_rand_req_from_tile(.source(8'h3_3),.cnt_wr(1));
//    $display("send_req_release at time %0t",$time);
//    delay(1);
//end
for(int i=0; i< $ceil(V_REQUESTS); i++) begin
wait(tile_ready[1][1] == 5'b11111);
send_req(.source_id(8'h1_1), .target_id(8'h3_3), .opcode(WR));
delay(10);
end

force fabric.col[3].row[3].mini_core_tile_ins.mini_top.mini_mem_wrap.mini_core_ready = 1'b0;
//force mini_core_ready[3][3] = 1'b0;
$display("send force at time %0t real signal is: %0b and mini_core_ready is %0b",$time,fabric.col[3].row[3].mini_core_tile_ins.mini_top.mini_mem_wrap.mini_core_ready,mini_core_ready[3][3]);
$display("send force at time %0t real signal is: %0b and mini_core_ready is %0b",$time,`MINI_CORE_TILE_READY(3,3));
for(int i=0; i< $ceil(V_REQUESTS); i++) begin
fork
wait(tile_ready[1][1] == 5'b11111);
begin delay(100);
flg = 1; end
join_any
if(flg == 1'b1) begin 
  $display("full fabric at time %0t with %0d req in pipe",$time,i);
  break;
end
send_req(.source_id(8'h1_1), .target_id(8'h3_3), .opcode(WR));
delay(10);
end

delay(10);
//release mini_core_ready[3][3];
//release fabric.col[3].row[3].mini_core_tile_ins.mini_top.mini_mem_wrap.mini_core_ready;
//release `MINI_CORE_TILE_READY(3,3);
$display("send release at time %0t real signal is: %0b and mini_core_ready is %0b",$time,fabric.col[3].row[3].mini_core_tile_ins.mini_top.mini_mem_wrap.mini_core_ready,mini_core_ready[3][3]);
//$display("release force at time %0t",$time);
delay(100);
for(int i=0; i< $ceil(V_REQUESTS); i++) begin
wait(tile_ready[1][1] == 5'b11111);
$display("time %0t real signal is: %0b and mini_core_ready is %0b",$time,fabric.col[3].row[3].mini_core_tile_ins.mini_top.mini_mem_wrap.mini_core_ready,mini_core_ready[3][3]);
send_req(.source_id(8'h1_1), .target_id(8'h3_3), .opcode(WR));
delay(10);
end

  delay(100);