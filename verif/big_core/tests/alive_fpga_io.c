//------------------------------------------------------------
// Title : alive fpga io
// Project : big_core
//------------------------------------------------------------
// File : alive_fpga_io.c
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
    while (count <= 10000) {
        wait(1000000);
        fpga_7seg_print(count++);
    }
    return 0;
}  // main()

