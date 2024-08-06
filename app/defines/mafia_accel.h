#ifndef MAFIA_ACCEL_H
#define MAFIA_ACCEL_H

// macros
#define WRITE_REG(REG,VAL) (*REG) = VAL
#define READ_REG(VAL,REG)  VAL    = (*REG)

#define CORE2MUL_INT8_MULTIPLICAND(index)  (volatile int *)(CR_MEM_BASE + 0xF000 + 2*index) // FIXME - possible to merge the macros. Now its easier to debug
#define CORE2MUL_INT8_MULTIPLIER(index)    (volatile int *)(CR_MEM_BASE + 0xF000 + 2*index+1)
#define MUL2CORE_INT8_RESULT(index)        (volatile int *)(CR_MEM_BASE + 0xF010 + 2*index)
#define MUL2CORE_INT8_DONE(index)          (volatile int *)(CR_MEM_BASE + 0xF010 + 2*index+1)

// error macros
#define MUL_INDEX_OUT_OF_RANGE  -1

// Define 8-bit, 16-bit and 32-bit types
typedef unsigned char uint8_t;     // 8-bit unsigned
typedef signed char int8_t;        // 8-bit signed
typedef unsigned short uint16_t;   // 16-bit unsigned
typedef signed short int16_t;      // 16-bit signed
typedef unsigned int uint32_t;   // 32-bit unsigned
typedef signed int int32_t;      // 32-bit signed


/*****************************************************
*                function definitions
*****************************************************/
// data   - 8 bit input
// weight - 8 bit weight
// bias   - 8 bit bias
// index  - multiplier index
// returns 32 bit signed result. We need only 17 bits max. data*weight + bias 
int32_t perceptron8_8(int8_t data, int8_t weight, int8_t bias, unsigned int index) {

    WRITE_REG(CORE2MUL_INT8_MULTIPLICAND(index), weight);
    WRITE_REG(CORE2MUL_INT8_MULTIPLIER(index), data);

    int data_ready = 0;

    while(!data_ready) {
            READ_REG(data_ready, MUL2CORE_INT8_DONE(index));
    }

    int32_t result;
    READ_REG(result, MUL2CORE_INT8_RESULT(index));

    return result + (int32_t)bias; 
}

// multiplier   - 16 bit signed input number
// multiplicand - 8 bit signed input number
// mul_index0   - first multiplier index
// mul_index1   - second multiplier index
// return 32 bit signed extended number. Note than only 24 max bits is needed.

int32_t mul_16by8(int16_t multiplier, int8_t multiplicand, unsigned int mul_index0, unsigned int mul_index1) {
    
    int8_t pre_result_lsb = multiplier & 0x00ff; // extract low 8 bits from the multiplier
    int8_t pre_result_msb = (multiplier & 0xff00) >> 8; // extract high 8 bits from the multiplier

    int lsb_was_neg;   // we have to ensure that lower 8 bits wont be considered as negative

    if(pre_result_lsb < 0){
        pre_result_lsb = pre_result_lsb & 0x7f;
        lsb_was_neg = 1;
    } else {
        lsb_was_neg = 0;
    }

    // request from multipliers
    WRITE_REG(CORE2MUL_INT8_MULTIPLICAND(mul_index0), multiplicand);
    WRITE_REG(CORE2MUL_INT8_MULTIPLIER(mul_index0), pre_result_lsb);

    WRITE_REG(CORE2MUL_INT8_MULTIPLICAND(mul_index1), multiplicand);
    WRITE_REG(CORE2MUL_INT8_MULTIPLIER(mul_index1), pre_result_msb);

    int data_ready = 0;

    // second multiplier we be ready after the first. Than only needed is to polling on the second
     while(!data_ready) {
            READ_REG(data_ready, MUL2CORE_INT8_DONE(mul_index1));
    }

    int16_t result_lsb, result_msb; 

    READ_REG(result_lsb, MUL2CORE_INT8_RESULT(mul_index0));
    READ_REG(result_msb, MUL2CORE_INT8_RESULT(mul_index1));

    if(lsb_was_neg) {
        result_lsb = result_lsb + (int16_t)(multiplicand << 7);
    }

    int32_t result;

    result = result_lsb + (result_msb << 8);

    return result;

}
#endif 