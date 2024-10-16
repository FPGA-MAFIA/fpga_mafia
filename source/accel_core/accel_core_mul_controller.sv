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

logic clear_m1_tmp;
logic clear_m2_tmp;

always_comb begin
    // Default assignments
    clear_m1_tmp = 1'b0;
    clear_m2_tmp = 1'b0;
    
    if (Rst) begin
        assign_m1_tmp = FREE;
        assign_m2_tmp = FREE;
    end else begin
        // Releasing the buffers when valid outputs
        if (out_valid_m1) begin
            assign_m1_tmp = FREE;
        end
        
        if (out_valid_m2) begin
            assign_m2_tmp = FREE;
        end

        // Assign buffers to m1 if free
        if (assign_m1_tmp == FREE) begin
            if (assign_m2_tmp != W1 && w1_metadata.in_use) begin
                assign_m1_tmp = W1;
                clear_m1_tmp = 1'b1;
            end else if (assign_m2_tmp != W2 && w2_metadata.in_use) begin
                assign_m1_tmp = W2;
                clear_m1_tmp = 1'b1;
            end else if (assign_m2_tmp != W3 && w3_metadata.in_use) begin
                assign_m1_tmp = W3;
                clear_m1_tmp = 1'b1;
            end
        end
        
        // Assign buffers to m2 if free
        if (assign_m2_tmp == FREE) begin
            if (assign_m1_tmp != W1 && w1_metadata.in_use) begin
                assign_m2_tmp = W1;
                clear_m2_tmp = 1'b1;
            end else if (assign_m1_tmp != W2 && w2_metadata.in_use) begin
                assign_m2_tmp = W2;
                clear_m2_tmp = 1'b1;
            end else if (assign_m1_tmp != W3 && w3_metadata.in_use) begin
                assign_m2_tmp = W3;
                clear_m2_tmp = 1'b1;
            end
        end
    end
end

// Sequential logic for clearing clear_m1 and clear_m2 at the rising edge of the clock
always_ff @(posedge Clock) begin
    if (Rst) begin
        clear_m1 <= 1'b0;
        clear_m2 <= 1'b0;
    end else begin
        clear_m1 <= clear_m1_tmp;
        clear_m2 <= clear_m2_tmp;
    end
end

assign assign_m1 = assign_m1_tmp;
assign assign_m2 = assign_m2_tmp;
assign start_m1 = 1'b1;
assign start_m2 = 1'b1;
assign move_out_to_in = 1'b0;

endmodule
