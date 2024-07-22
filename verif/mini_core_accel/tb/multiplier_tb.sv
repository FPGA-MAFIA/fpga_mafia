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
    pre_multiplicand = 8'd0;
    pre_multiplier   = 8'd0;
    #50
    // we also reset the CR's that acts like inputs
    rst = 0;
    #20
    @(posedge clk)
    pre_multiplicand = -8'd5;
    pre_multiplier   = 8'd12;
    #200

    $finish();


end

parameter V_TIMEOUT = 30000;
initial begin : time_out
    #V_TIMEOUT
    $error("Time out reached");
    $finish();
end

endmodule
