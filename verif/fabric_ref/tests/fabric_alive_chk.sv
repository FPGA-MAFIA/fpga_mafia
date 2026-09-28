//-----------------------------------------------------------------------------
// Title            : fabric_alive checker
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : fabric_alive_chk.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// Checks what fabric_alive.c left behind in each tile's scratch pad.
// Included from check_software() in fabric_ref_sw_tasks.vh.
//
// LOCAL_SCRATCH is 0x0001F000, which the translation resolves to DMEM offset
// 0xF000 of whichever tile issued the access. Nine cores ran the same store
// instruction, so nine different slices must now hold nine different values.
//-----------------------------------------------------------------------------

begin
    logic [31:0] me;

    for (int p = 0; p < N_TILES; p++) begin
        me = {24'b0, tile_id_from_idx(p)};
        check_word($sformatf("tile%0d_wrote_its_own_id",   p), dmem_word(p, 16'hF000), me);
        check_word($sformatf("tile%0d_read_back_its_own",  p), dmem_word(p, 16'hF004), me + 1);
        check_word($sformatf("tile%0d_ran_to_completion",  p), dmem_word(p, 16'hF008), 32'h0A11CE00);
    end
end
