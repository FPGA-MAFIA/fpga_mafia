//-----------------------------------------------------------------------------
// Title            : non_local_rd_wr checker
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : non_local_rd_wr_chk.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 10/2026
//-----------------------------------------------------------------------------
// Description :
// Checks what non_local_rd_wr.c left behind. Included from check_software()
// in fabric_ref_sw_tasks.vh.
//
// Slot i of a mailbox lives at scratch offset 0xF000 + 4*i, and the private
// results start at 0xF040 (scratch[16]).
//-----------------------------------------------------------------------------

begin
    logic [31:0] id_p;
    logic [31:0] id_11;
    logic [31:0] id_33;

    id_11 = {24'b0, tile_id_from_idx(0)}; // 0x11
    id_33 = {24'b0, tile_id_from_idx(8)}; // 0x33

    //===================================================================
    // 1. tile 1,1's mailbox collected all nine ids, each in its own slot.
    //    Nine remote cores wrote nine distinct slots of ONE tile.
    //===================================================================
    for (int p = 0; p < N_TILES; p++) begin
        id_p = {24'b0, tile_id_from_idx(p)};
        check_word($sformatf("tile11_mailbox_slot%0d_from_tile_0x%02h", p, tile_id_from_idx(p)),
                   dmem_word(0, 16'hF000 + 16'(4*p)), id_p);
    end

    //===================================================================
    // 2. the same for tile 3,3, with a different value, proving the model
    //    is not hardwired to a single remote destination.
    //===================================================================
    for (int p = 0; p < N_TILES; p++) begin
        id_p = {24'b0, tile_id_from_idx(p)};
        check_word($sformatf("tile33_mailbox_slot%0d_from_tile_0x%02h", p, tile_id_from_idx(p)),
                   dmem_word(8, 16'hF000 + 16'(4*p)), id_p + 32'h100);
    end

    //===================================================================
    // 3. every core's private result is its own, untouched by the remote
    //    traffic hitting tiles 1,1 and 3,3.
    //===================================================================
    for (int p = 0; p < N_TILES; p++) begin
        id_p = {24'b0, tile_id_from_idx(p)};
        check_word($sformatf("tile%0d_private_result_intact", p),
                   dmem_word(p, 16'hF040), id_p + 32'h2000);
    end

    //===================================================================
    // 4. cross region READS - every core observed the same two remote
    //    values, written by tiles 1,1 and 3,3.
    //===================================================================
    for (int p = 0; p < N_TILES; p++) begin
        check_word($sformatf("tile%0d_read_tile11_slot0", p),
                   dmem_word(p, 16'hF044), id_11);
        check_word($sformatf("tile%0d_read_tile33_slot8", p),
                   dmem_word(p, 16'hF048), id_33 + 32'h100);
    end

    //===================================================================
    // 5. each core read its OWN slot back out of tile 1,1, through the
    //    explicit physical address rather than the local 0x00 alias.
    //===================================================================
    for (int p = 0; p < N_TILES; p++) begin
        id_p = {24'b0, tile_id_from_idx(p)};
        check_word($sformatf("tile%0d_read_back_own_slot", p),
                   dmem_word(p, 16'hF04C), id_p);
    end
end
