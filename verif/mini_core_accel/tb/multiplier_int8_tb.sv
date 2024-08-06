`include "macros.vh"

// ./build.py -dut mini_core_accel -hw -sim -top multiplier_int8_tb -clean 

module multiplier_int8_tb;
import mini_core_pkg::*;
import mini_core_accel_pkg::*;

logic clk;
logic rst;
t_mul_int8_input   pre_mul_int_8_input;
t_mul_int8_output  mul_int8_output;


parameter LONG_DELAY  = 200;
parameter SHORT_DELAY = 30;
parameter CLK_DELAY   = 10;
// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end // forever
end // initial clock_gen

multiplier_int8 multiplier_int8 (
    .clock(clk),
    .rst(rst),
    .pre_mul_int_8_input(pre_mul_int_8_input),
    .mul_int8_output(mul_int8_output)
    );

initial begin : main_tb
    rst = 1'b1;
    // reset the cr's
    pre_mul_int_8_input.multiplicand = 8'd0;
    pre_mul_int_8_input.multiplier   = 8'd0;
    #50

    rst = 0;
    #20
    // change one of the inputs and wait until done (basic test)
    @(posedge clk)
    pre_mul_int_8_input.multiplicand = 8'd3;
    pre_mul_int_8_input.multiplier   = 8'd4;
    #LONG_DELAY
    
    @(posedge clk)
    pre_mul_int_8_input.multiplicand = -8'd3;
    pre_mul_int_8_input.multiplier   = 8'd4;
    #LONG_DELAY
    
    @(posedge clk)
    pre_mul_int_8_input.multiplicand = 8'd18;
    pre_mul_int_8_input.multiplier   = 8'd9;
    #LONG_DELAY

    // change one of the inputs during calculations
    @(posedge clk)
    pre_mul_int_8_input.multiplicand = 8'd5;
    pre_mul_int_8_input.multiplier   = 8'd6; // won't calculate
    #SHORT_DELAY

    @(posedge clk)
    pre_mul_int_8_input.multiplicand = 8'd4;
    pre_mul_int_8_input.multiplier   = 8'd6;  // will calculate and display display 24
    #LONG_DELAY

    
    @(posedge clk)
    pre_mul_int_8_input.multiplicand = 8'd12;
    pre_mul_int_8_input.multiplier   = 8'd6;  // won't calculate
    #SHORT_DELAY

    @(posedge clk)
    pre_mul_int_8_input.multiplicand = -8'd7;
    pre_mul_int_8_input.multiplier   = 8'd123;  // will calculate and desplay -861
    #LONG_DELAY

    // change one of the inputs each clock cycle
    @(posedge clk)
    pre_mul_int_8_input.multiplicand = 8'd3;
    pre_mul_int_8_input.multiplier   = 8'd5;  // won't calculate
    #CLK_DELAY

    @(posedge clk)
    pre_mul_int_8_input.multiplicand = -8'd4;
    pre_mul_int_8_input.multiplier   = 8'd4;   // will calculate and display -16
    #LONG_DELAY


    $finish();


end

parameter V_TIMEOUT = 30000;
initial begin : time_out
    #V_TIMEOUT
    $error("Time out reached");
    $finish();
end

endmodule
