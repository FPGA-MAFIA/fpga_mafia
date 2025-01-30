// quad ram for cpu_c design

`include "cpuc_macros.vh"

module cpuc_quad_ram
import cpuc_package::*;
#(parameter ADDRESS_WIDTH, parameter DATA_WIDTH)
(
    input logic clk, 
    // data_bus
    input logic [DATA_WIDTH-1:0] din_a,
    input logic [DATA_WIDTH-1:0] din_b,
    // we
    input logic we_a,
    input logic we_b,
    // address_bus
    input logic [ADDRESS_WIDTH-1:0] addr_a,
    input logic [ADDRESS_WIDTH-1:0] addr_b,
    input logic [ADDRESS_WIDTH-1:0] addr_c,
    input logic [ADDRESS_WIDTH-1:0] addr_d,
    // data_bus
    output logic [DATA_WIDTH-1:0] dout_a,
    output logic [DATA_WIDTH-1:0] dout_b,
    output logic [DATA_WIDTH-1:0] dout_c,
    output logic [DATA_WIDTH-1:0] dout_d

);


cpuc_dual_ram
#(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH))
cpuc_dual_ram0
(
    .clk(clk),
    // port As
    .addr_a(addr_a),
    .din_a(din_a),
    .we_a(we_a),
    .dout_a(dout_a), 
    // port B
    .addr_b(addr_b),
    .din_b(din_b),
    .we_b(we_b),
    .dout_b(dout_b)
);

logic [ADDRESS_WIDTH-1:0] addr_x, addr_y;
assign addr_x = (we_a) ? addr_a : addr_c;
assign addr_y = (we_b) ? addr_b : addr_d;  

cpuc_dual_ram
#(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH))
cpuc_dual_ram1
(
    .clk(clk),
    // port As
    .addr_a(addr_x),
    .din_a(din_a),
    .we_a(we_a),
    .dout_a(dout_c), 
    // port B
    .addr_b(addr_y),
    .din_b(din_b),
    .we_b(we_b),
    .dout_b(dout_d)
);


endmodule