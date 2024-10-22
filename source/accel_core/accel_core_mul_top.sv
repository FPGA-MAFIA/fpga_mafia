`include "macros.vh"
module accel_core_mul_top 
import accel_core_pkg::*;
(
    input logic Clock,
    input logic Rst,
    input t_buffer_inout input_vec,
    input t_buffer_weights w1,
    input t_buffer_weights w2,
    input t_buffer_weights w3,
    output t_buffer_inout output_vec,
    output logic release_w1,
    output logic release_w2,
    output logic release_w3,
    output logic move_out_to_in,
    output logic done_layer
);
t_buffer_inout output_vec_tmp;


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
      .neuron_in(input_vec),
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
      .neuron_in(input_vec),
      .w1(weight_m2),
      .result(result_m2),
      .out_valid(out_valid_m2)
  );

logic clear_output;
accel_core_mul_controller mul_controller (
    .Clock(Clock),
    .Rst(Rst),
    .input_metadata(input_vec.meta_data),
    .w1_metadata(w1.meta_data),
    .w2_metadata(w2.meta_data),
    .w3_metadata(w3.meta_data),
    .out_metadata(output_vec_tmp.meta_data),
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
    .out_valid_m2(out_valid_m2),
    ///////// release
    .release_w1(release_w1),
    .release_w2(release_w2),
    .release_w3(release_w3)
);

always_comb begin //mux_in - the logic which assigns the weight buffer to each mul
    if(Rst) begin
        weight_m1 = FREE;
        weight_m2 = FREE;
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
always_comb begin // mux_out - assigns the result to the output
    if(Rst || clear_output) begin
        output_vec_tmp.data = '0; // Reset output data
        done_layer = 0;
    end
    else begin
        done_layer = 0;
        if(out_valid_m1) begin
            output_vec_tmp.data[weight_m1.meta_data.neuron_idx] = result_m1;
            case (assign_m1)
                W1: begin
                    if (w1.meta_data.neuron_idx >= input_vec.meta_data.matrix_col_num - 1) begin
                        done_layer = 1;
                    end
                end
                W2: begin
                    if (w2.meta_data.neuron_idx >= input_vec.meta_data.matrix_col_num - 1) begin
                        done_layer = 1;
                    end
                end
                W3: begin
                    if (w3.meta_data.neuron_idx >= input_vec.meta_data.matrix_col_num - 1) begin
                        done_layer = 1;
                    end
                end
                default: ;
            endcase

        end
        if(out_valid_m2) begin
            output_vec_tmp.data[weight_m2.meta_data.neuron_idx] = result_m2;
            case (assign_m2)
                W1: begin
                    if (w1.meta_data.neuron_idx >= input_vec.meta_data.matrix_col_num - 1) begin
                        done_layer = 1;
                    end
                end
                W2: begin
                    if (w2.meta_data.neuron_idx >= input_vec.meta_data.matrix_col_num - 1) begin
                        done_layer = 1;
                    end
                end
                W3: begin
                    if (w3.meta_data.neuron_idx >= input_vec.meta_data.matrix_col_num - 1) begin
                        done_layer = 1;
                    end
                end
                default: ;
            endcase
        end
    end
end
assign output_vec = output_vec_tmp;
endmodule
