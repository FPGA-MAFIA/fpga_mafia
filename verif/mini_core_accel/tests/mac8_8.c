#include "mini_core_accel_defines.h"
#include "mafia_accel.h"

// ./build.py -dut mini_core_accel -test mac8_8 -app -hw -sim -clean

int main() {

    int8_t data   = 0x60;
    int8_t weight = 0xfb;
    int8_t bias   = 0x8;

    int32_t output;

    output = mac8_8(data, weight, bias, 5);

    // used for debug purposes
    WRITE_REG(CR_DEBUG_0, output);  // the result is d 0xfffffe28



    return 0;
}