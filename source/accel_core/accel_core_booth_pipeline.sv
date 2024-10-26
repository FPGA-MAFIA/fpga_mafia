`include "macros.vh"
import accel_core_pkg::*;

module accel_core_booth_pipeline
#(
  parameter int M_width = 8,  // Width of Mu (Multiplier)
  parameter int Q_width = 8   // Width of Qu (Multiplicand)
)
(
    input logic                  Clock,
    input logic                  Rst,
    input logic signed [M_width-1:0]    Mu,  // Multiplier
    input logic signed [Q_width-1:0]    Qu,  // Multiplicand
    output logic signed [M_width+Q_width-1:0] out // Product
);

    stage_mul_inp_t stage_inputs[0:Q_width];     // Current stage inputs
    stage_mul_inp_t stage_inputs_ns[0:Q_width];  // Next stage inputs

     generate
        for (genvar i = 0; i <= Q_width; ++i) begin
            `MAFIA_RST_DFF(stage_inputs[i], stage_inputs_ns[i], Clock, Rst);
        end
    endgenerate

    // Booth algorithm combinational logic
    always_comb begin
        // Initialize stage 0 with inputs
        stage_inputs_ns[0].Accum = '0;
        stage_inputs_ns[0].Qu    = Qu;
        stage_inputs_ns[0].q0    = 1'b0;
        stage_inputs_ns[0].Mu    = Mu;

        // Process Booth algorithm pipeline
        for (int i = 0; i < Q_width ; ++i) begin
            stage_inputs_ns[i+1].Mu = stage_inputs[i].Mu; // Pass Mu forward

            // Compute Booth recoding
            case ({stage_inputs[i].Qu[0], stage_inputs[i].q0})
                2'b01: begin
                    // Add Mu
                    stage_inputs_ns[i+1].Accum = stage_inputs[i].Accum + stage_inputs[i].Mu;
                end
                2'b10: begin
                    // Subtract Mu
                    stage_inputs_ns[i+1].Accum = stage_inputs[i].Accum - stage_inputs[i].Mu;
                end
                default: begin
                    // No operation
                    stage_inputs_ns[i+1].Accum = stage_inputs[i].Accum;
                end
            endcase

            // Shift operation (right shift)
            stage_inputs_ns[i+1].Qu  = {stage_inputs_ns[i+1].Accum[0], stage_inputs[i].Qu[Q_width-1:1]};
            stage_inputs_ns[i+1].Accum =  stage_inputs_ns[i+1].Accum >>> 1;
            stage_inputs_ns[i+1].q0   = stage_inputs[i].Qu[0];
        end
    end

    // Concatenate final Accum and Qu to get the result
    assign out = {stage_inputs[Q_width].Accum, stage_inputs[Q_width].Qu};

endmodule