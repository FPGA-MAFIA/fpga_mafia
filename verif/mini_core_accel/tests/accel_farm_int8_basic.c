//=========================================================
// testing access for read and write from acceleration farm
// using int8 multipliers
//=========================================================

//./build.py -dut mini_core_accel -test accel_farm_int8_basic -app -hw -sim

#include "mini_core_accel_defines.h"
#define WRITE_REG(REG,VAL) (*REG) = VAL
#define READ_REG(VAL,REG)  VAL    = (*REG)

int main() {

    //Writing to multiplier #0

    int data0 = 0x00000304; // {multiplicand = 3, multiplier = 4}
    int continue_when_finish = 0x00000304;
    WRITE_REG(CR_CORE2MUL_INT8_0, data0);

    int polling = 0;
    int mul_result0;

    while(!polling) {
        READ_REG(mul_result0, CR_MUL2CORE_INT8_0);
        polling = (mul_result0 & 0x00010000) >> 16;  // extend ready bit
    }

    return 0;
}