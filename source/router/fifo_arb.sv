
//File Name: fifo_arbiter.sv
//Description: The fifo_arbiter module.
`include "macros.sv"

module fifo_arb
 import router_pkg::*;
 #(parameter NUM_CLIENTS = 4,
   parameter FIFO_ARB_FIFO_DEPTH = 4)
(
input  logic clk,
input  logic rst,
//==============================
//  New alloc from neighbor Tiles
//==============================
// Input
input  logic             valid_alloc_req0, // can rewrite more generic with logic [NUM_CLIENTS-1:0] valid_alloc_req;
input  logic             valid_alloc_req1, // 
input  logic             valid_alloc_req2,
input  logic             valid_alloc_req3,
input var t_tile_trans   alloc_req0,
input var t_tile_trans   alloc_req1,
input var t_tile_trans   alloc_req2,
input var t_tile_trans   alloc_req3,
// Output
output logic             out_ready_fifo0,
output logic             out_ready_fifo1,
output logic             out_ready_fifo2,
output logic             out_ready_fifo3,
//==============================
//  Output to next north tile
//==============================
// Output
output var t_tile_trans winner_req,
output logic            winner_req_valid,
// Input
input  logic            in_ready_north_arb_fifo, // used by arb to choose winner
input  logic            in_ready_east_arb_fifo,
input  logic            in_ready_south_arb_fifo,
input  logic            in_ready_west_arb_fifo,
input  logic            in_ready_local_arb_fifo
);
t_tile_trans [3:0] din;
t_tile_trans [3:0] dout_fifo;

logic [3:0] push;
logic [3:0] fifo_pop;
logic [3:0] winner_dec_id;
logic [3:0] full;
logic [3:0] empty;
logic [1:0] src_num;;

always_comb begin
    din[0] = alloc_req0;
    din[1] = alloc_req1;
    din[2] = alloc_req2;
    din[3] = alloc_req3;
    push[0] = valid_alloc_req0;
    push[1] = valid_alloc_req1;
    push[2] = valid_alloc_req2;
    push[3] = valid_alloc_req3;
    out_ready_fifo0 = !full[0];
    out_ready_fifo1 = !full[1];
    out_ready_fifo2 = !full[2];
    out_ready_fifo3 = !full[3];
end

genvar i;
generate for (i=0; i<NUM_CLIENTS; i=i+1) begin : gen_fifo
    fifo #(.DATA_WIDTH($bits(t_tile_trans)),.FIFO_DEPTH(FIFO_ARB_FIFO_DEPTH))
        inside_fifo  (.clk       (clk),
                      .rst       (rst),
                      .push      (push[i]), // valid_alloc_req#
                      .push_data (din[i]),// alloc_req#
                      .pop       (fifo_pop[i]),//arbiter chose this fifo to pop.
                      .pop_data  (dout_fifo[i]), // arbiter input
                      .full      (full[i]),//out_ready_fifo#
                      .empty     (empty[i])
                     );// indication to arbiter that the fifo is empty
end endgenerate

// Setting the valid candidate for the arbiter
// to be a valid candidate for the round robin arbiter
// 1. The fifo[i] must be not empty (have data to pop)
// 2. The *target* fifo_arb must be ready to accept data
// 3. The transaction *target cardinal* must be the same as the target fifo_arb cardinal
logic [3:0] valid_candidate;
always_comb begin 
    for(int i=0; i<NUM_CLIENTS; i++ )
    valid_candidate[i] = ~empty[i] && ( (in_ready_north_arb_fifo && (dout_fifo[i].next_tile_fifo_arb_id == NORTH)) ||
                                        (in_ready_east_arb_fifo  && (dout_fifo[i].next_tile_fifo_arb_id == EAST))  ||
                                        (in_ready_south_arb_fifo && (dout_fifo[i].next_tile_fifo_arb_id == SOUTH)) ||
                                        (in_ready_west_arb_fifo  && (dout_fifo[i].next_tile_fifo_arb_id == WEST))  ||
                                        (in_ready_local_arb_fifo && (dout_fifo[i].next_tile_fifo_arb_id == LOCAL)));
end

arbiter #(
.NUM_CLIENTS(4),
.DATA_WIDTH($bits(t_tile_trans))
)
arb 
    (
    .clk(clk),
    .rst(rst),
    .valid_candidate(valid_candidate[3:0]),    // input from each fifo - not empty indication, valid candidate.
    .winner_dec_id  (winner_dec_id[3:0])  // the arbiter winner use to fifo pop.        
);
assign winner_req_valid = |winner_dec_id[3:0];

assign fifo_pop[3:0] = winner_dec_id[3:0];


`MAFIA_MUXOR(winner_req, dout_fifo, winner_dec_id)


//`ASSERT("Pop when not valid winner",fifo_pop & !winner_req_valid,!rst,"Pop fifo when not valid_req")
// =================================
// Assertion for illegal input
// =================================
// FIFO 0:
// assert if fifo is full -> no new data can be pushed. (valid_alloc_req# = 1'b1)

//// Define the property
//property push_data_when_full_prop;
//  @(posedge clk) disable iff(!rst) (full[0] == 1'b1) |-> (push[0] == 1'b0);
//endproperty
//
//// Use the property in an assertion
//assert push_data_when_full_assert: push_data_when_full_prop else $error("New data was pushed when fifo is full");
//
// If the arbiter chose a fifo to pop, the fifo must not be empty.
endmodule
