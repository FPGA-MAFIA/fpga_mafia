// PROCESSING UNIT of systolic array


// ./build.py -dut mini_core_accel -top pe_unit_tb -hw -sim
`include "macros.vh"

module pe_unit_tb;
import mini_core_accel_pkg::*;

logic             clk;
logic             rst;
int16             result;
t_pe_unit_input   pe_inputs;

// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end // forever
end // initial clock_gen

pe_unit pe_unit
(
    .clk(clk),
    .rst(rst),
    .pe_inputs(pe_inputs),
    .result(result)
);

initial begin:main_tb
    rst = 1;
    pe_inputs.done = 0;
    #20

    rst = 0;
    pe_inputs.weight     = 8'd5;
    pe_inputs.activation = 8'd4;
    #10   
    $display("Expected result is : 20, The result of mac is: %d", result);  
     
    pe_inputs.weight     = 8'd2;
    pe_inputs.activation = 8'd12;
    #10  
    $display("Expected result is : 44, The result of mac is: %d", result);

    pe_inputs.weight     = -8'd2;
    pe_inputs.activation = 8'd4;
    #10
    $display("Expected result is : 36, The result of mac is: %d", result);

    pe_inputs.weight     = -8'd5;
    pe_inputs.activation = -8'd6;
    pe_inputs.done = 1;
    #10
    $display("Expected result is : 66, The result of mac is: %d", result);

    $finish();
end

parameter V_TIMEOUT = 10000;
initial begin:timeout_logic
    #V_TIMEOUT
    $display("timeout reached");
    $finish();

end

endmodule