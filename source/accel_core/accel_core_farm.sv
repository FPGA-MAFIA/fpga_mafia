

`include "macros.vh"

module accel_core_farm
import accel_core_pkg::*;
import mini_core_pkg::*;
(
    input logic Clk,
    input logic Rst,
    input logic [7:0] xor_inp1,
    input logic [7:0] xor_inp2,
    output logic [7:0] xor_result
);

accel_core_xor accel_core_xor (
    .Rst(Rst),
    .x(xor_inp1),
    .y(xor_inp2),
    .out(xor_result)
);

endmodule