//-----------------------------------------------------------------------------
// Title            : fabric reference model VGA banner test
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : vga_banner.c
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 10/2026
//-----------------------------------------------------------------------------
// Description :
// Prints a readable banner on the shared VGA frame buffer, using the same
// letter glyphs the rest of the project uses (draw_char / rvc_printf in
// graphic_vga.h). The snapshot lands in ref_screen.log.
//
// The glyphs are 8x8 pixels, one character per text column. "Final Project
// Done" is 18 characters, so it occupies columns 31..48 of text row 2, which
// puts it near the middle of the 80 column screen and one text row down from
// the top.
//
// Only tile 1,1 draws. The font writes a whole character cell with one store,
// so if all nine cores printed the same string they would write the same
// bytes in the same cycle and the memory model would flag a collision. The
// other eight cores record that they stayed off the screen and finish.
//-----------------------------------------------------------------------------

#include "big_core_defines.h"
#include "graphic_vga.h"
#include "fabric_defines.h"

#define PRINTED  0x00F1A1
#define STOOD_BY 0x00D1D0

int main() {
    volatile int me = WHO_AM_I[0];

    int col = (me >> 4) & 0xF;
    int row = (me >> 0) & 0xF;
    int idx = (col - 1) * 3 + (row - 1);

    if (idx == 0) {
        // text row 2, column 31: one row below the top, centered
        set_cursor(2, 31);
        rvc_printf("Final Project Done");
        LOCAL_SCRATCH[0] = PRINTED;
    }
    else {
        LOCAL_SCRATCH[0] = STOOD_BY;
    }

    return 0;
}
