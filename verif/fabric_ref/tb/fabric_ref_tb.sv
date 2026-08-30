//-----------------------------------------------------------------------------
// Title            : fabric reference model test bench
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : fabric_ref_tb.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// Test bench for the fabric reference model (github issue #454).
// The test to run is selected by the +STRING=<test_name> plusarg that build.py
// passes to vsim, and is dispatched in fabric_ref_tasks.vh.
//-----------------------------------------------------------------------------

`include "macros.vh"

module fabric_ref_tb;
import fabric_ref_pkg::*;

logic  clk;
logic  rst;
string test_name;

int    checks_run;
int    checks_failed;

// =============================
// CLK GEN
// =============================
initial begin: clock_gen
    clk = 1'b0;
    forever #5 clk = ~clk;
end

// =============================
// RST GEN
// =============================
initial begin: reset_gen
    rst = 1'b1;
#40 rst = 1'b0;
end

// =============================
// timeout protection
// =============================
initial begin: timeout_monitor
    #100us;
    $error("ERROR: TIMEOUT");
    $finish();
end

// DUT instances - the three blocks of the unified memory
`include "fabric_ref_mem_dut.vh"

`include "fabric_ref_tasks.vh"

// =============================
// main test sequence
// =============================
initial begin: test_seq
    checks_run    = 0;
    checks_failed = 0;
    mem_assert_en = 1'b1;
    mem_clear_requests();
    $display("================\n     START\n================");
    if ($value$plusargs("STRING=%s", test_name)) $display("STRING value %s", test_name);
    else $fatal(1, "CANNOT FIND TEST %s at time %t", test_name, $time());

    @(negedge rst);
    delay(2);

    run_fabric_ref_test(test_name);

    print_final_status(test_name);
    delay(5);
    $finish();
end

endmodule
