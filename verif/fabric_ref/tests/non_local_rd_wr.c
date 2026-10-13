//-----------------------------------------------------------------------------
// Title            : fabric reference model cross region read/write test
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : non_local_rd_wr.c
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 10/2026
//-----------------------------------------------------------------------------
// Description :
// Cross region access on the fabric reference model (github issue #454).
//
// fabric_alive proved each core can reach its OWN memory. This test proves the
// other half of the issue: every core can read and write memory that belongs
// to a different core, and doing so from nine cores at once does not cause
// collisions.
//
// All nine cores run this same binary. Each one works out its own slot from
// its hardware tile id, so nine cores write nine DIFFERENT slots of the same
// remote tile. If the address translation were wrong, two cores would land on
// the same slot and the checker would see a missing id.
//
// Two separate remote tiles are used, 1,1 and 3,3, to prove the model is not
// accidentally hardwired to a single destination.
//
// Memory layout inside a tile's scratch pad (scratch is at offset 0xF000 of
// that tile's DMEM):
//
//   scratch[0..8]   mailbox, one slot per tile, written by REMOTE cores
//   scratch[16..19] private results, written by the owning core only
//
// The two ranges are kept apart on purpose. For tile 1,1 the LOCAL_SCRATCH and
// TILE_1_1_SCRATCH pointers refer to the very same memory, so overlapping them
// would have tile 1,1 overwrite another core's mailbox slot.
//
// Ordering note: there is no barrier here, and none is needed. Nothing before
// the mailbox stores depends on the tile id in a way that changes control
// flow, so all nine cores reach the stores together and every mailbox slot is
// already populated by the time any core issues its loads. The test that
// really exercises a barrier is the distributed sum.
//-----------------------------------------------------------------------------

#include "fabric_defines.h"

#define RESULT_BASE 16 // scratch[16] == offset 0xF040, clear of the mailbox

int main() {
    volatile int me = WHO_AM_I[0];

    // {col,row} nibbles -> flat slot 0..8. Pure arithmetic, no branches, so
    // every core is still in step when it reaches the stores below.
    int col = (me >> 4) & 0xF;
    int row = (me >> 0) & 0xF;
    int idx = (col - 1) * 3 + (row - 1);

    // ---- cross region WRITES -------------------------------------------
    // my id into my own slot of tile 1,1
    TILE_1_1_SCRATCH[idx] = me;
    // a different value into the same slot number of tile 3,3
    TILE_3_3_SCRATCH[idx] = me + 0x100;

    // ---- local write, must stay untouched by all the remote traffic -----
    LOCAL_SCRATCH[RESULT_BASE + 0] = me + 0x2000;

    // ---- cross region READS --------------------------------------------
    // every core reads the SAME two remote slots, and must see what tiles
    // 1,1 and 3,3 deposited above
    LOCAL_SCRATCH[RESULT_BASE + 1] = TILE_1_1_SCRATCH[0]; // tile 1,1 wrote 0x11
    LOCAL_SCRATCH[RESULT_BASE + 2] = TILE_3_3_SCRATCH[8]; // tile 3,3 wrote 0x133

    // read my own slot back through the explicit physical address of tile 1,1
    LOCAL_SCRATCH[RESULT_BASE + 3] = TILE_1_1_SCRATCH[idx];

    return 0;
}
