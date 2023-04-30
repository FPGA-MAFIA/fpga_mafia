//------------------------------------------------------------
// Title : alive fpga
// Project : big_core
//------------------------------------------------------------
// File : alive_fpga.c
// Author : Daniel Kaufman
// Adviser : Amichai Ben-David
// Created : 03/2023
//------------------------------------------------------------
// Description :
//------------------------------------------------------------
#include "big_core_defines.h"
#include "graphic_vga.h"

void wait(int cycles) {
    for (int i = 0; i < cycles; i++) {
        asm("nop");
    }
}
int main()  {  

    for(int i = 0; i < 100; i++) {
        CR_LED[0] = 0x1;
        wait(10);
        CR_LED[0] = 0x2;
        wait(10);
        CR_LED[0] = 0x4;
        wait(10);
    }

    rvc_printf("ABCDEFGHIJKLMNOPQRSTUVWXYZ\n");
    int test = 123456789;
    rvc_print_int(test);
    return 0;
}  // main()
