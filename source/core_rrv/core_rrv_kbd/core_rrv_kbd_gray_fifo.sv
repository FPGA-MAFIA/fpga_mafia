`include "macros.sv"
module core_rrv_kbd_gray_fifo
import core_rrv_pkg::*;
(
    input  logic       kbd_clk_write,
    input  logic       core_clk_read,
    input  logic       rst_kc,
    input  logic       write_en,
    input  logic [7:0] data_in,
    // core clock domain
    input  logic       read_en,
    output logic       data_valid,
    output logic [7:0] data_out
);
localparam int DEPTH = 4;
localparam int ADDR_BITS = $clog2(DEPTH);
logic full, empty;

logic [7:0] mem[DEPTH-1:0];
logic [ADDR_BITS-1:0] gray_write_addr, gray_write_addr_next;
logic [ADDR_BITS-1:0] gray_read_addr, gray_read_addr_next;

assign full = (gray_write_addr == (gray_read_addr ^ (1 << ADDR_BITS)));
assign empty = (gray_read_addr == gray_write_addr);

always_comb begin
    data_valid = 1'b0;
    gray_read_addr_next  = gray_read_addr;
    gray_write_addr_next = gray_write_addr;
    if (write_en) begin
        `MAFIA_BINARY_TO_GRAY(gray_write_addr_next,(gray_write_addr_next+1));
        data_valid = 1'b1;
    end
    if (read_en)  `MAFIA_BINARY_TO_GRAY(gray_read_addr_next, (gray_read_addr_next+1 ));
end


`MAFIA_EN_ASYNC_RST_VAL_DFF(gray_write_addr      , gray_write_addr_next , (write_en & ~full), 1'b1, rst_kc, 1'b0) 
`MAFIA_EN_ASYNC_RST_VAL_DFF(gray_read_addr       , gray_read_addr_next  , (read_en & ~empty), 1'b1, rst_kc, 1'b0) 
`MAFIA_EN_ASYNC_RST_VAL_DFF(mem[gray_write_addr] , data_in              , (write_en & ~full), 1'b1, rst_kc, 1'b0) 
`MAFIA_EN_ASYNC_RST_VAL_DFF(data_out             , mem[gray_read_addr]  , (read_en & ~empty), 1'b1, rst_kc, 1'b0) 
endmodule