 // to run that TB please time
 // ./build.py -dut mini_core_rrv -top mini_core_rrv_if_tb -hw -sim -gui &
`include "macros.vh"

module mini_core_rrv_if_tb;
import mini_core_rrv_pkg::*;

    logic         Clock;
    logic         Rst;
    var t_ctrl_if Ctrl;
    logic [31:0]  AluOutQ101H;
    logic [31:0]  PcQ100H;
    logic [31:0]   PcQ101H;

    
    initial begin: clock_gen
        forever begin
            #5 Clock = 1'b0;
            #5 Clock = 1'b1;
        end

    end

    mini_core_if mini_core_if
    (
    .Clock(Clock),
    .Rst(Rst),
    .Ctrl(Ctrl),
    .AluOutQ101H(AluOutQ101H),
    .PcQ100H(PcQ100H),
    .PcQ101H(PcQ101H)
);

    initial begin: main
        Rst         = 1'b1;
        AluOutQ101H = 1'b0;
        #20

        Rst = 1'b0;
        Ctrl.SelNextPcAluOutQ101H = 1'b0;
        #100

        AluOutQ101H               = 1'b1;
        Ctrl.SelNextPcAluOutQ101H = 1'b1;
        #100

        $finish;

    end

    parameter V_TIMEOUT = 100000;
    initial begin: time_out_detection
        #V_TIMEOUT
        $display("reached time_out");
        $finish;
    end

endmodule