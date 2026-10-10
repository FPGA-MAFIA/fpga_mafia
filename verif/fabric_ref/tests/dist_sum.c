//-----------------------------------------------------------------------------
// Title            : fabric reference model distributed sum test
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : dist_sum.c
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 10/2026
//-----------------------------------------------------------------------------
// Description :
// Distributed calculation with a real barrier, on the fabric reference model
// (github issue #454).
//
// The earlier tests only ever had the cores run in step, because nothing in
// them branched on the tile id. This one deliberately breaks that: tile 1,1
// takes a different path from the other eight and has to WAIT for them. It is
// the first test where the cores genuinely cooperate rather than just coexist.
//
// The job: sum the integers 1..90, split nine ways.
//   tile with flat index i sums the ten integers (10*i + 1) .. (10*i + 10)
//   so its partial is 100*i + 55
//   and the nine partials add up to 4095 (0xFFF)
//
// The protocol:
//   1. every core computes its own partial and keeps a local copy
//   2. every core burns a delay proportional to its tile index, so the nine
//      cores arrive at the mailbox at nine different times
//   3. every core publishes the partial into tile 1,1's mailbox, then raises
//      its done flag. The flag is written AFTER the data, so a flag that is
//      set always means the partial next to it is already valid.
//   4. tile 1,1 spins on the nine flags, then adds the nine partials and
//      writes the total. The other eight cores just finish.
//
// Step 2 is what makes this a real test. Without it the nine cores stay in
// lockstep, every partial is already in place by the time the aggregator
// looks, and the test passes whether the barrier is there or not. With it,
// deleting the barrier makes the test fail, which is what we want.
//
// Scratch pad layout, all offsets relative to a tile's scratch at 0xF000:
//   scratch[0..8]   partial results, one slot per tile
//   scratch[16..24] done flags, one slot per tile
//   scratch[32]     the final total, written only by tile 1,1
//   scratch[40]     each core's private copy of its own partial
//   scratch[48]     role marker, proving the cores really did diverge
//
// Everything crossing a core boundary goes through the volatile pointers in
// fabric_defines.h, so the spin loop really re-reads memory each time instead
// of being hoisted into a register, which would hang forever.
//-----------------------------------------------------------------------------

#include "fabric_defines.h"

#define NUM_TILES    9

#define PARTIAL_BASE 0
#define FLAG_BASE    16
#define TOTAL_SLOT   32
#define MY_SUM_SLOT  40
#define ROLE_SLOT    48

#define ROLE_AGGREGATOR 0x0A66
#define ROLE_WORKER     0x0B0B

int main() {
    volatile int me = WHO_AM_I[0];

    int col = (me >> 4) & 0xF;
    int row = (me >> 0) & 0xF;
    int idx = (col - 1) * 3 + (row - 1);

    // ---- 1. do my own slice of the work ----------------------------
    int base = idx * 10;
    int sum  = 0;
    for (int k = 1; k <= 10; k++) {
        sum += base + k;
    }
    LOCAL_SCRATCH[MY_SUM_SLOT] = sum;

    // ---- 2. stagger the cores on purpose ---------------------------
    // Nothing above this point branches on the tile id, so without this
    // delay all nine cores would reach the publish below on the very same
    // cycle, the barrier would never actually block, and the test would
    // pass for the wrong reason. The delay grows with the tile index and
    // the aggregator has none, so tile 1,1 is guaranteed to arrive at the
    // barrier well before the last worker reports in.
    volatile int spin = 0;
    for (int d = 0; d < idx * 64; d++) {
        spin = spin + 1;
    }

    // ---- 3. publish the partial, THEN announce it is ready ---------
    TILE_1_1_SCRATCH[PARTIAL_BASE + idx] = sum;
    TILE_1_1_SCRATCH[FLAG_BASE    + idx] = 1;

    // ---- 4. tile 1,1 aggregates, everyone else is done -------------
    if (idx == 0) {
        LOCAL_SCRATCH[ROLE_SLOT] = ROLE_AGGREGATOR;

        // the barrier - wait for all nine workers to report in
        for (int t = 0; t < NUM_TILES; t++) {
            while (TILE_1_1_SCRATCH[FLAG_BASE + t] == 0) {
                // spin
            }
        }

        int total = 0;
        for (int t = 0; t < NUM_TILES; t++) {
            total += TILE_1_1_SCRATCH[PARTIAL_BASE + t];
        }
        TILE_1_1_SCRATCH[TOTAL_SLOT] = total;
    }
    else {
        LOCAL_SCRATCH[ROLE_SLOT] = ROLE_WORKER;
    }

    return 0;
}
