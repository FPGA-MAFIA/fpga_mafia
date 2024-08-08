//=========================================================
// testing access for read and write from acceleration farm
// using int8 multipliers
//=========================================================

//./build.py -dut mini_core_accel -test accel_farm_int8_basic -app -hw -sim -clean

#include "mini_core_accel_defines.h"
#include "mafia_accel.h"


int main() {

    //Writing to multiplier #0, #1

    int8_t multiplicand0 = 3; 
    int8_t multiplier0   = 4; 
    
    // writing data to multiplier0 and it immediately starts to work
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_0, multiplicand0);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_0, multiplier0);

    int8_t multiplicand1 = -3; 
    int8_t multiplier1   = 4;

    // writing data to multiplier1 and it immediately starts to work
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_1, multiplicand1);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_1, multiplier1);

    int polling0 = 0;
    int polling1 = 0;
    int16_t mul_int8_result0, mul_int8_result1;

    while(!polling0) {
        READ_REG(polling0, CR_MUL2CORE_INT8_DONE_0);
    }

    // Read the result of mul0 after polling is 1 (ready)
    READ_REG(mul_int8_result0, CR_MUL2CORE_INT8_0);  

    // used for debug purposes
    WRITE_REG(CR_DEBUG_0, mul_int8_result0);  

     while(!polling1) {
        READ_REG(polling1, CR_MUL2CORE_INT8_DONE_1);
    }

    // Read the result of mul1 after polling is 1 (ready)
    READ_REG(mul_int8_result1, CR_MUL2CORE_INT8_1);

    // used for debug purposes
    WRITE_REG(CR_DEBUG_0, mul_int8_result0);

    return 0;
}