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

int main()  {  
    int cr_switch;
    for(int i=0;i<10;i++) {
        cr_switch = CR_SWITCH[0];
        fpga_7seg_print(cr_switch);
        CR_LED[0] = cr_switch;
    }
    
    return 0;
}  // main()
