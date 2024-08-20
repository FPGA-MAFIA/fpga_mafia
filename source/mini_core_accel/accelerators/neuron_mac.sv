//==============================================================================
// perform addition of 8 multiplier + bias, then apply ReLu and saturation
//==============================================================================

`include "macros.vh"

module neuron_mac
import mini_core_accel_pkg::*;
(

    input logic                         clk,
    input logic                         rst,
    input var t_neuron_mac_in_data      neuron_mac_in_data,
    output var t_neuron_mac_out_data    neuron_mac_out_data
);

    logic signed [16:0] mac_result;
    logic signed [16:0] ReLu_result;

    assign mac_result   = $signed(neuron_mac_in_data.mul_result[0]) + $signed(neuron_mac_in_data.mul_result[1]) + 
                          $signed(neuron_mac_in_data.mul_result[2]) + $signed(neuron_mac_in_data.mul_result[3]) + 
                          $signed(neuron_mac_in_data.mul_result[4]) + $signed(neuron_mac_in_data.mul_result[5]) + 
                          $signed(neuron_mac_in_data.mul_result[6]) + $signed(neuron_mac_in_data.mul_result[7]) + 
                          $signed(neuron_mac_in_data.bias);    
    
    assign ReLu_result = (mac_result > 0) ? mac_result : 'b0;

    assign neuron_mac_out_data.int8_output = (ReLu_result > 17'sd127) ? 8'd127 : (ReLu_result < -17'sd128) ? -8'sd128 : ReLu_result[7:0];



endmodule