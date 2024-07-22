`include "macros.vh"

// ./build.py -dut mini_core_accel -hw -sim -top multiplier_tb -clean 

module multiplier_tb;
import mini_core_pkg::*;
import mini_core_accel_pkg::*;

logic clk;
logic rst;
logic [NUM_WIDTH-1:0]    pre_multiplicand;
logic [NUM_WIDTH-1:0]    pre_multiplier;
logic [2*NUM_WIDTH-1:0]  result;
logic                    done;

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

multiplier multiplier (
    .clock(clk),
    .rst(rst),
    .pre_multiplicand(pre_multiplicand),
    .pre_multiplier(pre_multiplier),
    .result(result),
    .done(done)
    );

initial begin : main_tb
    rst = 1'b1;
    // reset the cr's
    pre_multiplicand = 8'd0;
    pre_multiplier   = 8'd0;
    #50

    rst = 0;
    #20
    // change one of the inputs and wait until done (basic test)
    @(posedge clk)
    pre_multiplicand = 8'd3;
    pre_multiplier   = 8'd4;
    #LONG_DELAY
    
    @(posedge clk)
    pre_multiplicand = -8'd3;
    pre_multiplier   = 8'd4;
    #LONG_DELAY
    
    @(posedge clk)
    pre_multiplicand = 8'd18;
    pre_multiplier   = 8'd9;
    #LONG_DELAY

    // change one of the inputs during calculations
    @(posedge clk)
    pre_multiplicand = 8'd5;
    pre_multiplier   = 8'd6; // won't calculate
    #SHORT_DELAY

    @(posedge clk)
    pre_multiplicand = 8'd4;
    pre_multiplier   = 8'd6;  // will calculate and display display 24
    #LONG_DELAY

    
    @(posedge clk)
    pre_multiplicand = 8'd12;
    pre_multiplier   = 8'd6;  // won't calculate
    #SHORT_DELAY

    @(posedge clk)
    pre_multiplicand = -8'd7;
    pre_multiplier   = 8'd123;  // will calculate and desplay -861
    #LONG_DELAY

    // change one of the inputs each clock cycle
    @(posedge clk)
    pre_multiplicand = 8'd3;
    pre_multiplier   = 8'd5;  // won't calculate
    #CLK_DELAY

    @(posedge clk)
    pre_multiplicand = -8'd4;
    pre_multiplier   = 8'd4;   // will calculate and display -16
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
