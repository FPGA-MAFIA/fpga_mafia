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
// memory block drivers
//
// Requests are level driven. Set one or more ports, call mem_commit() to let
// the write take effect on the clock edge, and the ports are dropped again.
// Reads are combinational, so mem_check_read samples after a small delay
// without consuming a clock cycle.
// =============================
task automatic mem_clear_requests();
    imem_valid = '0; imem_wr_en = '0; imem_byte_en = '0;
    imem_block_idx = '0; imem_offset = '0; imem_wr_data = '0;
    dmem_valid = '0; dmem_wr_en = '0; dmem_byte_en = '0;
    dmem_block_idx = '0; dmem_offset = '0; dmem_wr_data = '0;
    vga_valid  = '0; vga_wr_en  = '0; vga_byte_en  = '0;
    vga_block_idx  = '0; vga_offset  = '0; vga_wr_data  = '0;
endtask

// Stage a write on one port of one block. Nothing happens until mem_commit().
task automatic mem_set_write(input string      block,
                             input int         port,
                             input int         slice_idx,
                             input logic [15:0] offset,
                             input logic [31:0] data,
                             input logic [3:0]  byte_en = 4'hF);
    case (block)
        "IMEM" : begin
            imem_valid[port]     = 1'b1;
            imem_wr_en[port]     = 1'b1;
            imem_byte_en[port]   = byte_en;
            imem_block_idx[port] = TILE_IDX_WIDTH'(slice_idx);
            imem_offset[port]    = offset;
            imem_wr_data[port]   = data;
        end
        "DMEM" : begin
            dmem_valid[port]     = 1'b1;
            dmem_wr_en[port]     = 1'b1;
            dmem_byte_en[port]   = byte_en;
            dmem_block_idx[port] = TILE_IDX_WIDTH'(slice_idx);
            dmem_offset[port]    = offset;
            dmem_wr_data[port]   = data;
        end
        "VGA" : begin
            vga_valid[port]      = 1'b1;
            vga_wr_en[port]      = 1'b1;
            vga_byte_en[port]    = byte_en;
            vga_block_idx[port]  = 1'b0;
            vga_offset[port]     = offset;
            vga_wr_data[port]    = data;
        end
        default : $error("mem_set_write: unknown block %s", block);
    endcase
endtask

// Apply everything staged so far on the next clock edge, then drop the ports.
task automatic mem_commit();
    @(posedge clk);
    #1;
    mem_clear_requests();
endtask

// Combinational read plus compare.
task automatic mem_check_read(input string       check_name,
                              input string       block,
                              input int          port,
                              input int          slice_idx,
                              input logic [15:0] offset,
                              input logic [31:0] exp_data);
    logic [31:0] got;

    case (block)
        "IMEM" : begin
            imem_valid[port] = 1'b1; imem_wr_en[port] = 1'b0;
            imem_block_idx[port] = TILE_IDX_WIDTH'(slice_idx);
            imem_offset[port] = offset;
        end
        "DMEM" : begin
            dmem_valid[port] = 1'b1; dmem_wr_en[port] = 1'b0;
            dmem_block_idx[port] = TILE_IDX_WIDTH'(slice_idx);
            dmem_offset[port] = offset;
        end
        "VGA" : begin
            vga_valid[port] = 1'b1; vga_wr_en[port] = 1'b0;
            vga_block_idx[port] = 1'b0;
            vga_offset[port] = offset;
        end
        default : $error("mem_check_read: unknown block %s", block);
    endcase

    #1;
    case (block)
        "IMEM"  : got = imem_rd_data[port];
        "DMEM"  : got = dmem_rd_data[port];
        "VGA"   : got = vga_rd_data[port];
        default : got = 32'bx;
    endcase

    checks_run++;
    if (got !== exp_data) begin
        checks_failed++;
        $error("[FAIL] %s : %s port %0d slice %0d offset 0x%04h -> got 0x%08h expected 0x%08h",
               check_name, block, port, slice_idx, offset, got, exp_data);
    end
    else begin
        $display("[PASS] %s : %s port %0d slice %0d offset 0x%04h -> 0x%08h",
                 check_name, block, port, slice_idx, offset, got);
    end

    mem_clear_requests();
endtask

// Compare a boolean detection flag, used for the deliberate illegal accesses.
task automatic check_flag(input string check_name, input logic got, input logic exp);
    checks_run++;
    if (got !== exp) begin
        checks_failed++;
        $error("[FAIL] %s : got %0b expected %0b", check_name, got, exp);
    end
    else begin
        $display("[PASS] %s : %0b as expected", check_name, got);
    end
endtask

// =============================
// unified memory drivers
//
// Same level driven style as the block drivers above, but here the test bench
// speaks the core's language: a plain 32 bit virtual address. Which block and
// which slice it lands on is the unified memory's job to work out, which is
// precisely what these tests are checking.
// =============================
task automatic uni_clear_requests();
    uni_req_valid   = '0;
    uni_req_wr_en   = '0;
    uni_req_byte_en = '0;
    uni_req_address = '0;
    uni_req_wr_data = '0;
endtask

// Stage a write from one tile. Nothing happens until uni_commit().
task automatic uni_set_write(input int          tile_port,
                             input logic [31:0] address,
                             input logic [31:0] data,
                             input logic [3:0]  byte_en = 4'hF);
    uni_req_valid  [tile_port] = 1'b1;
    uni_req_wr_en  [tile_port] = 1'b1;
    uni_req_byte_en[tile_port] = byte_en;
    uni_req_address[tile_port] = address;
    uni_req_wr_data[tile_port] = data;
endtask

// Stage a read from one tile without sampling it yet. Used when several tiles
// must be observed in the same cycle.
task automatic uni_set_read(input int          tile_port,
                            input logic [31:0] address);
    uni_req_valid  [tile_port] = 1'b1;
    uni_req_wr_en  [tile_port] = 1'b0;
    uni_req_byte_en[tile_port] = 4'hF;
    uni_req_address[tile_port] = address;
endtask

task automatic uni_commit();
    @(posedge clk);
    #1;
    uni_clear_requests();
endtask

// Read plus compare, from the point of view of one tile.
task automatic uni_check_read(input string       check_name,
                              input int          tile_port,
                              input logic [31:0] address,
                              input logic [31:0] exp_data);
    logic [31:0] got;

    uni_set_read(tile_port, address);
    #1;
    got = uni_rsp_rd_data[tile_port];

    checks_run++;
    if (got !== exp_data) begin
        checks_failed++;
        $error("[FAIL] %s : tile %0d (id 0x%02h) read va 0x%08h -> got 0x%08h expected 0x%08h",
               check_name, tile_port, tile_id_from_idx(tile_port), address, got, exp_data);
    end
    else begin
        $display("[PASS] %s : tile %0d (id 0x%02h) read va 0x%08h -> 0x%08h",
                 check_name, tile_port, tile_id_from_idx(tile_port), address, got);
    end

    uni_clear_requests();
endtask

// Instruction fetch plus compare. The fetch path is separate from the data
// path on purpose, so it is checked separately.
task automatic uni_check_fetch(input string       check_name,
                               input int          tile_port,
                               input logic [31:0] address,
                               input logic [31:0] exp_data);
    logic [31:0] got;

    uni_fetch_addr[tile_port] = address;
    #1;
    got = uni_fetch_data[tile_port];

    checks_run++;
    if (got !== exp_data) begin
        checks_failed++;
        $error("[FAIL] %s : tile %0d (id 0x%02h) fetch 0x%08h -> got 0x%08h expected 0x%08h",
               check_name, tile_port, tile_id_from_idx(tile_port), address, got, exp_data);
    end
    else begin
        $display("[PASS] %s : tile %0d (id 0x%02h) fetch 0x%08h -> 0x%08h",
                 check_name, tile_port, tile_id_from_idx(tile_port), address, got);
    end

    uni_fetch_addr[tile_port] = 32'b0;
endtask

// =============================
// test dispatcher
// =============================
task automatic run_fabric_ref_test(input string test);
    if (test == "va2pa_map") begin
        `include "va2pa_map.sv"
    end
    else if (test == "mem_blocks") begin
        `include "mem_blocks.sv"
    end
    else if (test == "mem_unified") begin
        `include "mem_unified.sv"
    end
    else begin
        $error("[ERROR] : test %s not found", test);
    end
endtask
