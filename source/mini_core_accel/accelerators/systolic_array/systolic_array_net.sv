/*
                   4x4 systolic array
                   -------------------

                        weights                                
         ---|--------|--------|--------|--------|---
    a       |  PE0   |  PE1   |  PE2   | PE3    |
    c    ---|--------|--------|--------|--------|---
    t       |  PE4   |  PE5   |  PE6   | PE7    |
    i    ---|--------|--------|--------|--------|---
    v       |  PE8   |  PE9   |  PE10  | PE11   |
    e    ---|--------|--------|--------|--------|---
            |  PE12  |  PE13  |  PE14  | PE15   |
         ---|--------|--------|--------|--------|---

*/

`include "macros.vh"

module systolic_array_net
import mini_core_accel_pkg::*;
(
    input logic         clk,
    input logic         rst,
    input logic  [31:0] weights,     // 4 weights of INT8 type
    input logic  [31:0] activation,  // 4 inputs of INT8 type
    input logic         first_done,  // top left PE done signal
    output logic        valid        // final valid signal
);

    parameter DIMENTION = 4;  // 4x4 grid

    logic [15:0] result [0:3][0:3]; // Store result of each PE at the end of calculations
    logic done_signal [0:3][0:3];   // Propagating done signal for each PE

    // Define 4x4 grid of pe_units
    t_pe_unit_input  unit_input[0:3][0:3];
    t_pe_unit_output unit_output[0:3][0:3];

    genvar row, col;
    generate
        for (row = 0; row < DIMENTION; row++) begin : row_gen
            for (col = 0; col < DIMENTION; col++) begin : col_gen
                // Inputs for the PE
                assign unit_input[row][col].weight = (row == 0) ? weights[(8*col+7)-:8] : unit_output[row-1][col].weight;
                assign unit_input[row][col].activation = (col == 0) ? activation[(8*row+7)-:8] : unit_output[row][col-1].activation;

                // Done signal propagation
                if (row == 0 && col == 0) begin
                    // PE00 gets the initial done signal
                    assign done_signal[row][col] = first_done;
                end else if (col == 0) begin
                    // Propagate done signal from the PE above in the first column
                    assign done_signal[row][col] = unit_output[row-1][col].done;
                end else if (row == 0) begin
                    // Propagate done signal from the PE to the left in the first row
                    assign done_signal[row][col] = unit_output[row][col-1].done;
                end else begin
                    // For all other PEs, propagate done signal from the PE above or to the left
                    assign done_signal[row][col] = unit_output[row-1][col].done || unit_output[row][col-1].done;
                end

                // Assign the propagated done signal to the PE inputs
                assign unit_input[row][col].done = done_signal[row][col];

                // Instantiate the processing element (PE)
                pe_unit pe_inst (
                    .clk(clk),
                    .rst(rst),
                    .pe_inputs(unit_input[row][col]),
                    .pe_outputs(unit_output[row][col]),
                    .result(result[row][col])
                );
            end
        end
    endgenerate

    // Output valid signal: last PE's done signal indicates the entire array is done
    assign valid = done_signal[DIMENTION-1][DIMENTION-1];

endmodule
