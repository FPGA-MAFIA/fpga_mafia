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
t_buffer_weights weight_m1;
logic signed [7:0] result_m1;
logic out_valid_m1;
t_buffer_sel assign_m1;

accel_core_mul_wrapper m1 (
      .Clock(Clock),
      .Rst(Rst),
      .clear(clear_m1),
      .start(start_m1),
      .neuron_in(neuron_in),
      .w1(weight_m1),
      .result(result_m1),
      .out_valid(out_valid_m1)
  );

logic clear_m2;
logic start_m2;
t_buffer_weights weight_m2;
logic signed [7:0] result_m2;
logic out_valid_m2;
t_buffer_sel assign_m2;

  accel_core_mul_wrapper m2 (
      .Clock(Clock),
      .Rst(Rst),
      .clear(clear_m2),
      .start(start_m2),
      .neuron_in(neuron_in),
      .w1(weight_m2),
      .result(result_m2),
      .out_valid(out_valid_m2)
  );

logic move_out_to_in;
logic clear_output;
logic done_layer;
accel_core_mul_controller mul_controller (
    .Clock(Clock),
    .Rst(Rst),
    .input_metadata(input.meta_data),
    .w1_metadata(w1.meta_data),
    .w2_metadata(w2.meta_data),
    .w3_metadata(w3.meta_data),
    .out_metadata(output.meta_data),
    .move_out_to_in(move_out_to_in),
    .done_layer(done_layer),
    .clear_output(clear_output),
    ///////// m1 port
    .clear_m1(clear_m1),
    .start_m1(start_m1),
    .assign_m1(assign_m1),
    .out_valid_m1(out_valid_m1),
    ///////// m2 port
    .clear_m2(clear_m2),
    .start_m2(start_m2),
    .assign_m2(assign_m2),
    .out_valid_m2(out_valid_m2)
);

always_comb mux_in begin // the logic which assigns the weight buffer to each mul
    if(Rst) begin
        weight_m1 = '0;
        weight_m2 = '0;
    end
    else begin
        case (assign_m1)
            W1: weight_m1 = w1;
            W2: weight_m1 = w2;
            W3: weight_m1 = w3;
        endcase
        case (assign_m2)
            W1: weight_m2 = w1;
            W2: weight_m2 = w2;
            W3: weight_m2 = w3;
        endcase
    end
end
always_comb mux_out begin // assigns the result to the output
    if(Rst || clear_output) begin
        output.data = '0; // Reset output data
        curr_neuron_idx = 0;
        done_layer = 0;
    end
    else begin
        done_layer = 0;
        if(out_valid_m1) begin
            output.data[weight_m1.neuron_idx] = result_m1;
            case (assign_m1)
                W1: begin
                    w1_metadata.in_use = 1'b0;
                    if (w1_metadata.neuron_idx >= input.matrix_row_num) begin
                        done_layer = 1;
                    end
                end
                W2: begin
                    w2_metadata.in_use = 1'b0;
                    if (w2_metadata.neuron_idx >= input.matrix_row_num) begin
                        done_layer = 1;
                    end
                end
                W3: begin
                    w3_metadata.in_use = 1'b0;
                    if (w3_metadata.neuron_idx >= input.matrix_row_num) begin
                        done_layer = 1;
                    end
                end
                default: ;
            endcase

        end
        if(out_valid_m2) begin
            output.data[weight_m2.neuron_idx] = result_m2;
            case (assign_m2_tmp)
                W1: begin
                    w1_metadata.in_use = 1'b0;
                    if (w1_metadata.neuron_idx >= input.matrix_row_num) begin
                        done_layer = 1;
                    end
                end
                W2: begin
                    w2_metadata.in_use = 1'b0;
                    if (w2_metadata.neuron_idx >= input.matrix_row_num) begin
                        done_layer = 1;
                    end
                end
                W3: begin
                    w3_metadata.in_use = 1'b0;
                    if (w3_metadata.neuron_idx >= input.matrix_row_num) begin
                        done_layer = 1;
                    end
                end
                default: ;
            endcase
        end
    end
end
always_comb out_to_in begin
    if(mov_out_to_in)
        output = input;
end

endmodule
