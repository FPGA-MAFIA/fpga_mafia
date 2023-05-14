// File Name: fifo.sv
// Description: The fifo module.
// Push indicates that the data is valid will be pushed into the fifo.
// Pop indicates that the data will be popped out of the fifo.
// The push_data is the data to be pushed into the fifo.
// The pop_data is the data to be popped out of the fifo.
// The full indicates that the fifo is full.
// The empty indicates that the fifo is empty.

`include "macros.sv"
module fifo #(parameter int DATA_WIDTH = 8, 
           	  parameter int FIFO_DEPTH = 3)
    (
    input  logic                   clk,
    input  logic                   rst,
    input  logic                   push,
    input  logic[DATA_WIDTH-1:0]   push_data,
    input  logic                   pop,
    output logic [DATA_WIDTH-1:0]  pop_data,
    output logic                   full,
    output logic                   empty
    );

localparam MSB_PTR = $clog2(FIFO_DEPTH)-1;

logic [FIFO_DEPTH-1:0] [DATA_WIDTH-1:0] fifo_array;
logic [FIFO_DEPTH-1:0] [DATA_WIDTH-1:0] next_fifo_array;
logic [MSB_PTR:0] rd_ptr;
logic [MSB_PTR:0] next_rd_ptr;
logic [MSB_PTR:0] wr_ptr;
logic [MSB_PTR:0] next_wr_ptr;

// The FIFO flop array:
`MAFIA_DFF(fifo_array, next_fifo_array,    clk)

`MAFIA_RST_DFF(rd_ptr, next_rd_ptr, clk, rst)
`MAFIA_RST_DFF(wr_ptr, next_wr_ptr, clk, rst)

//Empty and full signals
assign empty = (wr_ptr == rd_ptr);
assign full  = ((wr_ptr > rd_ptr) ? (wr_ptr == (rd_ptr + FIFO_DEPTH - 1)): (wr_ptr == (rd_ptr - 1'b1)));
always_comb begin : fifo_array_assign
    //default values:
    next_fifo_array = fifo_array;
    next_rd_ptr = rd_ptr;
    next_wr_ptr = wr_ptr;
    if (push) begin
        next_fifo_array[wr_ptr] = push_data;
        next_wr_ptr = (wr_ptr != (FIFO_DEPTH - 1)) ? (wr_ptr + 1) : '0;
    end
    pop_data = fifo_array[rd_ptr];
    if (pop) begin
        next_rd_ptr = (rd_ptr != (FIFO_DEPTH - 1)) ? (rd_ptr + 1) : '0;
    end
end
// Assertion for push when full
//assert property (@(posedge clk) disable iff (rst) (full |-> !push)) else $error("Push when full"); // iff -> if and only if.

// Assertion for pop when empty
//assert property (@(posedge clk) disable iff (rst) (empty |-> !pop)) else $error("Pop when empty");
// Assertion for push when full

`ifdef SIM_ONLY
`ASSERT("Push when full", full && push, !rst, "Push when full");
`ASSERT("Pop when empty", empty && pop, !rst, "Pop when empty");
`endif


endmodule : fifo

