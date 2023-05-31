//------------------------------------------------------------
// Title : alive vga test
// Project : big_core
//------------------------------------------------------------
// File : alive_vga.c
// Author : Daniel Kaufman
// Adviser : Amichai Ben-David
// Created : 03/2023
//------------------------------------------------------------
// Description :
// This program is a basic sanity test for the vga operators.
//------------------------------------------------------------
#include "big_core_defines.h"
#include "../../../app/defines/graphic_vga.h"

void wait(int cycles) {
    for (int i = 0; i < cycles; i++) {
        asm("nop");
    }
}

int main()  {  
    rvc_printf("ABCDEFGHIJKLMNOPQRSTUVWXYZ\n");
    int test = 123456789;
    rvc_print_int(test);
    int row = 20;
    int col = 0;
    int width = 10;
    int height = 20;
    char direction = 'R';
    draw_rectangle(row, col, width, height, 1);
    while(1) {
        wait(1000000);
        move_rectangle(row, col, width, height, direction);
        col++;
    }
    return 0;
    
}  // main()
