//-----------------------------------------------------------------------------
// Title            : fabric reference model software test tasks
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : fabric_ref_sw_tasks.vh
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// Program loading, run control and result checking for fabric_ref_top_tb.
// Included from inside the test bench module, same convention as
// fabric_ref_tasks.vh.
//-----------------------------------------------------------------------------

// =============================
// program loading
//
// Both gcc output files carry an @address directive, so $readmemh drops every
// byte at its absolute address. The same image is then copied into all nine
// tiles, which is exactly what issue #454 is about: one binary, nine cores.
//
// The image is zero filled first, so every byte a core can address is a real
// value rather than X. That matches an FPGA block RAM, which powers up at
// zero, and it matters for software: a core that spins on a shared flag until
// it turns non zero needs that flag to start out readably zero. Left as X the
// compare resolves unpredictably and the spin falls straight through.
// =============================
task automatic load_program(input string test);
    string dir;
    dir = {"../../../target/fabric_ref/tests/", test, "/gcc_files/"};

    foreach (image[i]) image[i] = 8'h00;

    $readmemh({dir, "inst_mem.sv"}, image);
    $readmemh({dir, "data_mem.sv"}, image);

    for (int t = 0; t < N_TILES; t++) begin
        for (int o = 0; o < MEM_BLOCK_SIZE; o++) begin
            dut.u_mem.imem_block.mem[t][o] = image[o];
            dut.u_mem.dmem_block.mem[t][o] = image[MEM_BLOCK_SIZE + o];
        end
    end
    $display("[INFO] loaded %s into all %0d tiles", test, N_TILES);
endtask

// =============================
// run control
// =============================
task automatic wait_for_all_tiles_done();
    while (tile_done !== {N_TILES{1'b1}}) begin
        @(posedge clk);
    end
    $display("[INFO] every tile reached its ebreak at time %0t", $time());
endtask

// =============================
// back door memory reads, used by the checkers
// =============================
function automatic logic [31:0] dmem_word(input int tile_idx, input logic [15:0] offset);
    return {dut.u_mem.dmem_block.mem[tile_idx][offset + 3],
            dut.u_mem.dmem_block.mem[tile_idx][offset + 2],
            dut.u_mem.dmem_block.mem[tile_idx][offset + 1],
            dut.u_mem.dmem_block.mem[tile_idx][offset + 0]};
endfunction

function automatic logic [31:0] vga_word(input logic [15:0] offset);
    return {dut.u_mem.vga_block.mem[0][offset + 3],
            dut.u_mem.vga_block.mem[0][offset + 2],
            dut.u_mem.vga_block.mem[0][offset + 1],
            dut.u_mem.vga_block.mem[0][offset + 0]};
endfunction

// =============================
// checkers
// =============================
task automatic check_word(input string       check_name,
                          input logic [31:0] got,
                          input logic [31:0] exp);
    checks_run++;
    if (got !== exp) begin
        checks_failed++;
        $error("[FAIL] %s : got 0x%08h expected 0x%08h", check_name, got, exp);
    end
    else begin
        $display("[PASS] %s : 0x%08h", check_name, got);
    end
endtask

// Every tile must have finished, and none of them by an unexpected route.
task automatic check_all_tiles_finished();
    check_word("all_tiles_reached_ebreak", {{(32-N_TILES){1'b0}}, tile_ebreak},
                                            {{(32-N_TILES){1'b0}}, {N_TILES{1'b1}}});
    check_word("no_tile_hit_an_ecall",     {{(32-N_TILES){1'b0}}, tile_ecall}, 32'b0);
    check_word("no_illegal_instruction",   {{(32-N_TILES){1'b0}}, tile_illegal}, 32'b0);
endtask

// =============================
// final status
// =============================
task automatic print_final_status(input string test);
    $display("=======================================================");
    if (checks_failed == 0) begin
        $display("[INFO] Test Passed - %s - %0d checks, 0 failures", test, checks_run);
    end
    else begin
        $error("Test failed - %s - %0d of %0d checks failed", test, checks_failed, checks_run);
    end
    $display("=======================================================");
endtask

// =============================
// per test checkers
// =============================
task automatic check_software(input string test);
    check_all_tiles_finished();
    if (test == "fabric_alive") begin
        `include "fabric_alive_chk.sv"
    end
    else if (test == "non_local_rd_wr") begin
        `include "non_local_rd_wr_chk.sv"
    end
    else if (test == "dist_sum") begin
        `include "dist_sum_chk.sv"
    end
    else begin
        $error("[ERROR] : no checker for test %s", test);
    end
endtask
