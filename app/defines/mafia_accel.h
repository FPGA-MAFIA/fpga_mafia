#ifndef MAFIA_ACCEL_H
#define MAFIA_ACCEL_H

// macros
#define WRITE_REG(REG,VAL) (*REG) = VAL
#define READ_REG(VAL,REG)  VAL    = (*REG)

#define CORE2MUL_INT8_MULTIPLICAND(index)  (volatile int *)(CR_MEM_BASE + 0xF000 + 2*index) // FIXME - possible to merge the macros. Now its easier to debug
#define CORE2MUL_INT8_MULTIPLIER(index)    (volatile int *)(CR_MEM_BASE + 0xF000 + 2*index+1)
#define MUL2CORE_INT8_RESULT(index)        (volatile int *)(CR_MEM_BASE + 0xF050 + 2*index)
#define MUL2CORE_INT8_DONE(index)          (volatile int *)(CR_MEM_BASE + 0xF050 + 2*index+1)

#define PACK_TO_32BIT(a, b, c, d) ((d & 0xFF) | ((c & 0xFF) << 8) | ((b & 0xFF) << 16) | ((a & 0xFF) << 24))

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
int32_t mac8_8(int8_t data, int8_t weight, int8_t bias, unsigned int index) {

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

//set data in systolic array data into cr's.
// TODO - possible to start running systolic array after partial data load. We dont have perform full write of weights and
// activation matrixes
void set_systolic_array(int8_t activations[4][4], int8_t weights[4][4]){

    // writing activates to systolic array + perform reordering
    uint32_t packed_value_1 = PACK_TO_32BIT(activations[0][1], activations[1][3], activations[0][2], activations[0][3]);
    uint32_t packed_value_2 = PACK_TO_32BIT(activations[1][1], activations[0][0], activations[2][3], activations[1][2]);
    uint32_t packed_value_3 = PACK_TO_32BIT(activations[2][1], activations[1][0], activations[3][3], activations[2][2]);
    uint32_t packed_value_4 = PACK_TO_32BIT(activations[3][0], activations[3][1], activations[2][0], activations[3][2]);
    WRITE_REG(SYSTOLIC_ARRAY_ACTIVE31_0, packed_value_1);
    WRITE_REG(SYSTOLIC_ARRAY_ACTIVE63_32, packed_value_2);
    WRITE_REG(SYSTOLIC_ARRAY_ACTIVE95_64, packed_value_3);
    WRITE_REG(SYSTOLIC_ARRAY_ACTIVE127_96, packed_value_4);

    // writing weights to systolic array
    packed_value_1 = PACK_TO_32BIT(weights[1][0], weights[3][1], weights[2][0], weights[3][0]);
    packed_value_2 = PACK_TO_32BIT(weights[1][1], weights[0][0], weights[3][2], weights[2][1]);
    packed_value_3 = PACK_TO_32BIT(weights[1][2], weights[0][1], weights[3][3], weights[2][2]);
    packed_value_4 = PACK_TO_32BIT(weights[0 ][3], weights[1][3], weights[0][2], weights[2][3]);
    WRITE_REG(SYSTOLIC_ARRAY_WEIGHTS31_0, packed_value_1);
    WRITE_REG(SYSTOLIC_ARRAY_WEIGHTS63_32, packed_value_2);
    WRITE_REG(SYSTOLIC_ARRAY_WEIGHTS95_64, packed_value_3);
    WRITE_REG(SYSTOLIC_ARRAY_WEIGHTS127_96, packed_value_4);

}

int16_t (*systolic_array_result())[4] {
    static int16_t results[4][4];

    READ_REG(results[0][0], PE00_RESULT);
    READ_REG(results[0][1], PE01_RESULT);
    READ_REG(results[0][2], PE02_RESULT);
    READ_REG(results[0][3], PE03_RESULT);
    READ_REG(results[1][0], PE10_RESULT);
    READ_REG(results[1][1], PE11_RESULT);
    READ_REG(results[1][2], PE12_RESULT);
    READ_REG(results[1][3], PE13_RESULT);
    READ_REG(results[2][0], PE20_RESULT);
    READ_REG(results[2][1], PE21_RESULT);
    READ_REG(results[2][2], PE22_RESULT);
    READ_REG(results[2][3], PE23_RESULT);
    READ_REG(results[3][0], PE30_RESULT);
    READ_REG(results[3][1], PE31_RESULT);
    READ_REG(results[3][2], PE32_RESULT);
    READ_REG(results[3][3], PE33_RESULT);
    
    
    return results;
}
#endif 