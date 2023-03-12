module router_tb;
import router_pkg::*;
logic              clk;
logic              rst;
logic        [3:0] valid_alloc_req;
t_tile_trans [3:0] alloc_req;
logic        [3:0] out_ready_fifo;
t_tile_trans       winner_req;
logic        [3:0] in_ready_arb_fifo;
logic              winner_valid;

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
.winner_valid       (winner_valid),
.in_ready_arb_fifo0 (in_ready_arb_fifo[0]),
.in_ready_arb_fifo1 (in_ready_arb_fifo[1]),
.in_ready_arb_fifo2 (in_ready_arb_fifo[2]),
.in_ready_arb_fifo3 (in_ready_arb_fifo[3])
);
always_comb begin
for(int i = 0 ; i<4 ; i++) begin
alloc_req[i].data = i;
alloc_req[i].address = i;
alloc_req[i].opcode = WR;
alloc_req[i].requestor_id = '0;
alloc_req[i].next_tile_fifo_arb_id = NORTH;
end
end
task delay(input int cycles);
  for(int i =0; i< cycles; i++) begin
    @(posedge clk);
  end
endtask
task push_fifo(input int num_fifo);
  $display("%t, push_fifo %d",$time, num_fifo);
  valid_alloc_req[num_fifo] = 1'b1;
  delay(1);
  valid_alloc_req[num_fifo] = '0;
endtask

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
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
    fork
      push_fifo(0);
      push_fifo(1);
      push_fifo(2);
      push_fifo(3);
    join
  delay(30);
  $finish;
end

//initial begin : timeout_monitor
//  #100000
//  $fatal(1, "Timeout");
//end

endmodule

