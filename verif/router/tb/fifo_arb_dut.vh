logic        [3:0] valid_alloc_req;
t_tile_trans [3:0] alloc_req;
logic        [3:0] out_ready_fifo;
t_tile_trans       winner_req;
logic        [3:0] in_ready_arb_fifo;
logic              winner_req_valid;
logic        [1:0] src_num; // the decimal number of fifo


`include "fifo_arb_trk.vh"

fifo_arb #(.FIFO_ARB_FIFO_DEPTH(V_FIFO_DEPTH)) fifo_arb_ins(
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
