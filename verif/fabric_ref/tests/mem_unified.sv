//-----------------------------------------------------------------------------
// Title            : fabric reference model unified memory test
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : mem_unified.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// Directed test for fabric_ref_mem, the unified memory of the fabric
// reference model (github issue #454).
//
// The mem_blocks test already proved that a single block stores bytes
// correctly. This test is about everything built on top of that: the VA->PA
// translation, the steering into the right block and slice, and the response
// mux. The whole point is that nine cores can run the SAME binary, each
// reach its OWN memory through a tile id of 0x00, and still reach every other
// tile's memory by naming it explicitly.
//
// Address shorthand used below, all of it straight out of fabric_ref_pkg:
//   {tile, 8'h00, offset} -> IMEM of that tile   (bit [16] = 0)
//   {tile, 8'h01, offset} -> DMEM of that tile   (bit [16] = 1)
//   {tile, 24'hFF_xxxx}   -> the shared VGA frame buffer
//   {tile, 24'hFE_xxxx}   -> that tile's control registers
// A tile field of 0x00 means "whoever is asking".
//-----------------------------------------------------------------------------

begin
    logic [31:0] exp_local   [N_TILES-1:0];
    logic [31:0] va;
    t_tile_id    tid;

    $display("=======================================================");
    $display("[INFO] mem_unified : unified memory, VA->PA and steering");
    $display("=======================================================");

    //===================================================================
    // 1. The same virtual address on every tile must reach nine
    //    different physical places. This is the heart of issue #454.
    //    All nine writes are issued in the SAME cycle.
    //===================================================================
    $display("--- 1. local virtual writes, all nine tiles in one cycle ---");
    for (int p = 0; p < N_TILES; p++) begin
        exp_local[p] = 32'hA0000000 + p;
        uni_set_write(p, 32'h0001_1000, exp_local[p]);
    end
    uni_commit();

    // each tile sees its own value through the same virtual address
    for (int p = 0; p < N_TILES; p++) begin
        uni_check_read($sformatf("1a_local_va_tile%0d", p), p, 32'h0001_1000, exp_local[p]);
    end

    // and tile 0 can reach all nine physically, which proves they really are
    // nine separate locations and not one aliased one
    for (int p = 0; p < N_TILES; p++) begin
        tid = tile_id_from_idx(p);
        va  = {tid, 8'h01, 16'h1000};
        uni_check_read($sformatf("1b_physical_from_tile0_to_tile%0d", p), 0, va, exp_local[p]);
    end

    //===================================================================
    // 2. Cross region access - one tile writing into another tile's DMEM
    //===================================================================
    $display("--- 2. cross region write ---");
    // Plant a sentinel in the writer's own slice first. IMEM and DMEM start
    // uninitialized, exactly like the arrays in rv32i_ref, so without this the
    // "untouched" check below would only be comparing against X.
    uni_set_write(0, 32'h0001_2000, 32'h5EED_0000);
    uni_commit();
    // tile 0 (id 0x11) writes into tile 8 (id 0x33)
    uni_set_write(0, {tile_id_from_idx(8), 8'h01, 16'h2000}, 32'hCAFE_0033);
    uni_commit();
    // tile 8 reads it back as if it were its own local memory
    uni_check_read("2a_target_reads_locally", 8, 32'h0001_2000, 32'hCAFE_0033);
    // and the writer's own slice at the same offset still holds the sentinel
    uni_check_read("2b_writer_untouched",     0, 32'h0001_2000, 32'h5EED_0000);

    //===================================================================
    // 3. Bit [16] really does separate IMEM from DMEM
    //===================================================================
    $display("--- 3. IMEM and DMEM are independent ---");
    uni_set_write(3, 32'h0000_3000, 32'h1111_1111); // IMEM, bit16 = 0
    uni_commit();
    uni_set_write(3, 32'h0001_3000, 32'h2222_2222); // DMEM, bit16 = 1
    uni_commit();
    uni_check_read("3a_imem_kept_its_value", 3, 32'h0000_3000, 32'h1111_1111);
    uni_check_read("3b_dmem_kept_its_value", 3, 32'h0001_3000, 32'h2222_2222);

    //===================================================================
    // 4. The VGA frame buffer is shared by the whole fabric.
    //    Unlike IMEM and DMEM, the tile field must NOT create nine copies.
    //===================================================================
    $display("--- 4. shared VGA frame buffer ---");
    uni_set_write(2, {8'h00, VGA_MEM_REGION_FLOOR + 24'h100}, 32'h5A5A_1234);
    uni_commit();
    for (int p = 0; p < N_TILES; p++) begin
        uni_check_read($sformatf("4a_vga_seen_by_tile%0d", p),
                       p, {8'h00, VGA_MEM_REGION_FLOOR + 24'h100}, 32'h5A5A_1234);
    end
    // naming a different tile explicitly must land on the same frame buffer
    uni_check_read("4b_vga_via_explicit_tile_id",
                   5, {tile_id_from_idx(8), VGA_MEM_REGION_FLOOR + 24'h100}, 32'h5A5A_1234);

    //===================================================================
    // 5. Control registers are per tile, unlike VGA
    //===================================================================
    $display("--- 5. per tile control registers ---");
    uni_set_write(0, {8'h00, CR_MEM_REGION_FLOOR + 24'h18}, 32'h0000_00FF); // local CR_LED
    uni_commit();
    uni_check_read("5a_owner_reads_its_cr", 0,
                   {8'h00, CR_MEM_REGION_FLOOR + 24'h18}, 32'h0000_00FF);
    uni_check_read("5b_other_tile_reads_it_physically", 1,
                   {tile_id_from_idx(0), CR_MEM_REGION_FLOOR + 24'h18}, 32'h0000_00FF);
    uni_check_read("5c_other_tile_own_cr_untouched", 1,
                   {8'h00, CR_MEM_REGION_FLOOR + 24'h18}, 32'h0000_0000);

    //===================================================================
    // 6. The instruction fetch port reads the same IMEM the data port wrote
    //===================================================================
    $display("--- 6. instruction fetch path ---");
    uni_set_write(5, 32'h0000_0040, 32'h0000_0073); // looks like an ebreak
    uni_commit();
    uni_check_fetch("6a_fetch_own_imem",       5, 32'h0000_0040, 32'h0000_0073);
    // a fetch that names another tile explicitly reaches that tile's code
    uni_check_fetch("6b_fetch_other_tile_imem", 0,
                    {tile_id_from_idx(5), 8'h00, 16'h0040}, 32'h0000_0073);
    // and tile 5's data port still sees the same bytes
    uni_check_read ("6c_same_word_via_data_port", 5, 32'h0000_0040, 32'h0000_0073);
    // a fetch must not be disturbed by a data access in the same cycle
    uni_set_read(5, 32'h0001_1000);
    uni_check_fetch("6d_fetch_during_data_access", 5, 32'h0000_0040, 32'h0000_0073);
    uni_clear_requests();

    //===================================================================
    // 7. Byte enables survive the trip through the wrapper
    //===================================================================
    $display("--- 7. byte enables ---");
    uni_set_write(4, 32'h0001_4000, 32'hFFFF_FFFF);
    uni_commit();
    uni_set_write(4, 32'h0001_4000, 32'h0000_0011, 4'b0001); // lane 0 only
    uni_commit();
    uni_check_read("7a_only_lane0_changed", 4, 32'h0001_4000, 32'hFFFF_FF11);
    uni_set_write(4, 32'h0001_4000, 32'h2200_0000, 4'b1000); // lane 3 only
    uni_commit();
    uni_check_read("7b_only_lane3_changed", 4, 32'h0001_4000, 32'h22FF_FF11);

    //===================================================================
    // 8. Illegal accesses must be reported, not silently aliased.
    //    The assertion is muted here on purpose, exactly like the
    //    mem_blocks test does, so the detection logic can be checked
    //    without failing the run.
    //===================================================================
    $display("--- 8. illegal accesses are detected ---");
    uni_assert_en = 1'b0;

    // 8a - a rogue pointer with reserved bits set
    uni_set_write(6, 32'h0002_0000, 32'hDEAD_DEAD); // bit [17] is set
    #1;
    check_flag("8a_rsvd_error_detected", |u_unified_mem.req_rsvd_error, 1'b1);
    check_flag("8a_not_forwarded_to_imem", u_unified_mem.imem_valid[6], 1'b0);
    check_flag("8a_not_forwarded_to_dmem", u_unified_mem.dmem_valid[6], 1'b0);
    uni_commit();

    // 8b - a tile that does not exist in a 3x3 mesh
    uni_set_write(6, 32'h4401_0000, 32'hDEAD_DEAD);
    #1;
    check_flag("8b_tile_error_detected", |u_unified_mem.req_tile_error, 1'b1);
    check_flag("8b_not_forwarded",       u_unified_mem.dmem_valid[6],   1'b0);
    uni_commit();

    // 8c - WhoAmI belongs to the core and must never reach memory
    uni_set_read(6, 32'h00FF_FFFF);
    #1;
    check_flag("8c_who_am_i_detected", |u_unified_mem.req_who_am_i, 1'b1);
    check_flag("8c_not_forwarded",     u_unified_mem.dmem_valid[6], 1'b0);
    uni_clear_requests();

    // 8d - an instruction fetch that wandered outside the IMEM region
    uni_fetch_addr[6] = 32'h0001_0000; // bit [16] set, that is DMEM
    #1;
    check_flag("8d_fetch_error_detected", |u_unified_mem.fetch_region_error, 1'b1);
    uni_fetch_addr[6] = 32'h0000_0000;
    #1;
    check_flag("8d_fetch_error_clears", |u_unified_mem.fetch_region_error, 1'b0);

    uni_assert_en = 1'b1;
    delay(1);

    //===================================================================
    // 9. Nothing above corrupted anything. If a bad address had been
    //    forwarded instead of rejected, this is where it would show.
    //===================================================================
    $display("--- 9. final sweep, memory is still intact ---");
    for (int p = 0; p < N_TILES; p++) begin
        uni_check_read($sformatf("9a_local_still_intact_tile%0d", p),
                       p, 32'h0001_1000, exp_local[p]);
    end
    uni_check_read("9b_cross_region_still_intact", 8, 32'h0001_2000, 32'hCAFE_0033);
    uni_check_read("9b_sentinel_still_intact",     0, 32'h0001_2000, 32'h5EED_0000);
    uni_check_read("9c_imem_still_intact",         3, 32'h0000_3000, 32'h1111_1111);
    uni_check_read("9d_vga_still_intact",          7,
                   {8'h00, VGA_MEM_REGION_FLOOR + 24'h100}, 32'h5A5A_1234);
    uni_check_read("9e_cr_still_intact",           0,
                   {8'h00, CR_MEM_REGION_FLOOR + 24'h18}, 32'h0000_00FF);
    uni_check_read("9f_byte_enables_still_intact", 4, 32'h0001_4000, 32'h22FF_FF11);
end
