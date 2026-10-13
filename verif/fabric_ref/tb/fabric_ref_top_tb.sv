//-----------------------------------------------------------------------------
// Title            : fabric reference model top test bench
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : fabric_ref_top_tb.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// Runs real compiled software on the fabric reference model (issue #454).
//
// The flow mirrors rv32i_ref_tb, just multiplied by the number of tiles:
//   1. generate clock and reset, hold run low
//   2. back door load the SAME binary into every tile
//   3. release reset, raise run, let all nine cores go at once
//   4. finish when every core has hit its ebreak
//   5. hand over to the per test checker in fabric_ref_sw_tasks.vh
//
// Loading the same image into all nine tiles is the point of the exercise. A
// core reaches its own memory through a tile field of 0x00, so one binary
// behaves differently on each tile without a single instruction changing.
//-----------------------------------------------------------------------------

`include "macros.vh"

module fabric_ref_top_tb;
import fabric_ref_pkg::*;

logic  clk;
logic  rst;
logic  run;
string test_name;

int    checks_run;
int    checks_failed;

logic [N_TILES-1:0] tile_done;
logic [N_TILES-1:0] tile_ebreak;
logic [N_TILES-1:0] tile_ecall;
logic [N_TILES-1:0] tile_illegal;

// The program image, indexed by absolute address. Both gcc output files carry
// an @address directive, inst_mem at 0x00000000 and data_mem at 0x00010000,
// so reading both into one array puts every byte exactly where it belongs.
parameter IMAGE_SIZE = 2 * MEM_BLOCK_SIZE; // 64KB of code plus 64KB of data
logic [7:0] image [0:IMAGE_SIZE-1];

// =============================
// CLK GEN
// =============================
initial begin: clock_gen
    clk = 1'b0;
    forever #5 clk = ~clk;
end

// =============================
// DUT
// =============================
fabric_ref_top dut (
    .clk            (clk),
    .rst            (rst),
    .run            (run),
    .o_tile_done    (tile_done),
    .o_tile_ebreak  (tile_ebreak),
    .o_tile_ecall   (tile_ecall),
    .o_tile_illegal (tile_illegal)
);

`include "fabric_ref_sw_tasks.vh"
`include "fabric_ref_trk.vh"

// =============================
// timeout protection
// =============================
initial begin: timeout_monitor
    #500us;
    $error("ERROR: TIMEOUT - not every tile reached its ebreak. done = 0b%b", tile_done);
    $finish();
end

// =============================
// illegal instruction monitor
// =============================
initial begin: illegal_monitor
    forever begin
        @(posedge clk);
        if (run && (|tile_illegal)) begin
            $error("ERROR: illegal_instruction on tiles 0b%b", tile_illegal);
            $finish();
        end
    end
end

// =============================
// main test sequence
// =============================
initial begin: test_seq
    checks_run    = 0;
    checks_failed = 0;
    rst           = 1'b1;
    run           = 1'b0;

    $display("================\n     START\n================");
    if ($value$plusargs("STRING=%s", test_name)) $display("STRING value %s", test_name);
    else $fatal(1, "CANNOT FIND TEST %s at time %t", test_name, $time());

    load_program(test_name);

    repeat (4) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
    run = 1'b1;
    $display("[INFO] all %0d tiles released at time %0t", N_TILES, $time());

    wait_for_all_tiles_done();

    check_software(test_name);

    print_final_status(test_name);
    repeat (5) @(posedge clk);
    $finish();
end

endmodule
