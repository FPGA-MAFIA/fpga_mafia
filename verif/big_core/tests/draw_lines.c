//------------------------------------------------------------
// Title : draw line
// Project : big_core
//------------------------------------------------------------
// File : draw_line.c
// Author : Amichai Ben-David
// Adviser : Amichai Ben-David
// Created : 06/2023
//------------------------------------------------------------
// Description :
// POC of using the graphic library to draw lines and circles
//------------------------------------------------------------
#include "big_core_defines.h"
#include "graphic_vga.h"
int main()  {  
    set_pixel(1,1,1);
  
    draw_line(5, 10, 25, 25, 1);
    draw_circle(30, 30, 10, 1);
return 0;
}  // main()
