//------------------------------------------------------------
// Title : floating points test
// Project : big_core
//------------------------------------------------------------
// File : floating_points.c
// Author : Daniel Kaufman
// Adviser : Amichai Ben-David
// Created : 01/2023
//------------------------------------------------------------
// Description :
// This program performs basic floating-point
// arithmetic operations. 
//------------------------------------------------------------
#include "big_core_defines.h"
#include "graphic_vga.h"

void print_float_binary(float f) {
    // A union to represent the float value as an integer
    union {
        float f;
        int i;
    } u;
    u.f = f;
    // Extract the bits of the float value and print them as binary
    for (int i = 31; i >= 0; i--) {
        if (u.i & (1 << i)) {
            rvc_printf("1");
        } else {
            rvc_printf("0");
        }
    }
}

int main() {
    float a = 1.5, b = 2.7; 
    float c = a + b;
    union {
        float f;
        int i;
    } u;
    u.f = c;
    D_MEM_SCRATCH[0]=u.f;   
    D_MEM_SCRATCH[1]=u.i;   
    //===========================================
    //Uncomment this to see the print to screen.log
    //===========================================
    // rvc_printf("RAW  ");
    // rvc_print_int(u.i);
    // rvc_printf("\nCAST  ");
    // rvc_print_int(u.f);
    // rvc_printf("\nBINARY  ");
    // print_float_binary(u.f);
    return 0;
}

