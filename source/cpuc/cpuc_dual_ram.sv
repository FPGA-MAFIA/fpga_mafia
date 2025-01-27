// cpuc dual ram

`include "cpuc_macros.vh"

module cpuc_dual_ram
import cpuc_package::*;
#(parameter ADDRESS_WIDTH, parameter DATA_WIDTH)
(
    input logic clk,
    // port As
    input logic [ADDRESS_WIDTH-1:0] addr_a,
    input logic [DATA_WIDTH-1:0]    din_a,
    input logic                     we_a,
    output logic [DATA_WIDTH-1:0]   dout_a, 
    // port B
    input logic [ADDRESS_WIDTH-1:0] addr_b,
    input logic [DATA_WIDTH-1:0]    din_b,
    input logic                     we_b,
    output logic [DATA_WIDTH-1:0]   dout_b
);

    logic [DATA_WIDTH-1:0] mem [2**ADDRESS_WIDTH-1:0];
    logic [DATA_WIDTH-1:0] next_mem [2**ADDRESS_WIDTH-1:0];

    `CPUC_DFF(mem, next_mem, clk)

    always_comb begin
        next_mem = mem;
        if(we_a) next_mem[addr_a] = din_a;
        if(we_b) next_mem[addr_b] = din_b;
    end

    assign dout_a = mem[addr_a];
    assign dout_b = mem[addr_b];

endmodule