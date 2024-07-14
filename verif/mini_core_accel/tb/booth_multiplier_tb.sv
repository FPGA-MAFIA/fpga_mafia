// ./build.py -dut mini_core_accel -hw -sim -top booth_multiplier_tb -gui &

`include "macros.vh"

module booth_multiplier_tb;
import mini_core_pkg::*;
import mini_core_accel_pkg::*;



logic Clk;
logic Rst;
t_booth_mul_req       InputReq;
t_booth_output        OutputRsp;



// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 Clk = 1'b0;
        #5 Clk = 1'b1;
    end //forever
end//initial clock_gen

booth_multiplier booth_multiplier (
    .Clock(Clk),
    .Rst(Rst),
    .InputReq(InputReq),
    .OutputRsp(OutputRsp)
);

initial begin: main_tb
    // reset
    Rst = 1'b1;
    #20

    // test -7x3 = -21
    InputReq.Valid        = 1'b1;
    InputReq.Multiplicand =  -8'h7;
    InputReq.Multiplier   =  8'h3;
    Rst = 1'b0;
    #200

    // test 7x7 = 49
    InputReq.Valid        = 1'b1;
    InputReq.Multiplicand =  8'h7;
    InputReq.Multiplier   =  8'h7;
    Rst = 1'b0;
    #200

     // test -8x-8 = 64
    InputReq.Valid        = 1'b1;
    InputReq.Multiplicand =  -8'h8;
    InputReq.Multiplier   =  -8'h8;
    Rst = 1'b0;
    #200

    $finish();

end


parameter V_TIMEOUT = 10000;
initial begin :time_out
    #V_TIMEOUT
    $display("Time out reached");
    $finish();
end
endmodule