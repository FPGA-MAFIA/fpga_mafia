// ./build.py -dut mini_core_accel -hw -sim -top booth_multiplier_tb -gui &

`include "macros.vh"

module booth_multiplier_tb;
import mini_core_pkg::*;
import mini_core_accel_pkg::*;



logic clk;
logic rst;
t_booth_mul_req   input_req;
t_booth_output    output_rsp;



// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end //forever
end//initial clock_gen

booth_multiplier booth_multiplier (
    .clock(clk),
    .rst(rst),
    .input_req(input_req),
    .output_rsp(output_rsp),
    .busy()
);

initial begin: main_tb
    // reset
    rst = 1'b1;
    #20

    // test -7x3 = -21
    input_req.valid        = 1'b1;
    input_req.multiplicand = -8'h7;
    input_req.multiplier   =  8'h3;
    rst = 1'b0;
    #300

    // test 7x7 = 49
    input_req.multiplicand = 8'h7;
    input_req.multiplier   = 8'h7;
    #300

     // test -8x-8 = 64
    input_req.multiplicand = -8'h8;
    input_req.multiplier   = -8'h8;
    #300

    $finish();

end


parameter V_TIMEOUT = 10000;
initial begin :time_out
    #V_TIMEOUT
    $display("Time out reached");
    $finish();
end
endmodule