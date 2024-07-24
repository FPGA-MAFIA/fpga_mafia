//=========================================================
// testing access for read and write from acceleration farm
// using int8 multipliers
//=========================================================

#include "mini_core_accel_defines.h"
#define WRITE_REG(REG,VAL) (*REG) = VAL
#define READ_REG(VAL,REG)  VAL    = (*REG)

int main() {

    //Writing to multiplier #1

    int data0 = 0x00010304; // {start = 1, multiplicand = 3, multiplier = 4}
    int continue_when_finish = 0x00000304;
    WRITE_REG(CR_CORE2MUL_0, data0);
    WRITE_REG(CR_CORE2MUL_0, continue_when_finish);



    int polling = 0;
    int mul_result0;

    while(!polling) {
        READ_REG(mul_result0, CR_MUL2CORE_0);
        polling = (mul_result0 & 0x00010000) >> 16;  // extend ready bit
    }

    return 0;
}