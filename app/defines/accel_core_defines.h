#ifndef ACCEL_CORE_DEFINES_H
#define ACCEL_CORE_DEFINES_H

// macros
#define WRITE_REG(REG,VAL) (*REG) = VAL
#define READ_REG(VAL,REG)  VAL    = (*REG)
#define NOP() __asm__("nop")

typedef unsigned int uint32_t;
#define CR_MUL_IN_META 0x00FE0210
#define CR_MUL_IN_DATA 0x00FE0211
#define CR_MUL_W1_META 0x00FE0250
#define CR_MUL_W1_DATA 0x00FE0251
#define CR_MUL_W2_META 0x00FE0290
#define CR_MUL_W2_DATA 0x00FE0291
#define CR_MUL_W3_META 0x00FE02D0
#define CR_MUL_W3_DATA 0x00FE02D1
#define CR_MUL_OUT_META 0x00FE0310

#endif