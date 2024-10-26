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
    input logic out_valid_m2,
    // Control signals for CR
    output logic release_w1,
    output logic release_w2,
    output logic release_w3
);

t_buffer_sel assign_m1_tmp;
t_buffer_sel assign_m2_tmp;
t_buffer_sel assign_m1_tmp_ps;
t_buffer_sel assign_m2_tmp_ps;

logic out_valid_m1_ff;
logic out_valid_m2_ff;
`MAFIA_RST_DFF(out_valid_m1_ff, out_valid_m1, Clock, Rst);
`MAFIA_RST_DFF(out_valid_m2_ff, out_valid_m2, Clock, Rst);


always_comb begin
    // Default assignments
    
    if (Rst || (~(input_metadata.in_use_by_accel))) begin
        assign_m1_tmp = FREE; 
        assign_m2_tmp = FREE;
    end else begin
        // Releasing the buffers when valid outputs
        if (out_valid_m1_ff) begin
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
        
        if (out_valid_m2_ff) begin 
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
assign start_m1 = 1'b1;
assign start_m2 = 1'b1;
`MAFIA_RST_VAL_DFF(assign_m1_tmp_ps, assign_m1_tmp, Clock, Rst, FREE);
`MAFIA_RST_VAL_DFF(assign_m2_tmp_ps, assign_m2_tmp, Clock, Rst, FREE);
assign clear_m1 = (assign_m1_tmp_ps == FREE /*&& assign_m1_tmp != FREE*/) ? 1'b1 : 1'b0;
assign clear_m2 = (assign_m2_tmp_ps == FREE /*&& assign_m2_tmp != FREE*/) ? 1'b1 : 1'b0;
assign release_w1 = ((assign_m1_tmp_ps == W1 && out_valid_m1) || 
              (assign_m2_tmp_ps == W1 && out_valid_m2))   ? 1'b1 : 1'b0;
assign release_w2 = ((assign_m1_tmp_ps == W2 && out_valid_m1) || 
              (assign_m2_tmp_ps == W2 && out_valid_m2))   ? 1'b1 : 1'b0;
assign release_w3 = ((assign_m1_tmp_ps == W3 && out_valid_m1) || 
              (assign_m2_tmp_ps == W3 && out_valid_m2))   ? 1'b1 : 1'b0;

// Process to detect the rising edge of meta_data.in_use
logic in_use_ff; // Flip-flop to detect rising edge
logic done_layer_ff; // Flip-flop to detect rising edge
`MAFIA_RST_DFF(in_use_ff, input_metadata.in_use_by_accel, Clock, Rst);
`MAFIA_RST_DFF(done_layer_ff, done_layer, Clock, Rst);
assign clear_output   = (~in_use_ff && input_metadata.in_use_by_accel) ? 1'b1 : 1'b0;
assign move_out_to_in = (~done_layer_ff && done_layer) ? 1'b1 : 1'b0;
endmodule
