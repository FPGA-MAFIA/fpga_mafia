`include "macros.vh"

module mini_core_accel_farm 
import mini_core_pkg::*;
import mini_core_accel_pkg::*;
#(parameter MUL_NUM = 16)
(
    input logic                     clock,
    input logic                     rst,
    input var t_accel_farm_input    accel_farm_input,
    output var t_accel_farm_output  accel_farm_output
);

genvar mul_index;

generate
    for(mul_index = 0; mul_index < MUL_NUM; mul_index++) begin : multiplier_int8_inst
        multiplier_int8 multiplier_int8 (
            .clock(clock),
            .rst(rst),
            .pre_mul_int_8_input(accel_farm_input.core2mul_int8[mul_index]),
            .mul_int8_output(accel_farm_output.mul2core_int8[mul_index])
        );

    end
endgenerate


endmodule

