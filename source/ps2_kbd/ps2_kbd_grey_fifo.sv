//-----------------------------------------------------------------------------
// Title            : FIFO
// Project          : PS2 keyboard
//-----------------------------------------------------------------------------
// File             : 
// Original Author  : Amichai Ben-David
// Created          : 3/2024
//-----------------------------------------------------------------------------
// Description :
// Implementation of FIFO with two clock domains. To decrease a probability for 
// metastability we use two FF synchronizer and Encodes write/read pointers
// to grey code
//------------------------------------------------------------------------------
// Modification history :
//------------------------------------------------------------------------------

`include "macros.sv"
module ps2_kbd_grey_fifo #(parameter DEPTH = 16,
                           parameter WIDTH = 8)
(
    input logic              kbd_clk, // kbd_clock
    input logic              cc_clk,  // core_clock 
    input logic [WIDTH-1:0]  data_in,
    input logic              write_en,
    input logic              read_en,
    input logic              rst,
    output logic [WIDTH-1:0] data_out,
    output logic             empty,
    output logic             full
);

// The width of write and read pointer will be 1 bit more then the required address
// This will allow us to compare if the fifo is full or empty 
logic [$clog2(DEPTH):0] write_ptr, read_ptr;
logic [$clog2(DEPTH):0] write_ptr_next, read_ptr_next;

// fifo memory
logic [WIDTH-1:0] mem[0:DEPTH-1];

always_comb begin : pointer_logic
    write_ptr_next = write_ptr;
    read_ptr_next  = read_ptr;
    if(write_en & !full) begin
        write_ptr_next = write_ptr + 1;
    end
    if(read_en & !empty) begin
        read_ptr_next = read_ptr + 1;
    end
end

logic write_ptr_msb;
assign write_ptr_msb = write_ptr[$clog2(DEPTH)];

assign empty = (write_ptr == read_ptr);
assign full  = ({!write_ptr_msb, write_ptr[$clog2(DEPTH)-1:0]} == read_ptr);

`MAFIA_EN_RST_DFF(write_ptr, write_ptr_next, kbd_clk, (write_en & !full), rst)
`MAFIA_EN_RST_DFF(read_ptr, read_ptr_next, cc_clk, (read_en & !empty), rst)

`MAFIA_EN_DFF(mem[write_ptr], data_in, kbd_clk, (write_en & !full))

assign data_out = mem[read_ptr];

endmodule
