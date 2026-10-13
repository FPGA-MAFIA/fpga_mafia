//-----------------------------------------------------------------------------
// Title            : unified memory blocks directed test
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : mem_blocks.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// Directed test for fabric_ref_mem_block, the building block of the unified
// memory. Included from run_fabric_ref_test() in fabric_ref_tasks.vh
//
// What this proves:
//  1. all 9 ports write their own tile slice in ONE cycle, no arbitration
//  2. every core can read every other core's slice (cross region access)
//  3. slices are truly independent, a write to one never touches another
//  4. byte enables work, including partial word writes
//  5. IMEM and DMEM are separate, the same slice/offset in each holds
//     different data
//  6. the VGA block is a single frame buffer shared by all cores
//  7. illegal accesses are DETECTED - same cycle same byte write collisions,
//     out of range offsets and out of range slice indices
//-----------------------------------------------------------------------------

begin
    logic [31:0] exp_word;

    //===================================================================
    // 1. nine parallel writes in a single cycle, one per tile slice
    //===================================================================
    $display("--- 1. nine cores write their own slice in one cycle ---");
    for (int p = 0; p < N_TILES; p++) begin
        mem_set_write(.block("DMEM"), .port(p), .slice_idx(p),
                      .offset(16'h1000), .data(32'hA0000000 + p));
    end
    mem_commit();

    for (int p = 0; p < N_TILES; p++) begin
        mem_check_read(.check_name($sformatf("parallel_wr_slice%0d", p)),
                       .block("DMEM"), .port(p), .slice_idx(p),
                       .offset(16'h1000), .exp_data(32'hA0000000 + p));
    end

    //===================================================================
    // 2. cross region access - every core reads every slice.
    //    Core p reads slice s and must see the data core s wrote above.
    //===================================================================
    $display("--- 2. every core reads every other core's slice ---");
    for (int p = 0; p < N_TILES; p++) begin
        for (int s = 0; s < N_TILES; s++) begin
            mem_check_read(.check_name($sformatf("core%0d_reads_slice%0d", p, s)),
                           .block("DMEM"), .port(p), .slice_idx(s),
                           .offset(16'h1000), .exp_data(32'hA0000000 + s));
        end
    end

    //===================================================================
    // 3. slices are independent - writing slice 0 must not disturb the
    //    neighbours that were written in step 1.
    //===================================================================
    $display("--- 3. writing one slice does not disturb the others ---");
    mem_set_write(.block("DMEM"), .port(0), .slice_idx(0),
                  .offset(16'h1000), .data(32'hDEADBEEF));
    mem_commit();
    mem_check_read(.check_name("slice0_updated"),
                   .block("DMEM"), .port(0), .slice_idx(0),
                   .offset(16'h1000), .exp_data(32'hDEADBEEF));
    for (int s = 1; s < N_TILES; s++) begin
        mem_check_read(.check_name($sformatf("slice%0d_untouched", s)),
                       .block("DMEM"), .port(0), .slice_idx(s),
                       .offset(16'h1000), .exp_data(32'hA0000000 + s));
    end

    //===================================================================
    // 4. byte enables
    //===================================================================
    $display("--- 4. byte enables ---");
    mem_set_write(.block("DMEM"), .port(0), .slice_idx(4),
                  .offset(16'h2000), .data(32'h11223344), .byte_en(4'hF));
    mem_commit();
    mem_check_read(.check_name("be_full_word"),
                   .block("DMEM"), .port(0), .slice_idx(4),
                   .offset(16'h2000), .exp_data(32'h11223344));

    // only lane 0
    mem_set_write(.block("DMEM"), .port(0), .slice_idx(4),
                  .offset(16'h2000), .data(32'hFFFFFF99), .byte_en(4'h1));
    mem_commit();
    mem_check_read(.check_name("be_lane0_only"),
                   .block("DMEM"), .port(0), .slice_idx(4),
                   .offset(16'h2000), .exp_data(32'h11223399));

    // only lane 3
    mem_set_write(.block("DMEM"), .port(0), .slice_idx(4),
                  .offset(16'h2000), .data(32'h77FFFFFF), .byte_en(4'h8));
    mem_commit();
    mem_check_read(.check_name("be_lane3_only"),
                   .block("DMEM"), .port(0), .slice_idx(4),
                   .offset(16'h2000), .exp_data(32'h77223399));

    // two middle lanes
    mem_set_write(.block("DMEM"), .port(0), .slice_idx(4),
                  .offset(16'h2000), .data(32'hFFAABBFF), .byte_en(4'h6));
    mem_commit();
    mem_check_read(.check_name("be_lanes_1_2"),
                   .block("DMEM"), .port(0), .slice_idx(4),
                   .offset(16'h2000), .exp_data(32'h77AABB99));

    //===================================================================
    // 5. IMEM and DMEM are separate blocks - an instruction fetch can
    //    never be disturbed by a data write to the same slice/offset.
    //===================================================================
    $display("--- 5. IMEM and DMEM are independent blocks ---");
    mem_set_write(.block("IMEM"), .port(3), .slice_idx(6),
                  .offset(16'h0040), .data(32'h1111_1111));
    mem_set_write(.block("DMEM"), .port(3), .slice_idx(6),
                  .offset(16'h0040), .data(32'h2222_2222));
    mem_commit();
    mem_check_read(.check_name("imem_slice6"),
                   .block("IMEM"), .port(3), .slice_idx(6),
                   .offset(16'h0040), .exp_data(32'h1111_1111));
    mem_check_read(.check_name("dmem_slice6"),
                   .block("DMEM"), .port(3), .slice_idx(6),
                   .offset(16'h0040), .exp_data(32'h2222_2222));

    //===================================================================
    // 6. the VGA frame buffer is shared - core 8 must see what core 1
    //    wrote, and two cores can paint disjoint areas in one cycle.
    //===================================================================
    $display("--- 6. shared VGA frame buffer ---");
    mem_set_write(.block("VGA"), .port(1), .slice_idx(0),
                  .offset(16'h0000), .data(32'hCAFEBABE));
    mem_set_write(.block("VGA"), .port(7), .slice_idx(0),
                  .offset(16'h0100), .data(32'h12345678));
    mem_commit();
    mem_check_read(.check_name("vga_shared_read_by_core8"),
                   .block("VGA"), .port(8), .slice_idx(0),
                   .offset(16'h0000), .exp_data(32'hCAFEBABE));
    mem_check_read(.check_name("vga_second_area"),
                   .block("VGA"), .port(0), .slice_idx(0),
                   .offset(16'h0100), .exp_data(32'h12345678));
    // last legal VGA word
    mem_set_write(.block("VGA"), .port(2), .slice_idx(0),
                  .offset(16'(SIZE_VGA_MEM - 4)), .data(32'h0BADF00D));
    mem_commit();
    mem_check_read(.check_name("vga_last_word"),
                   .block("VGA"), .port(2), .slice_idx(0),
                   .offset(16'(SIZE_VGA_MEM - 4)), .exp_data(32'h0BADF00D));

    //===================================================================
    // 7. illegal accesses must be DETECTED.
    //
    // The detection logic drives a MAFIA_ASSERT, and a single $error would
    // fail the build (build.py fails on more than one "Error" in the vsim
    // output). So assertions are muted while the illegal access is applied
    // and the detection signal itself is checked instead. The assertions are
    // proven to actually fire by temporarily re-enabling them by hand, see
    // the commit message.
    //===================================================================
    $display("--- 7a. same cycle same byte write collision ---");
    mem_assert_en = 1'b0;
    // two different cores, same slice, same byte -> collision
    mem_set_write(.block("DMEM"), .port(2), .slice_idx(5),
                  .offset(16'h3000), .data(32'hAAAAAAAA));
    mem_set_write(.block("DMEM"), .port(6), .slice_idx(5),
                  .offset(16'h3000), .data(32'hBBBBBBBB));
    #1;
    check_flag(.check_name("collision_detected"),
               .got(dmem_block.wr_collision), .exp(1'b1));
    mem_commit();

    // same cycle, same slice, but DIFFERENT bytes - this is legal and is
    // exactly what the split memory is for.
    $display("--- 7b. same slice different bytes is legal ---");
    mem_set_write(.block("DMEM"), .port(2), .slice_idx(5),
                  .offset(16'h4000), .data(32'h0000CDEF), .byte_en(4'h3));
    mem_set_write(.block("DMEM"), .port(6), .slice_idx(5),
                  .offset(16'h4000), .data(32'h89AB0000), .byte_en(4'hC));
    #1;
    check_flag(.check_name("no_collision_different_bytes"),
               .got(dmem_block.wr_collision), .exp(1'b0));
    mem_commit();
    mem_assert_en = 1'b1;
    mem_check_read(.check_name("merged_partial_writes"),
                   .block("DMEM"), .port(0), .slice_idx(5),
                   .offset(16'h4000), .exp_data(32'h89ABCDEF));

    $display("--- 7c. offset past the end of a slice ---");
    mem_assert_en = 1'b0;
    // last legal DMEM offset is MEM_BLOCK_SIZE-4, so -2 straddles the end
    mem_set_write(.block("DMEM"), .port(0), .slice_idx(0),
                  .offset(16'(MEM_BLOCK_SIZE - 2)), .data(32'hFFFFFFFF));
    #1;
    check_flag(.check_name("range_error_detected"),
               .got(dmem_block.port_range_error[0]), .exp(1'b1));
    mem_commit();

    // the VGA block is smaller, so an offset that is fine for DMEM is out of
    // range here. This confirms the bound really follows BLOCK_SIZE.
    mem_set_write(.block("VGA"), .port(0), .slice_idx(0),
                  .offset(16'(SIZE_VGA_MEM)), .data(32'hFFFFFFFF));
    #1;
    check_flag(.check_name("vga_range_error_detected"),
               .got(vga_block.port_range_error[0]), .exp(1'b1));
    mem_commit();

    $display("--- 7d. slice index outside the mesh ---");
    mem_set_write(.block("DMEM"), .port(0), .slice_idx(N_TILES),
                  .offset(16'h0000), .data(32'hFFFFFFFF));
    #1;
    check_flag(.check_name("block_error_detected"),
               .got(dmem_block.port_block_error[0]), .exp(1'b1));
    mem_commit();
    mem_assert_en = 1'b1;

    //===================================================================
    // 8. after all the illegal traffic above, the memory must still hold
    //    the data written in step 1. Nothing was corrupted.
    //===================================================================
    $display("--- 8. no corruption from the rejected accesses ---");
    for (int s = 1; s < N_TILES; s++) begin
        mem_check_read(.check_name($sformatf("final_slice%0d_intact", s)),
                       .block("DMEM"), .port(0), .slice_idx(s),
                       .offset(16'h1000), .exp_data(32'hA0000000 + s));
    end
end
