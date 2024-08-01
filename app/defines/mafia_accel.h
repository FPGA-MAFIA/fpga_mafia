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
typedef unsigned int uint32_t;   // 16-bit unsigned
typedef signed int int32_t;      // 16-bit signed

#endif 