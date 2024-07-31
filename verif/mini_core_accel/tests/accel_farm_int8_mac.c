//=========================================================
// testing mac operation
// using int8 multipliers
//=========================================================

//./build.py -dut mini_core_accel -test accel_farm_int8_mac -app -hw -sim 

#include "mini_core_accel_defines.h"


int main() {

    
    int data[8] = {0x00000304, 0x00000305, 0x00000306, 0x00000307, 0x00000308, 0x00000309, 0x00000400, 0x00000504};
    int data_size = sizeof(data)/sizeof(int);

    int mul_result;
    int result = 0;
    
    int data_ready = 0;

    for(int i=0; i<data_size; i++){

        WRITE_REG(CR_CORE2MUL_INT8_0, data[i]);
        while(!data_ready) {
            READ_REG(data_ready, CR_MUL2CORE_INT8_DONE_0);
        }
        data_ready = 0;
        READ_REG(mul_result, CR_MUL2CORE_INT8_0);
        result += mul_result; 
        WRITE_REG(CR_DEBUG_0, result);

    }


    return 0;
}