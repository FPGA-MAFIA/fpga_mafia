`include "macros.vh"
// that module is intantiate the systolic array (systolic_array_ctrl.sv)
// the main goal of that model is to hide all the assignments from mini_core_accel_farm
// so we do the assignments here

module systolic_array_top
import mini_core_accel_pkg::*;
(
    input logic                     clk,
    input logic                     rst,
    input var t_cr_systolic_array   cr_systolic_array_input,
    output var t_cr_systolic_array  cr_systolic_array_output

);


logic [127:0] systolic_array_weights;
logic [127:0] systolic_array_avtivations;
assign        systolic_array_weights    =  {cr_systolic_array_input.cr_systolic_array_weights127_96, 
                                            cr_systolic_array_input.cr_systolic_array_weights95_64,
                                            cr_systolic_array_input.cr_systolic_array_weights63_32,
                                            cr_systolic_array_input.cr_systolic_array_weights31_0};

assign        systolic_array_avtivations = {cr_systolic_array_input.cr_systolic_array_active127_96, 
                                            cr_systolic_array_input.cr_systolic_array_active95_64,
                                            cr_systolic_array_input.cr_systolic_array_active63_32,
                                            cr_systolic_array_input.cr_systolic_array_active31_0};  


t_pe_results pe_results_to_cr;

assign cr_systolic_array_output.cr_pe00_result = pe_results_to_cr.pe00_result;
assign cr_systolic_array_output.cr_pe01_result = pe_results_to_cr.pe01_result;
assign cr_systolic_array_output.cr_pe02_result = pe_results_to_cr.pe02_result;
assign cr_systolic_array_output.cr_pe03_result = pe_results_to_cr.pe03_result;
assign cr_systolic_array_output.cr_pe10_result = pe_results_to_cr.pe10_result;
assign cr_systolic_array_output.cr_pe11_result = pe_results_to_cr.pe11_result;
assign cr_systolic_array_output.cr_pe12_result = pe_results_to_cr.pe12_result;
assign cr_systolic_array_output.cr_pe13_result = pe_results_to_cr.pe13_result;
assign cr_systolic_array_output.cr_pe20_result = pe_results_to_cr.pe20_result;
assign cr_systolic_array_output.cr_pe21_result = pe_results_to_cr.pe21_result;
assign cr_systolic_array_output.cr_pe22_result = pe_results_to_cr.pe22_result;
assign cr_systolic_array_output.cr_pe23_result = pe_results_to_cr.pe23_result;
assign cr_systolic_array_output.cr_pe30_result = pe_results_to_cr.pe30_result;
assign cr_systolic_array_output.cr_pe31_result = pe_results_to_cr.pe31_result;
assign cr_systolic_array_output.cr_pe32_result = pe_results_to_cr.pe32_result;
assign cr_systolic_array_output.cr_pe33_result = pe_results_to_cr.pe33_result;

systolic_array_ctrl systolic_array_ctrl
(
    .clk(clk),
    .rst(rst),
    .all_weights(systolic_array_weights),                                 // hard wired to cr's
    .all_activations(systolic_array_avtivations),                         // hard wired to cr's
    .start(cr_systolic_array_input.cr_systolic_array_start),   // hard wired to cr
    .valid(cr_systolic_array_output.cr_systolic_array_valid),  // hard wired to cr data is valid 
    .pe_results(pe_results_to_cr)

);

endmodule