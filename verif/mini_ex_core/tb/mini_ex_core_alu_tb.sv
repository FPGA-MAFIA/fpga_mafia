`include "macros.vh"

module mini_ex_core_alu_tb;
import mini_ex_core_pkg::*;

    logic Clock;
    logic Rst;
    logic PcQ101H, PcQ102H;
    t_alu_ctrl Ctrl;
    logic AluOutQ102H;


    mini_ex_core_alu mini_ex_core_alu (
     .Clock         (Clock),
     .Rst           (Rst),
     .PcQ101H       (PcQ101H),
     .Ctrl          (Ctrl),
     .AluOutQ102H   (AluOutQ102H),
     .PcQ102H       (PcQ102H)

    );

    always Clock = !Clock;

    // FIXME - finish
    

endmodule


