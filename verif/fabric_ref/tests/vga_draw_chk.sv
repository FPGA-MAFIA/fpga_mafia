//-----------------------------------------------------------------------------
// Title            : vga_draw checker
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : vga_draw_chk.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 10/2026
//-----------------------------------------------------------------------------
// Description :
// Checks what vga_draw.c left behind. Included from check_software() in
// fabric_ref_sw_tasks.vh.
//
// The strong check here is the last one. Rather than sampling the nine boxes
// and hoping nothing else moved, it rebuilds the entire 38400 byte frame
// buffer from the software's own geometry and compares every single byte.
// That catches a core spilling outside its cell, two cores aliasing onto the
// same address, and a write landing somewhere nobody asked for.
//-----------------------------------------------------------------------------

begin
    localparam int CELL_BYTE_COLS = 26;
    localparam int CELL_ROWS      = 160;
    localparam int BOX_BYTE_COLS  = 8;
    localparam int BOX_ROWS       = 24;
    localparam int BOX_MARGIN_BC  = 2;
    localparam int BOX_MARGIN_ROW = 20;

    logic [7:0] expected [SIZE_VGA_MEM-1:0];
    int         addr;
    int         bx0;
    int         y0;
    int         mismatches;
    logic [7:0] pattern;

    //===================================================================
    // 1. every core got as far as the breadcrumb, so a blank cell below
    //    means a lost write and not a core that never ran.
    //===================================================================
    for (int p = 0; p < N_TILES; p++) begin
        check_word($sformatf("tile%0d_finished_drawing", p),
                   dmem_word(p, 16'hF000), 32'h0007D02E);
    end

    //===================================================================
    // 2. build the picture the software was supposed to draw.
    //===================================================================
    foreach (expected[i]) expected[i] = 8'h00;

    for (int p = 0; p < N_TILES; p++) begin
        pattern = 8'h11 * 8'(p + 1);
        bx0 = (int'(tile_id_from_idx(p)[7:4]) - 1) * CELL_BYTE_COLS + BOX_MARGIN_BC;
        y0  = (int'(tile_id_from_idx(p)[3:0]) - 1) * CELL_ROWS      + BOX_MARGIN_ROW;
        for (int r = 0; r < BOX_ROWS; r++) begin
            for (int b = 0; b < BOX_BYTE_COLS; b++) begin
                addr = ((y0 + r) / 4) * 320 + (bx0 + b) * 4 + ((y0 + r) % 4);
                expected[addr] = pattern;
            end
        end
    end

    //===================================================================
    // 3. spot check each box: its first and last byte must carry that
    //    core's own signature and nobody else's.
    //===================================================================
    for (int p = 0; p < N_TILES; p++) begin
        pattern = 8'h11 * 8'(p + 1);
        bx0 = (int'(tile_id_from_idx(p)[7:4]) - 1) * CELL_BYTE_COLS + BOX_MARGIN_BC;
        y0  = (int'(tile_id_from_idx(p)[3:0]) - 1) * CELL_ROWS      + BOX_MARGIN_ROW;

        addr = (y0 / 4) * 320 + bx0 * 4 + (y0 % 4);
        check_word($sformatf("tile_0x%02h_box_top_left", tile_id_from_idx(p)),
                   {24'b0, vga_byte(addr)}, {24'b0, pattern});

        addr = ((y0 + BOX_ROWS - 1) / 4) * 320 + (bx0 + BOX_BYTE_COLS - 1) * 4
             + ((y0 + BOX_ROWS - 1) % 4);
        check_word($sformatf("tile_0x%02h_box_bottom_right", tile_id_from_idx(p)),
                   {24'b0, vga_byte(addr)}, {24'b0, pattern});
    end

    //===================================================================
    // 4. the whole frame buffer, byte for byte. Nine cores wrote one
    //    shared memory concurrently and the result is exactly the nine
    //    boxes, with every other byte still at zero.
    //===================================================================
    mismatches = 0;
    for (int a = 0; a < SIZE_VGA_MEM; a++) begin
        if (vga_byte(a) !== expected[a]) begin
            if (mismatches < 8) begin // keep the log readable
                $display("[INFO] vga byte %0d : got 0x%02h expected 0x%02h",
                         a, vga_byte(a), expected[a]);
            end
            mismatches++;
        end
    end
    check_word("whole_frame_buffer_matches", mismatches, 32'd0);

    print_vga_ref_screen(test);
end
