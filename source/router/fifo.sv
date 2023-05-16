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
           	  parameter int FIFO_DEPTH = 4)
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

//=============================================================================
// Empty and full signals
//=============================================================================
// In this implementation - if the fifo of size 2 we have a problem due to the bit overflow when comparing rd_ptr-1 and wr_ptr
// This is why we added the "FIFO_DEPTH - 1" in the comparison - but this is not a good solution
// assign empty = (wr_ptr == rd_ptr);
// assign full  = ((wr_ptr > rd_ptr) ? (wr_ptr == (rd_ptr + FIFO_DEPTH - 1)): (wr_ptr == (rd_ptr - 1'b1)));

//=============================================================================
// An alternative solution is to use a counter:
//=============================================================================
logic [MSB_PTR:0] count;
logic [MSB_PTR:0] next_count;
`MAFIA_RST_DFF(count, next_count, clk, rst)
always_comb begin
    next_count = count;
    unique casez ({push, pop})
        2'b00: next_count = count;
        2'b01: next_count = count - 1'b1; // protected with the assertion below
        2'b10: next_count = count + 1'b1; // protected with the assertion below
        2'b11: next_count = count;
    endcase
end // always_comb
assign empty = (count == 0); 
assign full  = (count == FIFO_DEPTH-1);

//=============================================================================
//=============================================================================
//=============================================================================
`ifdef SIM_ONLY
`ASSERT("Push when full", full && push, !rst, "Push when full");
`ASSERT("Pop when empty", empty && pop, !rst, "Pop when empty");
// Assertion for push when full
//assert property (@(posedge clk) disable iff (rst) (full |-> !push)) else $error("Push when full"); // iff -> if and only if.
// Assertion for pop when empty
//assert property (@(posedge clk) disable iff (rst) (empty |-> !pop)) else $error("Pop when empty");
// Assertion for push when full
`endif


endmodule : fifo

