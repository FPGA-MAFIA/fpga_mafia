`include "macros.vh"

// ./build.py -dut mini_core_accel -hw -sim -top neuron_mac_output_tb -gui &
module neuron_mac_output_tb;
import mini_core_accel_pkg::*;

logic       clk;
logic       rst;
t_neuron_mac_input_data neuron_mac_input_data;
t_neuron_mac_output_data neuron_mac_output_data;

// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end // forever
end // initial clock_gen

neuron_mac_output neuron_mac_output 
(
    .clk(clk),
    .rst(rst),
    .neuron_mac_input_data(neuron_mac_input_data),
    .neuron_mac_output_data(neuron_mac_output_data)
);

integer index;

initial begin : main_tb
    for(index=0; index < 8; index++) begin
        neuron_mac_input_data.mul_result[index] = 1;
    end
    rst  = 0;
    neuron_mac_input_data.bias = 8'd101;

    #10

    $finish();    
end

parameter V_TIMEOUT = 1000;
initial begin :timeout
    #V_TIMEOUT
    $display("reached time out!!!");
    $finish();
end




endmodule