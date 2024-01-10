#include "interrupt_handler.h"
int main() {

    int x = 1;
    int y = 2;
    //This instruction is trying to shift to an illegal amount of bits.
    asm(".word 0xfff79793" : /* outputs / : / inputs / : / clobbers */);
    int z = x + y;

    return 0;
}