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
    volatile unsigned int button_1_value, button_0_value;
    rvc_print_int(test);
    Rectangle rect;
    rect.row = 20;
    rect.col = 0;
    rect.width = 10;
    rect.height = 20;
    char direction = 'R';
    draw_rectangle(rect, 1);
    while(1) {
        READ_REG(button_0_value, CR_Button_0);
        READ_REG(button_1_value, CR_Button_1);
        rvc_printf("\nBOTTOM 0 - ");
        rvc_print_int(button_0_value);
        rvc_printf("\nBOTTOM 1 - ");
        rvc_print_int(button_1_value);
        wait(1000000);
        move_rectangle(rect, direction);
        rect.col++;
    }
    return 0;
    
}  // main()
