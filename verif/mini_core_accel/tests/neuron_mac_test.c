//===========================================================
// testing neuron mac operation 
// adding results from mul0+mul1+mul5 activation -> saturation
//===========================================================

//./build.py -dut mini_core_accel -test neuron_mac_test -app -hw -sim -clean

#include "mini_core_accel_defines.h"
#include "mafia_accel.h"


int main() {
 
    //Writing to multiplier #0, #1
    int8_t multiplicand0 = 3; 
    int8_t multiplier0   = 4; 
    
    // writing data to multiplier0 and it immediately starts to work
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_0, multiplicand0);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_0, multiplier0);

    int8_t multiplicand1 = 5; 
    int8_t multiplier1   = 6;

    // writing data to multiplier1 and it immediately starts to work
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_1, multiplicand1);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_1, multiplier1);

    int8_t multiplicand5 = 2; 
    int8_t multiplier5   = 3;

    // writing data to multiplier5 and it immediately starts to work
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_5, multiplicand5);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_5, multiplier5);

    int polling5 = 0;
    int16_t mul_int8_result0, mul_int8_result1, mul_int8_result5;
  
     while(!polling5) {
        READ_REG(polling5, CR_MUL2CORE_INT8_DONE_5);
    }

    // Read the result of mul0 after polling is 1 (ready)
    READ_REG(mul_int8_result0, CR_MUL2CORE_INT8_0);  

    // Read the result of mul1 after polling is 1 (ready)
    READ_REG(mul_int8_result1, CR_MUL2CORE_INT8_1);

    // Read the result of mul5 after polling is 1 (ready)
    READ_REG(mul_int8_result5, CR_MUL2CORE_INT8_5);

    // writing bias to neuron_mac0
    int8_t neuron_mac_bias0 = 5;
    int8_t neuron_mac_result0;
    WRITE_REG(NEURON_MAC_BIAS0, neuron_mac_bias0);
    READ_REG(neuron_mac_result0, NEURON_MAC_RESULT0);

    // used for debug purposes
    WRITE_REG(CR_DEBUG_0, mul_int8_result0);
    WRITE_REG(CR_DEBUG_1, mul_int8_result1);
    WRITE_REG(CR_DEBUG_2, mul_int8_result5);
    WRITE_REG(CR_DEBUG_3, neuron_mac_result0);  // expected 0x35

    return 0;
}