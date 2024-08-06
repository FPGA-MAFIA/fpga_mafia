// testing int16*int8 using int8 arithmetics

//./build.py -dut mini_core_accel -test int16_mul_int8 -app -hw -sim -clean

#include "mini_core_accel_defines.h"
#include "mafia_accel.h"

int main() {

    int8_t weights[2] = {0x60, 0xfb}; 
    int8_t input = 0x4;
    
    int data_ready = 0;
    
    // multiply (weights[0]*input) * weights[1]
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_0, weights[0]);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_0, input);

    while(!data_ready) {
            READ_REG(data_ready, CR_MUL2CORE_INT8_DONE_0);
    }

    int16_t result16;
    READ_REG(result16, CR_MUL2CORE_INT8_0); 

    int32_t result32;
    result32 = mul_16by8(result16, weights[1], 0, 1);

    // used for debug purposes
    WRITE_REG(CR_DEBUG_0, result32);  //the result is 0xfffff880

    return 0;
}