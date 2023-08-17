
#include "fabric_defines.h"

int main(){
    int a = 1;
    int b = 2;
    //writing to local scratchpad
    LOCAL_SCRATCH[0] = a;
    //writing to non-local scratchpad
    TILE_2_2_SCRATCH[1] = b; // we are tile 2_2 so this is also local
    TILE_1_1_SCRATCH[0] = a+b;
    return 0;
}