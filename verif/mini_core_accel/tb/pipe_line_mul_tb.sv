`include "macros.vh"

module pipe_line_mul_tb;
import mini_core_accel_pkg::*;

//./build.py -dut mini_core_accel -top pipe_line_mul_tb -hw -sim -clean 
logic clk;
logic rst;
logic         start;
logic [7:0]   multiplier;
logic [7:0]   multiplicand;
logic         ready;
logic [15:0]  result;

// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end // forever
end // initial clock_gen

parameter ONE_CYCLE_DELAY = 10;

pipe_line_mul pipe_line_mul 
(
    .clk(clk),
    .rst(rst),
    .start(start),
    .multiplier(multiplier),
    .multiplicand(multiplicand),
    .ready(ready),
    .result(result)
);

initial begin :main_tn
    rst = 1;
    #20;
    @(posedge clk)

    rst = 0;
    start = 0;
    multiplier   = 8'd4;
    multiplicand = 8'd3;
    #20;
    @(posedge clk)

    start = 1;
    #ONE_CYCLE_DELAY;
    @(posedge clk)

    multiplier   = -8'd4;
    multiplicand = 8'd3;
    #ONE_CYCLE_DELAY;
    @(posedge clk)

    multiplier   = 8'd18;
    multiplicand = 8'd9;
    #ONE_CYCLE_DELAY;
    @(posedge clk)

    multiplier   = 8'd5;
    multiplicand = 8'd6;
    #ONE_CYCLE_DELAY;
    @(posedge clk)

    multiplier   = 8'd123;
    multiplicand = -8'd6;
    #ONE_CYCLE_DELAY;
    @(posedge clk)

    multiplier   = -8'd4;
    multiplicand = -8'd5;
    #ONE_CYCLE_DELAY;
    @(posedge clk)

    multiplier   = -8'd21;
    multiplicand = 8'd0;
    #ONE_CYCLE_DELAY;
    @(posedge clk)

    multiplier   = 8'd0;
    multiplicand = 8'd3;
    #ONE_CYCLE_DELAY;
    @(posedge clk)

    multiplier   = 8'd64;
    multiplicand = -8'd2;
    #ONE_CYCLE_DELAY;
    @(posedge clk)

    multiplier   = -8'd64;
    multiplicand =  8'd2;
    #ONE_CYCLE_DELAY;
    @(posedge clk)

    multiplier   = 8'd12;
    multiplicand = -8'd12;
    #ONE_CYCLE_DELAY;
    @(posedge clk)

    multiplier   = -8'd128;
    multiplicand =  8'd1;
    #(50*ONE_CYCLE_DELAY);
    @(posedge clk)

    $finish();
end

parameter V_TIMEOUT = 100000;

initial begin: v_timeout
    #V_TIMEOUT
    $display("reached timeout");
    $finish();
end

endmodule