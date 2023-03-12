#include "../../../app/defines/big_core_defines.h"
int main()  {  
    int x,y,z;  
    x = 17;  
    y = 11;  
    z = x*y;  
    MEM_SCRATCH[0]=z;
    WRITE_REG(CR_LED, 0xf);
    READ_REG(z,CR_LED);
    MEM_SCRATCH[1]=z;
}  // main()
