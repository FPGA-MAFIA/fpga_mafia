
//-----------------------------------------------------------------------------
// Title            : Example TB
// Project          : Placeholder
//-----------------------------------------------------------------------------
// File             : sdram_fsm_tb.sv
// Original Author  : Placeholder
// Code Owner       : Placeholder
// Created          : MM/YYYY
//-----------------------------------------------------------------------------
// Description :
//-----------------------------------------------------------------------------

// to run type in the terminal ./build.py -dut sdram_fsm -hw -sim
`ifndef sdram_fsm_TB_SV
`define sdram_fsm_TB_SV

`include "macros.vh"

module sdram_fsm_tb;
import sdram_fsm_pkg::*;

logic Clk;
logic Rst;
// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 Clk = 1'b0;
        #5 Clk = 1'b1;
    end //forever
end//initial clock_gen

// ========================
// reset generation
// ========================
initial begin: reset_gen
    Rst = 1'b1;
#40 Rst = 1'b0;
end: reset_gen
// ========================


logic StartWr;

string test_name;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    #35
        $display("Test Start");
        StartWr = 1'b1;

    wait(sdram_fsm_top.Done) begin
        $display("Test is finished");
    end

    $finish;

end // test_seq

parameter V_TIMEOUT = 1000;
initial begin : time_out_detection
    #V_TIMEOUT
    $error("Time out reached");
    $finish;
end

// ========================
// DUT - Design Under Test
// ========================
sdram_fsm_top sdram_fsm_top 
(
    .Clock(Clk),
    .nRst(!Rst),
    .StartWr(StartWr) // start writing to memory
);

endmodule
`endif
