//=========================================================
// testing access for read and write from acceleration farm
// using int8 multipliers
//=========================================================

//./build.py -dut mini_core_accel -test accel_farm_int8_basic -app -hw -sim 

#include "mini_core_accel_defines.h"
#define WRITE_REG(REG,VAL) (*REG) = VAL
#define READ_REG(VAL,REG)  VAL    = (*REG)

int main() {

    //Writing to multiplier #0, #1

    int data0 = 0x00000304; // {multiplicand = 3, multiplier = 4}
    int data1 = 0x0000fd04; // {multiplicand = -3, multiplier = 4}
    WRITE_REG(CR_CORE2MUL_INT8_0, data0);
    WRITE_REG(CR_CORE2MUL_INT8_1, data1);

    int polling0 = 0;
    int polling1 = 0;
    int mul_int8_result0, mul_int8_result1;

    while(!polling0) {
        READ_REG(mul_int8_result0, CR_MUL2CORE_INT8_0);
        polling0 = (mul_int8_result0 & 0x00010000) >> 16;  // extend ready bit
    }

     while(!polling1) {
        READ_REG(mul_int8_result1, CR_MUL2CORE_INT8_1);
        polling1 = (mul_int8_result1 & 0x00010000) >> 16;  // extend ready bit
    }

    return 0;
}