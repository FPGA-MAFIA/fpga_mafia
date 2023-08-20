`include "macros.sv"
module big_core_kbd_gray_fifo
import common_pkg::*;
(
    input  logic       kbd_clk_write,
    input  logic       core_clk_read,
    input  logic       Rst,
    input  logic       write_en,
    input  logic       read_en,
    input  logic [7:0] data_in,
    output logic [7:0] data_out
);
localparam int DEPTH = 4;
localparam int ADDR_BITS = $clog2(DEPTH);

logic [7:0] mem[0:DEPTH-1];
logic [ADDR_BITS-1:0] gray_write_addr;
logic [ADDR_BITS-1:0] gray_read_addr;
logic gray_read_addr_next, gray_write_addr_next;

always_comb begin
    gray_read_addr_next  = gray_read_addr;
    gray_write_addr_next = gray_write_addr;
    if (write_en) `MAFIA_BINARY_TO_GRAY(gray_write_addr_next,(gray_write_addr_next+1));
    if (read_en)  `MAFIA_BINARY_TO_GRAY(gray_read_addr_next, (gray_read_addr_next+1 ));
end

`MAFIA_EN_RST_DFF(gray_write_addr, gray_write_addr_next, kbd_clk_write, write_en, Rst) 
`MAFIA_EN_RST_DFF(gray_read_addr,  gray_read_addr_next , core_clk_read, read_en,  Rst) 

`MAFIA_EN_RST_DFF(mem[gray_write_addr], data_in, kbd_clk_write , write_en, Rst) 
`MAFIA_EN_RST_DFF(data_out, mem[gray_read_addr], core_clk_read , read_en , Rst) 
endmodule