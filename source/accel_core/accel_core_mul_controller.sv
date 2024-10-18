`include "macros.vh"
module accel_core_mul_controller
import accel_core_pkg::*;
(
    input logic Clock,
    input logic Rst,
    
    // Metadata inputs for input, weights, and output
    input t_metadata_inout input_metadata,
    input t_metadata_weights w1_metadata,
    input t_metadata_weights w2_metadata,
    input t_metadata_weights w3_metadata,
    input t_metadata_inout out_metadata,

    // Control signal for moving data from output to input
    output logic move_out_to_in,
    input logic done_layer,
    output logic clear_output,

    // Control signals for m1
    output logic clear_m1,
    output logic start_m1,
    output t_buffer_sel assign_m1, // Enum for buffer selection (W1, W2, W3)
    input logic out_valid_m1,

    // Control signals for m2
    output logic clear_m2,
    output logic start_m2,
    output t_buffer_sel assign_m2,  // Enum for buffer selection (W1, W2, W3)
    input logic out_valid_m2
);

t_buffer_sel assign_m1_tmp;
t_buffer_sel assign_m2_tmp;
t_buffer_sel assign_m1_tmp_ps;
t_buffer_sel assign_m2_tmp_ps;

logic clear_m1_tmp;
logic clear_m2_tmp;
logic test;
always_comb begin
    // Default assignments
    
    if (Rst || (~(input_metadata.in_use_by_accel))) begin
        assign_m1_tmp = FREE; 
        assign_m2_tmp = FREE;
    end else begin
        // Releasing the buffers when valid outputs
        if (out_valid_m1) begin
            assign_m1_tmp = FREE;
        end else begin
    
            if (assign_m1_tmp == FREE) begin //chatgpt - it seems like this if is always true
                if (assign_m2_tmp != W1 && w1_metadata.in_use) begin
                    assign_m1_tmp = W1;
                end else if (assign_m2_tmp != W2 && w2_metadata.in_use) begin
                    assign_m1_tmp = W2;
                end else if (assign_m2_tmp != W3 && w3_metadata.in_use) begin
                    assign_m1_tmp = W3;
                end
            end
        end  
        
        if (out_valid_m2) begin 
            assign_m2_tmp = FREE;
        end else  if (assign_m2_tmp == FREE) begin
            if (assign_m1_tmp != W1 && w1_metadata.in_use) begin
                assign_m2_tmp = W1;
            end else if (assign_m1_tmp != W2 && w2_metadata.in_use) begin
                assign_m2_tmp = W2;
            end else if (assign_m1_tmp != W3 && w3_metadata.in_use) begin
                assign_m2_tmp = W3;
            end
        end 
    end
end

assign assign_m1 = assign_m1_tmp;
assign assign_m2 = assign_m2_tmp;

// Sequential logic for clearing clear_m1 and clear_m2 at the rising edge of the clock
always_ff @(posedge Clock) begin
    if (Rst) begin
        assign_m1_tmp_ps <= FREE;
        assign_m2_tmp_ps <= FREE;
    end else begin
        assign_m1_tmp_ps <= assign_m1_tmp;
        assign_m2_tmp_ps <= assign_m2_tmp;
        clear_m1_tmp <= (assign_m1_tmp_ps != assign_m1_tmp) ? 1'b1 : 1'b0;
        clear_m2_tmp <= (assign_m2_tmp_ps != assign_m2_tmp) ? 1'b1 : 1'b0;
    end
end
assign clear_m1 = clear_m1_tmp;
assign clear_m2 = clear_m2_tmp;
assign start_m1 = 1'b1;
assign start_m2 = 1'b1;

logic clear_output_tmp;
logic in_use_ff; // Flip-flop to detect rising edge
logic done_layer_ff; // Flip-flop to detect rising edge
logic move_out_to_in_tmp;
// Process to detect the rising edge of meta_data.in_use
always_ff @(posedge Clock) begin
    if (Rst) begin
        clear_output_tmp <= 1'b0;
        in_use_ff <= 1'b0;
        done_layer_ff <= 1'b0;
    end else begin
        // Detect rising edge: transition from 0 to 1
        in_use_ff <= input_metadata.in_use_by_accel;
        if (~in_use_ff && input_metadata.in_use_by_accel) begin
            clear_output_tmp <= 1'b1; // Rising edge detected, clear_output is set
        end else begin
            clear_output_tmp <= 1'b0; // No rising edge, clear_output is cleared
        end

        done_layer_ff <= done_layer;
        if (~done_layer_ff && done_layer) begin
            move_out_to_in_tmp <= 1'b1; // Rising edge detected, clear_output is set
        end else begin
            move_out_to_in_tmp <= 1'b0; // No rising edge, clear_output is cleared
        end
    end
end
assign clear_output=clear_output_tmp;
assign move_out_to_in=move_out_to_in_tmp;

endmodule
