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

int main() {
    float a = 1.5, b = 2.7; 
    float c = a + b;
    D_MEM_SCRATCH[0]=c;   

    return 0;
}

