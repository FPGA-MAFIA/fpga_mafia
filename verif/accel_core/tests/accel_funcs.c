// Define uint32_t as unsigned int
#include "accel_core_defines.h"
uint32_t *address = (uint32_t *)0x00FE0200;

int xor_accel(int x, int y) {
    int result;
    WRITE_REG(address,x);
    WRITE_REG((address+1), y);
    READ_REG(result,address+2);
    READ_REG(result,address+2);
    return result;
}
