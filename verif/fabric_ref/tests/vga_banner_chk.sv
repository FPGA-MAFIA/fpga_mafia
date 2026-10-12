//-----------------------------------------------------------------------------
// Title            : vga_banner checker
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : vga_banner_chk.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 10/2026
//-----------------------------------------------------------------------------
// Description :
// Checks what vga_banner.c left on the shared frame buffer. The expected
// words are the same glyph constants draw_char uses (the *_TOP / *_BTM
// macros in graphic_vga.h). A character at text column c of text row r is
// two words: the top half at byte r*320 + c*4, the bottom half 320 bytes
// later. Included from check_software() in fabric_ref_sw_tasks.vh.
//-----------------------------------------------------------------------------

begin
    localparam int TEXT_ROW  = 2;
    localparam int TEXT_COL  = 31;
    localparam int N_CHARS   = 18;
    localparam int LINE_BYTES = 320;

    // "Final Project Done", in order. Space is all zeros.
    logic [31:0] top_glyph [N_CHARS] = '{
        32'h3E3E063E, // F
        32'h60002000, // i
        32'h4C340000, // n
        32'h24180000, // a
        32'h10101030, // l
        32'h00000000, //
        32'h1E26261E, // P
        32'h4C340000, // r
        32'h24180000, // o
        32'h20002000, // j
        32'h24380000, // e
        32'h04380000, // c
        32'h08081C08, // t
        32'h00000000, //
        32'h2626261E, // D
        32'h24180000, // o
        32'h4C340000, // n
        32'h24380000  // e
    };
    logic [31:0] btm_glyph [N_CHARS] = '{
        32'h00000606, // F
        32'h00003020, // i
        32'h00004444, // n
        32'h00005824, // a
        32'h00003810, // l
        32'h00000000, //
        32'h00000606, // P
        32'h00000404, // r
        32'h00001824, // o
        32'h30282020, // j
        32'h0000781c, // e
        32'h00003804, // c
        32'h00001028, // t
        32'h00000000, //
        32'h00001E26, // D
        32'h00001824, // o
        32'h00004444, // n
        32'h0000781c  // e
    };

    int top_base;
    int mismatches;
    logic in_banner;

    //===================================================================
    // 1. tile 1,1 did the printing, and the other eight stayed off the
    //    screen. A core that also printed would have collided.
    //===================================================================
    check_word("tile0_printed_the_banner", dmem_word(0, 16'hF000), 32'h0000F1A1);
    for (int p = 1; p < N_TILES; p++) begin
        check_word($sformatf("tile%0d_left_the_screen_alone", p),
                   dmem_word(p, 16'hF000), 32'h0000D1D0);
    end

    //===================================================================
    // 2. each character cell holds that letter's glyph, top half then
    //    bottom half.
    //===================================================================
    top_base = TEXT_ROW * LINE_BYTES + TEXT_COL * 4;
    for (int c = 0; c < N_CHARS; c++) begin
        check_word($sformatf("banner_char%0d_top", c),
                   vga_word(top_base + c * 4), top_glyph[c]);
        check_word($sformatf("banner_char%0d_bottom", c),
                   vga_word(top_base + LINE_BYTES + c * 4), btm_glyph[c]);
    end

    //===================================================================
    // 3. nothing else on the screen was touched. The banner is two bands
    //    of 18*4 bytes, and every byte outside them must still be zero.
    //===================================================================
    mismatches = 0;
    for (int a = 0; a < SIZE_VGA_MEM; a++) begin
        in_banner = ((a >= top_base) && (a < top_base + N_CHARS * 4)) ||
                    ((a >= top_base + LINE_BYTES) &&
                     (a < top_base + LINE_BYTES + N_CHARS * 4));
        if (!in_banner && (vga_byte(a) !== 8'h00)) begin
            if (mismatches < 8) begin
                $display("[INFO] vga byte %0d lit outside the banner: 0x%02h",
                         a, vga_byte(a));
            end
            mismatches++;
        end
    end
    check_word("rest_of_screen_is_blank", mismatches, 32'd0);

    print_vga_ref_screen(test);
end
