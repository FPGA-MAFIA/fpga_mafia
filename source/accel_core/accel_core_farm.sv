

`include "macros.vh"

module accel_core_farm
import accel_core_pkg::*;
import mini_core_pkg::*;
(
    input logic Clk,
    input logic Rst,
    input logic [7:0] xor_inp1,
    input logic [7:0] xor_inp2,
    output logic [7:0] xor_result,
    input accel_inputs_t mul_inputs,
    output accel_outputs_t mul_outputs
);

accel_core_xor accel_core_xor (
    .Rst(Rst),
    .x(xor_inp1),
    .y(xor_inp2),
    .out(xor_result)
);

accel_core_mul_top mul_accel (
    .Clock         (Clk),
    .Rst           (Rst),
    .input_vec     (mul_inputs.input_vec),
    .w1            (mul_inputs.w1),
    .w2            (mul_inputs.w2),
    .w3            (mul_inputs.w3),
    .output_vec    (mul_outputs.output_vec),
    .release_w1    (mul_outputs.release_w1),
    .release_w2    (mul_outputs.release_w2),
    .release_w3    (mul_outputs.release_w3),
    .move_out_to_in(mul_outputs.move_out_to_in),
    .done_layer    (mul_outputs.done_layer)
);

endmodule