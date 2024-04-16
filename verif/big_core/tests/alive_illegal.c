#include "interrupt_handler.h"
int main() {

    int x = 1;
    int y = 2;
    
    // This instruction is trying to generate slli instruction with illegal FUNCT7.
    asm(".word 0xfff79793" : /* outputs / : / inputs / : / clobbers */);
    int z = x + y;

    // Reading mepc and mtval 
    int csr_mepc, csr_mtval;
    asm volatile ("csrr %0, 0x341" : "=r" (csr_mepc));
    asm volatile ("csrr %0, 0x343" : "=r" (csr_mtval)); 

    return 0;
}