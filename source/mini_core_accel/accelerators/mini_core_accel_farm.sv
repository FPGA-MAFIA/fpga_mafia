`include "macros.vh"

module mini_core_accel_farm 
import mini_core_pkg::*;
import mini_core_accel_pkg::*;
#(parameter MUL_NUM = 16, NEURON_MAC_NUM = 2)
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

genvar neuron_mac_index;
generate
    for(neuron_mac_index = 0; neuron_mac_index < NEURON_MAC_NUM; neuron_mac_index++) begin : neuron_mac_inst
        neuron_mac neuron_mac (
            .clk(clock),
            .rst(rst),
            .neuron_mac_input(accel_farm_input.int8_mul2neuron_mac[neuron_mac_index]),
            .neuron_mac_output(accel_farm_output.neuron_mac_result[neuron_mac_index])
        );

    end
endgenerate


endmodule

