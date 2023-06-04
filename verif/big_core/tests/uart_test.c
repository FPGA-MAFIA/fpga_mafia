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
#include "graphic_vga.h"

void wait(int cycles) {
    for (int i = 0; i < cycles; i++) {
        asm("nop");
    }
}

int main()  {  
    clear_screen();
    rvc_printf("HELLO DANIEL\n");
    int test = 123456789;
    rvc_print_int(test);
    int counter = 0;
    while(1) {
        set_cursor(50, 50);
        rvc_print_int(counter++);
    }
    return 0;
    
}  // main()
