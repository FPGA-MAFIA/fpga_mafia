//-----------------------------------------------------------------------------
// Title            : fabric reference model test bench tasks
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : fabric_ref_tasks.vh
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// Shared helpers and the test dispatcher for fabric_ref_tb.
// Included from inside the test bench module, same convention as
// verif/fabric/tb/router/router_tasks.vh
//-----------------------------------------------------------------------------

// =============================
// general helpers
// =============================
task automatic delay(input int cycles);
    for (int i = 0; i < cycles; i++) begin
        @(posedge clk);
    end
endtask

function automatic string region2str(input t_ref_region region);
    case (region)
        REGION_NONE     : return "NONE";
        REGION_IMEM     : return "IMEM";
        REGION_DMEM     : return "DMEM";
        REGION_VGA      : return "VGA";
        REGION_CR       : return "CR";
        REGION_WHO_AM_I : return "WHO_AM_I";
        default         : return "ILLEGAL";
    endcase
endfunction

// =============================
// va2pa checker
// Checks region and rsvd_error on every call. tile_idx and offset are only
// meaningful when the access actually resolved to a memory block, so they are
// skipped for REGION_NONE and REGION_WHO_AM_I.
// =============================
task automatic check_pa(input string       check_name,
                        input t_tile_id    requestor_id,
                        input logic [31:0] va,
                        input t_ref_region exp_region,
                        input int          exp_tile_idx,
                        input logic [15:0] exp_offset,
                        input logic        exp_rsvd_error = 1'b0,
                        input logic        exp_tile_error = 1'b0);
    t_ref_pa pa;
    logic    failed;

    pa     = va2pa(requestor_id, va);
    failed = 1'b0;

    if (pa.region     != exp_region)     failed = 1'b1;
    if (pa.rsvd_error != exp_rsvd_error) failed = 1'b1;
    if (pa.tile_error != exp_tile_error) failed = 1'b1;
    if ((exp_region != REGION_NONE) && (exp_region != REGION_WHO_AM_I)) begin
        if (pa.tile_idx != TILE_IDX_WIDTH'(exp_tile_idx)) failed = 1'b1;
        if (pa.offset   != exp_offset)                    failed = 1'b1;
    end

    checks_run++;
    if (failed) begin
        checks_failed++;
        $error("[FAIL] %s : requestor=0x%02h va=0x%08h -> got {region=%s tile_id=0x%02h tile_idx=%0d offset=0x%04h rsvd_error=%0b tile_error=%0b} expected {region=%s tile_idx=%0d offset=0x%04h rsvd_error=%0b tile_error=%0b}",
               check_name, requestor_id, va,
               region2str(pa.region), pa.tile_id, pa.tile_idx, pa.offset, pa.rsvd_error, pa.tile_error,
               region2str(exp_region), exp_tile_idx, exp_offset, exp_rsvd_error, exp_tile_error);
    end
    else begin
        $display("[PASS] %s : requestor=0x%02h va=0x%08h -> region=%s tile_id=0x%02h tile_idx=%0d offset=0x%04h",
                 check_name, requestor_id, va,
                 region2str(pa.region), pa.tile_id, pa.tile_idx, pa.offset);
    end
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
// test dispatcher
// =============================
task automatic run_fabric_ref_test(input string test);
    if (test == "va2pa_map") begin
        `include "va2pa_map.sv"
    end
    else begin
        $error("[ERROR] : test %s not found", test);
    end
endtask
