#include "fabric_defines.h"
int main()  {  

TILE_3_3_SCRATCH[0] = WHO_AM_I[0];
int read_data = TILE_3_3_SCRATCH[0];

// want to tests access to the TILE 3,3 scratchpad.
// load values to the scratchpad, then read them back.

// write to scratchpad
TILE_3_3_SCRATCH[0] = 0x12345678;
TILE_3_3_SCRATCH[1] = 0x9abcdef0;
TILE_3_3_SCRATCH[2] = 0xdeadbeef;
TILE_3_3_SCRATCH[3] = 0xfeedface;

// read from scratchpad
int read_data_0 = TILE_3_3_SCRATCH[0];
int read_data_1 = TILE_3_3_SCRATCH[1];
int read_data_2 = TILE_3_3_SCRATCH[2];
int read_data_3 = TILE_3_3_SCRATCH[3];

// check that the read data matches the written data
if (read_data_0 != 0x12345678) {
    return 1;
}
if (read_data_1 != 0x9abcdef0) {
    return 2;
}
if (read_data_2 != 0xdeadbeef) {
    return 3;
}
if (read_data_3 != 0xfeedface) {
    return 4;
}




return 0;
}  // main()
