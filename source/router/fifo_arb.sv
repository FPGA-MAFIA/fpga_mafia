
-//File Name: fifo_arbiter.sv
-//Description: The fifo_arbiter module.
-
-module fifo_arb (
input  logic clk,
input  logic rst,
//==============================
//  New alloc from neighber Tiles
//==============================
// Input
input  logic             valid_alloc_req0,
input  logic             valid_alloc_req1,
input  logic             valid_alloc_req2,
input  logic             valid_alloc_req3,
input  t_tile_trans      alloc_req0,
input  t_tile_trans      alloc_req1,
input  t_tile_trans      alloc_req2,
input  t_tile_trans      alloc_req3,
// Output
output logic             out_ready_fifo0,
output logic             out_ready_fifo1,
output logic             out_ready_fifo2,
output logic             out_ready_fifo2,
//==============================
//  Output to next north tile
//==============================
// Output
output t_tile_trans     winner_req,
// Input
input  logic             in_ready_arb_fifo0,
input  logic             in_ready_arb_fifo1,
input  logic             in_ready_arb_fifo2,
input  logic             in_ready_arb_fifo3
)


endmodule
