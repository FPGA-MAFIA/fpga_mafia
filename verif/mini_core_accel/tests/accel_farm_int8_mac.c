//=========================================================
// testing mac operation
// using int8 multipliers
//=========================================================

//./build.py -dut mini_core_accel -test accel_farm_int8_mac -app -hw -sim 

#include "mini_core_accel_defines.h"


int main() {

    int data[16] = {3, 4, 3, 5, 3, 6, 3, 7, 3, 8, 3, 9, 4, 0, 5, 4}; // 3x4 + 3x5 + 3x6 + ... + 4x0 + 5x4
    int data_size = sizeof(data)/sizeof(int);

    int mul_result;
    int result = 0;
    
    int data_ready = 0;

    for(int i=0; i<data_size/2; i++){

        WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_0, data[2*i]);
        WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_0, data[2*i+1]);
        while(!data_ready) {
            READ_REG(data_ready, CR_MUL2CORE_INT8_DONE_0);
        }
        data_ready = 0;
        READ_REG(mul_result, CR_MUL2CORE_INT8_0);
        result += mul_result; 

        // used for debug purposes
        WRITE_REG(CR_DEBUG_0, result);

    }


    return 0;
}