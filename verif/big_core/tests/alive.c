//------------------------------------------------------------
// Title : alive test
// Project : big_core
//------------------------------------------------------------
// File : alive.c
// Author : Daniel Kaufman
// Adviser : Amichai Ben-David
// Created : 01/2023
//------------------------------------------------------------
// Description :
// This program is a basic sanity test for the target device.
//------------------------------------------------------------
#include "../../../app/defines/big_core_defines.h"
int main()  {  
    int x,y,z;  
    x = 17;  
    y = 11;  
    z = x*y;  
    D_MEM_SCRATCH[0]=z;
    WRITE_REG(CR_LED, 0xf);
    READ_REG(z,CR_LED);
    D_MEM_SCRATCH[1]=z;
    return 0;
}  // main()
