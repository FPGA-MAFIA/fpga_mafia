
`include "macros.vh"

module accel_core_mul_top 
import accel_core_pkg::*;
(
    input logic Clock,
    input logic Rst,
    inout t_buffer_inout input,
    inout t_buffer_weights w1,
    inout t_buffer_weights w2,
    inout t_buffer_weights w3,
    inout t_buffer_inout output
);

logic clear_m1;
logic start_m1;
t_l8_array weight_m1_data;
logic signed [7:0] result_m1;
logic out_valid_m1;

accel_core_mul_wrapper m1 (
      .Clock(Clock),
      .Rst(Rst),
      .clear(clear_m1),
      .start(start_m1),
      .neuron_in(neuron_in),
      .w1(weight_m1_data),
      .result(result_m1),
      .out_valid(out_valid_m1)
  );

logic clear_m2;
logic start_m2;
t_l8_array weight_m2_data;
logic signed [7:0] result_m2;
logic out_valid_m2;

  accel_core_mul_wrapper m2 (
      .Clock(Clock),
      .Rst(Rst),
      .clear(clear_m2),
      .start(start_m2),
      .neuron_in(neuron_in),
      .w1(weight_m2_data),
      .result(result_m2),
      .out_valid(out_valid_m2)
  );
logic 
always_comb mux begin // the logic which assigns the weight buffer to each mul
    if(Rst) begin
        weight_m1_data = '0;
        weight_m2_data = '0;
    end
    else begin
        case (m1_assign)
            W1: weight_m1_data = w1.data;
            W2: weight_m1_data = w2.data;
            W3: weight_m1_data = w3.data;
        endcase
        case (m2_assign)
            W1: weight_m2_data = w1.data;
            W2: weight_m2_data = w2.data;
            W3: weight_m3_data = w3.data;
        endcase
    end
end

endmodule
