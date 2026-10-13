//-----------------------------------------------------------------------------
// Title            : fabric reference model shared VGA test
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : vga_draw.c
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 10/2026
//-----------------------------------------------------------------------------
// Description :
// Nine cores drawing into the one shared VGA frame buffer at the same time
// (github issue #454).
//
// The scratch pads used by the earlier tests are per tile: nine separate
// slices of memory that merely happen to be reachable from anywhere. The VGA
// region is the opposite, and is the more interesting case. There is exactly
// one of it in the whole fabric, every core reaches it through the very same
// address, and the address carries no tile id at all. Nine cores writing one
// physical memory concurrently is the case where a bad model would alias or
// drop writes.
//
// Each core draws a filled box into its own cell of a 3x3 grid laid over the
// 640x480 screen, positioned to match where that core sits in the mesh. So
// the picture that comes out is a map of the fabric itself: the box drawn by
// tile 2,3 appears in the middle column, bottom row.
//
// The boxes are deliberately laid out so that no two cores ever touch the
// same BYTE. That matters because a byte holds eight horizontally adjacent
// pixels, so two cores sharing a byte would be a genuine read modify write
// race. Here the cells are split on byte column boundaries, which keeps the
// writes to whole bytes: no read modify write, and the memory model's
// collision assertion stands as proof that the nine cores never overlapped.
//
// Each core fills with a value unique to it, 0x11 * (index + 1), so the
// checker can tell not just that a byte was written but WHICH core wrote it.
// A core spilling outside its own cell would be caught immediately.
//-----------------------------------------------------------------------------

#include "fabric_defines.h"

// Screen geometry, matching graphic_vga.h.
#define BYTE_COLS_PER_SCREEN 80  // 640 pixels / 8 pixels per byte
#define ROWS_PER_BLOCK       4
#define BYTES_PER_BLOCK      320 // 4 rows * 80 byte columns

// One cell of the 3x3 grid. 26 byte columns and 160 rows out of 80 and 480.
#define CELL_BYTE_COLS 26
#define CELL_ROWS      160

// The box drawn inside a cell, and where it starts within that cell.
#define BOX_BYTE_COLS 8
#define BOX_ROWS      24
#define BOX_MARGIN_BYTE_COLS 2
#define BOX_MARGIN_ROWS      20

int main() {
    volatile int me = WHO_AM_I[0];

    int col = (me >> 4) & 0xF;
    int row = (me >> 0) & 0xF;
    int idx = (col - 1) * 3 + (row - 1);

    // where my box starts on the screen. Column of the mesh picks the
    // horizontal band, row of the mesh picks the vertical one.
    int bx0 = (col - 1) * CELL_BYTE_COLS + BOX_MARGIN_BYTE_COLS;
    int y0  = (row - 1) * CELL_ROWS      + BOX_MARGIN_ROWS;

    // my signature, so the checker knows who wrote each byte
    unsigned char pattern = (unsigned char)(0x11 * (idx + 1));

    for (int r = 0; r < BOX_ROWS; r++) {
        int y = y0 + r;
        // byte_addr = (y / 4) * 320 + (x / 8) * 4 + (y % 4)
        int row_base = (y / ROWS_PER_BLOCK) * BYTES_PER_BLOCK
                     + (y % ROWS_PER_BLOCK);
        for (int b = 0; b < BOX_BYTE_COLS; b++) {
            FABRIC_VGA_MEM[row_base + (bx0 + b) * ROWS_PER_BLOCK] = pattern;
        }
    }

    // breadcrumb so the checker can confirm every core really ran this
    LOCAL_SCRATCH[0] = 0x7D02E;

    return 0;
}
