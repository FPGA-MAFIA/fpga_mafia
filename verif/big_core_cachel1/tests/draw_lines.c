//------------------------------------------------------------
// Title : draw line
// Project : big_core_cachel1
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
   // set_pixel(1,1,1);
    set_cursor(5,0);
    //draw a house:
    draw_line(7, 0, 0, 5, 1);   //left side of the roof
    draw_line(8, 0, 15, 5, 1);  //right side of the roof
    draw_line(0, 5, 15, 5, 1);  //base of the roof
    draw_line(0, 5, 0, 15, 1);  //left side of the house
    draw_line(15, 5, 15, 15, 1);//right side of the house
    draw_line(1, 15, 15, 15, 1);//base of the house
    
    draw_circle(25, 8, 5, 1);    //draw a circle next to the house
    //draw_circle(30, 30, 10, 1);
return 0;
}  // main()
