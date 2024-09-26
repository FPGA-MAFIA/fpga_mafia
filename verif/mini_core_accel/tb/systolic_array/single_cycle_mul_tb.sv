// single cycle mul tb

module single_cycle_mul_tb;
import mini_core_pkg::*;
import mini_core_accel_pkg::*;

// ./build.py -dut mini_core_accel -top single_cycle_mul_tb -hw -sim
logic rst;
int8  multiplier;
int8  multiplicand;
int16 result;

single_cycle_mul single_cycle_mul
(
    .clk(),
    .rst(rst),
    .multiplier(multiplier),
    .multiplicand(multiplicand),
    .result(result)
);


initial begin : main_tb
    rst = 1;
    #10

    rst = 0;
    multiplier   = 8'd3;
    multiplicand = 8'd4;
    #10

    multiplier   = 8'd15;
    multiplicand = 8'd4;
    #10

    multiplier   = 8'd0;
    multiplicand = 8'd4;
    #10

    multiplier   = 8'd127;
    multiplicand = 8'd1;
    #10

    multiplier   = 8'd32;
    multiplicand = 8'd5;
    #10
    
    multiplier   = -8'd2;
    multiplicand =  8'd4;
    #10

    multiplier   = -8'd20;
    multiplicand =  8'd4;
    #10

    multiplier   = -8'd128;
    multiplicand =  8'd1;
    #10

    multiplier   = -8'd1;
    multiplicand =  8'd100;
    #10

    multiplier   = -8'd20;
    multiplicand =  8'd3;
    #10

    multiplier   = -8'd33;
    multiplicand =  8'd4;
    #10

    multiplier   =  8'd2;
    multiplicand =  -8'd3;
    #10

    multiplier   =  8'd2;
    multiplicand =  -8'd3;
    #10


    multiplier   =  8'd12;
    multiplicand =  -8'd3;
    #10

    multiplier   =  8'd1;
    multiplicand =  -8'd128;
    #10

    multiplier   =  -8'd6;
    multiplicand =  -8'd3;
    #10
    
    $finish();

end

parameter V_TIMEOUT = 30000;
initial begin : time_out
    #V_TIMEOUT
    $error("Time out reached");
    $finish();
end

endmodule



