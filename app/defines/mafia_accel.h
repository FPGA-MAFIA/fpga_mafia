#ifndef MAFIA_ACCEL_H
#define MAFIA_ACCEL_H

// macros
#define WRITE_REG(REG,VAL) (*REG) = VAL
#define READ_REG(VAL,REG)  VAL    = (*REG)

// Define 8-bit, 16-bit and 32-bit types
typedef unsigned char uint8_t;     // 8-bit unsigned
typedef signed char int8_t;        // 8-bit signed
typedef unsigned short uint16_t;   // 16-bit unsigned
typedef signed short int16_t;      // 16-bit signed
typedef unsigned int uint32_t;   // 32-bit unsigned
typedef signed int int32_t;      // 32-bit signed


// function definitions

// TODO - possible refactor is needed
// FIXME - working on multiplier 0 and 1 only
int32_t mul_16by8(int16_t multiplier, int8_t multiplicand) {

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
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_0, multiplicand);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_0, pre_result_lsb);

    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLICAND_1, multiplicand);
    WRITE_REG(CR_CORE2MUL_INT8_MULTIPLIER_1, pre_result_msb);

    int data_ready = 0;

     while(!data_ready) {
            READ_REG(data_ready, CR_MUL2CORE_INT8_DONE_1);
    }

    int16_t result_lsb, result_msb; 

    READ_REG(result_lsb, CR_MUL2CORE_INT8_0);
    READ_REG(result_msb, CR_MUL2CORE_INT8_1);

    if(lsb_was_neg) {
        result_lsb = result_lsb + (multiplicand << 7);
    }

    int32_t result;

    result = result_lsb + (result_msb << 8);

    return result;

}
#endif 