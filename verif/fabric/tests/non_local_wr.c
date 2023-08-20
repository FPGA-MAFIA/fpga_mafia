#include "fabric_defines.h"
#define WHO_AM_I ((volatile int *) (0x00FFFFFF))

int main(){
// switch case according to WHO_AM_I - each case writes different data to the scratchpad of TILE_1_1

TILE_1_1_SCRATCH[0] = 0xFF;

for(int i = 0; i < 100; i++){
    //busy wait  
}
TILE_1_1_SCRATCH[0] = WHO_AM_I[0];

if(WHO_AM_I[0] != 0x11){
    while(1){};//busy wait
}

    return 0;
}