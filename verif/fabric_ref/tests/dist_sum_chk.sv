//-----------------------------------------------------------------------------
// Title            : dist_sum checker
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : dist_sum_chk.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 10/2026
//-----------------------------------------------------------------------------
// Description :
// Checks what dist_sum.c left behind. Included from check_software() in
// fabric_ref_sw_tasks.vh.
//
// Slot i sits at scratch offset 0xF000 + 4*i, so:
//   partials 0xF000, flags 0xF040, total 0xF080, my_sum 0xF0A0, role 0xF0C0
//-----------------------------------------------------------------------------

begin
    logic [31:0] exp_partial;
    logic [31:0] exp_total;

    exp_total = 32'd0;

    //===================================================================
    // 1. every core did its own share of the work, and only its own.
    //    partial of tile i is 100*i + 55.
    //===================================================================
    for (int p = 0; p < N_TILES; p++) begin
        exp_partial = 32'd100 * p + 32'd55;
        exp_total   = exp_total + exp_partial;
        check_word($sformatf("tile%0d_computed_its_partial", p),
                   dmem_word(p, 16'hF0A0), exp_partial);
    end

    //===================================================================
    // 2. all nine partials arrived in the aggregator's mailbox, each in
    //    its own slot.
    //===================================================================
    for (int p = 0; p < N_TILES; p++) begin
        check_word($sformatf("aggregator_got_partial_from_tile%0d", p),
                   dmem_word(0, 16'hF000 + 16'(4*p)), 32'd100 * p + 32'd55);
    end

    //===================================================================
    // 3. every flag was raised. This is what released the barrier.
    //===================================================================
    for (int p = 0; p < N_TILES; p++) begin
        check_word($sformatf("tile%0d_raised_its_done_flag", p),
                   dmem_word(0, 16'hF040 + 16'(4*p)), 32'd1);
    end

    //===================================================================
    // 4. the aggregated total. 1 + 2 + ... + 90 == 4095.
    //===================================================================
    check_word("aggregated_total", dmem_word(0, 16'hF080), exp_total);
    check_word("aggregated_total_is_4095", dmem_word(0, 16'hF080), 32'd4095);

    //===================================================================
    // 5. the cores really did take different paths. Tile 1,1 ran the
    //    aggregator branch, the other eight ran the worker branch.
    //===================================================================
    check_word("tile0_took_the_aggregator_path", dmem_word(0, 16'hF0C0), 32'h0A66);
    for (int p = 1; p < N_TILES; p++) begin
        check_word($sformatf("tile%0d_took_the_worker_path", p),
                   dmem_word(p, 16'hF0C0), 32'h0B0B);
    end
end
