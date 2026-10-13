//-----------------------------------------------------------------------------
// Title            : fabric reference model alive test
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : fabric_alive.c
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// The first piece of real software to run on the fabric reference model
// (github issue #454).
//
// All nine cores execute this exact same binary at the same time. Nothing in
// it is tile specific, and yet every core must end up with a different answer,
// because:
//   - WHO_AM_I is answered by the core itself with its own hardware tile id
//   - LOCAL_SCRATCH has a tile field of 0x00, which the address translation
//     resolves to the memory of whichever core is asking
//
// So if this test passes, one binary really is running on nine cores without
// them treading on each other.
//
// Everything that crosses the core boundary is volatile, otherwise the
// compiler is free to keep it in a register and the memory would never be
// touched at all.
//-----------------------------------------------------------------------------

#include "fabric_defines.h"

int main() {
    volatile int me = WHO_AM_I[0];

    // proof that the core knows who it is
    LOCAL_SCRATCH[0] = me;

    // proof that it can read back what it wrote to its own memory
    LOCAL_SCRATCH[1] = LOCAL_SCRATCH[0] + 1;

    // a constant every tile writes, so a tile that never ran is obvious
    LOCAL_SCRATCH[2] = 0x0A11CE00;

    return 0;
}
