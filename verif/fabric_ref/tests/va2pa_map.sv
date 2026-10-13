//-----------------------------------------------------------------------------
// Title            : va2pa address map directed test
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : va2pa_map.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// Directed test for the VA->PA translation in fabric_ref_pkg.
// Included from run_fabric_ref_test() in fabric_ref_tasks.vh
//
// tile id {col,row} -> flat index used by the memory blocks:
//   0x11=0  0x12=1  0x13=2
//   0x21=3  0x22=4  0x23=5
//   0x31=6  0x32=7  0x33=8
//-----------------------------------------------------------------------------

begin
    t_tile_id requestor;

    //===================================================================
    // 1. virtual (local) access - tile id 0x00 resolves to the requestor
    //    itself. Every one of the 9 cores must land on its own block.
    //===================================================================
    $display("--- 1. virtual access, tile id 0x00 aliases to the requestor ---");
    for (int i = 0; i < N_TILES; i++) begin
        requestor = tile_id_from_idx(i);
        check_pa(.check_name("local_imem"),
                 .requestor_id(requestor),
                 .va(32'h0000_0100),
                 .exp_region(REGION_IMEM),
                 .exp_tile_idx(i),
                 .exp_offset(16'h0100));
        check_pa(.check_name("local_dmem"),
                 .requestor_id(requestor),
                 .va(32'h0001_0040),
                 .exp_region(REGION_DMEM),
                 .exp_tile_idx(i),
                 .exp_offset(16'h0040));
    end

    //===================================================================
    // 2. physical cross region access - a non zero tile id goes straight
    //    to the target block regardless of who is asking.
    //===================================================================
    $display("--- 2. physical cross region access ---");
    check_pa(.check_name("remote_imem_33"),
             .requestor_id(8'h11),
             .va(32'h3300_0004),
             .exp_region(REGION_IMEM),
             .exp_tile_idx(8),
             .exp_offset(16'h0004));
    check_pa(.check_name("remote_dmem_23"),
             .requestor_id(8'h11),
             .va(32'h2301_2340),
             .exp_region(REGION_DMEM),
             .exp_tile_idx(5),
             .exp_offset(16'h2340));
    // a core reaching its own block through its explicit physical id must
    // land in exactly the same place as the virtual form used above.
    check_pa(.check_name("explicit_self_id"),
             .requestor_id(8'h22),
             .va(32'h2200_0100),
             .exp_region(REGION_IMEM),
             .exp_tile_idx(4),
             .exp_offset(16'h0100));

    //===================================================================
    // 3. nibble order lock - {col,row}, matching fabric.sv local_tile_id.
    //    0x12 and 0x21 must NOT map to the same block.
    //===================================================================
    $display("--- 3. tile id nibble order is {col,row} ---");
    check_pa(.check_name("tile_0x12_col1_row2"),
             .requestor_id(8'h11),
             .va(32'h1200_0000),
             .exp_region(REGION_IMEM),
             .exp_tile_idx(1),
             .exp_offset(16'h0000));
    check_pa(.check_name("tile_0x21_col2_row1"),
             .requestor_id(8'h11),
             .va(32'h2100_0000),
             .exp_region(REGION_IMEM),
             .exp_tile_idx(3),
             .exp_offset(16'h0000));

    //===================================================================
    // 4. the scratch addresses that app/defines/fabric_defines.h already
    //    uses must keep working unchanged.
    //===================================================================
    $display("--- 4. fabric_defines.h scratch addresses ---");
    // TILE_1_1_SCRATCH = 0x1101F000 -> tile 0x11, bit[16]=1 so DMEM, offset 0xF000
    check_pa(.check_name("TILE_1_1_SCRATCH"),
             .requestor_id(8'h33),
             .va(32'h1101_F000),
             .exp_region(REGION_DMEM),
             .exp_tile_idx(0),
             .exp_offset(16'hF000));
    // TILE_3_2_SCRATCH = 0x3201F000 -> tile 0x32 = col3,row2 -> idx 7
    check_pa(.check_name("TILE_3_2_SCRATCH"),
             .requestor_id(8'h11),
             .va(32'h3201_F000),
             .exp_region(REGION_DMEM),
             .exp_tile_idx(7),
             .exp_offset(16'hF000));
    // LOCAL_SCRATCH = 0x0001F000 -> virtual, resolves to the requestor
    check_pa(.check_name("LOCAL_SCRATCH"),
             .requestor_id(8'h23),
             .va(32'h0001_F000),
             .exp_region(REGION_DMEM),
             .exp_tile_idx(5),
             .exp_offset(16'hF000));

    //===================================================================
    // 5. IMEM / DMEM split on bit [16], including the boundaries.
    //===================================================================
    $display("--- 5. bit[16] selects IMEM vs DMEM ---");
    check_pa(.check_name("imem_first_byte"),
             .requestor_id(8'h11), .va(32'h0000_0000),
             .exp_region(REGION_IMEM), .exp_tile_idx(0), .exp_offset(16'h0000));
    check_pa(.check_name("imem_last_byte"),
             .requestor_id(8'h11), .va(32'h0000_FFFF),
             .exp_region(REGION_IMEM), .exp_tile_idx(0), .exp_offset(16'hFFFF));
    check_pa(.check_name("dmem_first_byte"),
             .requestor_id(8'h11), .va(32'h0001_0000),
             .exp_region(REGION_DMEM), .exp_tile_idx(0), .exp_offset(16'h0000));
    check_pa(.check_name("dmem_last_byte"),
             .requestor_id(8'h11), .va(32'h0001_FFFF),
             .exp_region(REGION_DMEM), .exp_tile_idx(0), .exp_offset(16'hFFFF));

    //===================================================================
    // 6. WhoAmI
    //===================================================================
    $display("--- 6. WhoAmI ---");
    check_pa(.check_name("who_am_i"),
             .requestor_id(8'h23),
             .va(32'h00FF_FFFF),
             .exp_region(REGION_WHO_AM_I),
             .exp_tile_idx(0),
             .exp_offset(16'h0000));

    //===================================================================
    // 7. VGA window - one frame buffer shared by the whole fabric.
    //===================================================================
    $display("--- 7. VGA window ---");
    check_pa(.check_name("vga_first_byte"),
             .requestor_id(8'h11), .va(32'h00FF_0000),
             .exp_region(REGION_VGA), .exp_tile_idx(0), .exp_offset(16'h0000));
    check_pa(.check_name("vga_last_byte"),
             .requestor_id(8'h11), .va({8'h00, VGA_MEM_REGION_ROOF}),
             .exp_region(REGION_VGA), .exp_tile_idx(0), .exp_offset(16'(SIZE_VGA_MEM - 1)));

    //===================================================================
    // 8. CR window
    //===================================================================
    $display("--- 8. CR window ---");
    check_pa(.check_name("cr_first_byte"),
             .requestor_id(8'h11), .va(32'h00FE_0000),
             .exp_region(REGION_CR), .exp_tile_idx(0), .exp_offset(16'h0000));
    check_pa(.check_name("cr_led"),
             .requestor_id(8'h11), .va(32'h00FE_7018),
             .exp_region(REGION_CR), .exp_tile_idx(0), .exp_offset(16'h7018));
    check_pa(.check_name("cr_last_byte"),
             .requestor_id(8'h11), .va(32'h00FE_FFFF),
             .exp_region(REGION_CR), .exp_tile_idx(0), .exp_offset(16'hFFFF));

    //===================================================================
    // 9. reserved bits [23:17] must fail LOUDLY rather than alias.
    //    This is the deliberate rogue pointer case.
    //===================================================================
    $display("--- 9. reserved bits [23:17] violations ---");
    // first address above the 128KB per tile map
    check_pa(.check_name("rsvd_just_past_dmem"),
             .requestor_id(8'h11), .va(32'h0002_0000),
             .exp_region(REGION_NONE), .exp_tile_idx(0), .exp_offset(16'h0000),
             .exp_rsvd_error(1'b1));
    // rogue pointer in the middle of the reserved space, on a remote tile
    check_pa(.check_name("rsvd_remote_rogue"),
             .requestor_id(8'h11), .va(32'h11A0_0000),
             .exp_region(REGION_NONE), .exp_tile_idx(0), .exp_offset(16'h0000),
             .exp_rsvd_error(1'b1));
    // one byte past the end of the VGA frame buffer
    check_pa(.check_name("rsvd_just_past_vga"),
             .requestor_id(8'h11), .va({8'h00, VGA_MEM_REGION_ROOF + 24'd1}),
             .exp_region(REGION_NONE), .exp_tile_idx(0), .exp_offset(16'h0000),
             .exp_rsvd_error(1'b1));

    //===================================================================
    // 10. a tile id that does not exist in the 3x3 mesh
    //===================================================================
    $display("--- 10. tile id outside the mesh ---");
    check_pa(.check_name("tile_id_out_of_mesh"),
             .requestor_id(8'h11), .va(32'h4400_0000),
             .exp_region(REGION_IMEM), .exp_tile_idx(0), .exp_offset(16'h0000),
             .exp_rsvd_error(1'b0), .exp_tile_error(1'b1));
    check_pa(.check_name("tile_id_zero_col"),
             .requestor_id(8'h11), .va(32'h0500_0000),
             .exp_region(REGION_IMEM), .exp_tile_idx(0), .exp_offset(16'h0000),
             .exp_rsvd_error(1'b0), .exp_tile_error(1'b1));
end
