//=========================================================
// testing INT8 arithmetics
// handle multiplication between numbers wider that 8 bits
// Description: step1: (INT8*INT8)  = INT16
//              step2: (INT16*INT8) = INT24
//=========================================================

//./build.py -dut mini_core_accel -test accel_farm_int8_arith -app -hw -sim 

#include "mini_core_accel_defines.h"
#include "mafia_accel.h"

int main() {

    // weights both positive
    int8_t weights[2] = {0x04, 0x05};

    int8_t input = 0x07;
    // operation: ((weights[0]*input) * weights[1]) 
    
    int data_ready = 0;
    int16_t result;
    int8_t  result_lsb8, result_msb8;
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_0, weights[0]);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_0, input);

    while(!data_ready) {
            READ_REG(data_ready, CR_MUL2CORE_INT8_DONE_0);
    }

    // we got the result : 4x7 = 28
    READ_REG(result, CR_MUL2CORE_INT8_0);

    result_lsb8 = result & 0x00ff;
    result_msb8 = (result & 0xff00) >> 8; 

    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_0, weights[1]);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_0, result_lsb8);

    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_1, weights[1]);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_1, result_msb8);

    data_ready = 0;

    //mul#0 ready before mul#1
     while(!data_ready) {
            READ_REG(data_ready, CR_MUL2CORE_INT8_DONE_1);
    }

    int result_lsb, result_msb;

    READ_REG(result_lsb, CR_MUL2CORE_INT8_0);
    READ_REG(result_msb, CR_MUL2CORE_INT8_1);

    // we got the result = 28*5 = 140. 0x8c
    result = result_lsb + (result_msb << 8);

    // used for debug purposes
    WRITE_REG(CR_DEBUG_0, result);

    /////////////////////////////////////////
    // one weight is negative
    int8_t weights2[2] = {-0x14, 0x05};

    int8_t input2 = 0x07;
    // operation: ((weights[0]*input) * weights[1]) 
    
    int data_ready2 = 0;
    int16_t result2;
    int8_t  result2_lsb8, result2_msb8;
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_0, weights2[0]);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_0, input2);

    while(!data_ready2) {
            READ_REG(data_ready2, CR_MUL2CORE_INT8_DONE_0);
    }

    // we got the result : 7x(-20) = -140. 0xff74
    READ_REG(result2, CR_MUL2CORE_INT8_0);

    result2_lsb8 = result2 & 0x00ff;
    result2_msb8 = (result2 & 0xff00) >> 8;  

    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_0, weights2[1]);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_0, result2_lsb8);

    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_1, weights2[1]);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_1, result2_msb8);

    data_ready2 = 0;

    //mul#0 ready before mul#1
     while(!data_ready2) {
            READ_REG(data_ready2, CR_MUL2CORE_INT8_DONE_1);
    }

    int result2_lsb, result2_msb;

    READ_REG(result2_lsb, CR_MUL2CORE_INT8_0);
    READ_REG(result2_msb, CR_MUL2CORE_INT8_1);

    // we got the result = -140*5 = -700. 0xfd4c
    result2 = result2_lsb + (result2_msb << 8);

    // used for debug purposes
    WRITE_REG(CR_DEBUG_0, result2);
    
    /////////////////////////////////////////
    // the 8 lsb bits are negative
    int8_t weights3[2] = {0x60, 0x05}; //0x60 = d96

    int8_t input3 = 0x4;
    // operation: ((weights[0]*input) * weights[1]) 
    
    int data_ready3 = 0;
    int16_t result3;
    
    int8_t  result3_lsb8, result3_msb8;
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_0, weights3[0]);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_0, input3);

    while(!data_ready3) {
            READ_REG(data_ready3, CR_MUL2CORE_INT8_DONE_0);
    }

    // we got the result : 4x96 = 384. 0x180
    READ_REG(result3, CR_MUL2CORE_INT8_0);

    result3_lsb8 = result3 & 0x00ff;
    result3_msb8 = (result3 & 0xff00) >> 8; ; 

    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_0, weights3[1]);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_0, result3_lsb8);

    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_1, weights3[1]);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_1, result3_msb8);

    data_ready3 = 0;

    //mul#0 ready before mul#1
     while(!data_ready3) {
            READ_REG(data_ready3, CR_MUL2CORE_INT8_DONE_1);
    }

    int result3_lsb, result3_msb;

    READ_REG(result3_lsb, CR_MUL2CORE_INT8_0);
    READ_REG(result3_msb, CR_MUL2CORE_INT8_1);

    // we got the result = 384*5 = 1920. 0x780
    result3 = result3_lsb + (result3_msb << 8);

    // used for debug purposes
    WRITE_REG(CR_DEBUG_0, result3);
    
    /////////////////////////////////////////
    return 0;
}

