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
    int count = 0;
    while (1) {
        wait(100);
        fpga_7seg_print(count++);
    }
    return 0;
}  // main()

