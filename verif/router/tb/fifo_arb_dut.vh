logic        [3:0] valid_alloc_req;
t_tile_trans [3:0] alloc_req;
logic        [3:0] out_ready_fifo;
t_tile_trans       winner_req;
logic        [3:0] in_ready_arb_fifo;
logic              winner_req_valid;
logic        [1:0] src_num; // the decimal number of fifo


`include "fifo_arb_trk.vh"

fifo_arb fifo_arb_ins(
.clk                (clk),
.rst                (rst),
.valid_alloc_req0   (valid_alloc_req[0]),
.valid_alloc_req1   (valid_alloc_req[1]),
.valid_alloc_req2   (valid_alloc_req[2]),
.valid_alloc_req3   (valid_alloc_req[3]),
.alloc_req0         (alloc_req[0]),
.alloc_req1         (alloc_req[1]),
.alloc_req2         (alloc_req[2]),
.alloc_req3         (alloc_req[3]),
.out_ready_fifo0    (out_ready_fifo[0]),
.out_ready_fifo1    (out_ready_fifo[1]),
.out_ready_fifo2    (out_ready_fifo[2]),
.out_ready_fifo3    (out_ready_fifo[3]),
.winner_req         (winner_req),
.winner_req_valid       (winner_req_valid),
.in_ready_arb_fifo0 (in_ready_arb_fifo[0]),
.in_ready_arb_fifo1 (in_ready_arb_fifo[1]),
.in_ready_arb_fifo2 (in_ready_arb_fifo[2]),
.in_ready_arb_fifo3 (in_ready_arb_fifo[3])
);



//defalut value for the inputs
//always_comb begin
//    for(int i = 0 ; i<4 ; i++) begin
//      alloc_req[i] = input_gen[i];
//       // alloc_req[i].data = i+10;
//       // alloc_req[i].address = i+10;
//       // alloc_req[i].opcode = WR;
//       // alloc_req[i].requestor_id = '0+10;
//       // alloc_req[i].next_tile_fifo_arb_id = NORTH;
//    end
//    //`ENCODER(num_of_fifo,1,valid_alloc_req)
//end





/*initial begin
if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
if(test_name == "fifo_arb_diff_num_activ_fifo") begin
$display("================\n     START\n================\n");
    rst = 1'b1;
    for(int i =0; i<4 ; i++) begin
      valid_alloc_req[i] = '0;
    end
    delay(10);
    rst = '0;
    delay(10);
    push_fifo(0);
    delay(10);
    push_fifo(0);
    delay(10);
    //forever begin
      for (int num_of_fifo=0; num_of_fifo<4; num_of_fifo++) begin
       push_fifo(num_of_fifo);
       delay(100);
      end
    //end
    // fork // - hard to work with trk's.
    //   push_fifo(0);
    //   push_fifo(1);
    //   push_fifo(2);
    //   push_fifo(3);
    // join
  delay(30);
  $finish;

end// if alive
end*/