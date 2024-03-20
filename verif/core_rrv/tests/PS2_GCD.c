//in this file we implement how to recive tow parameter from the keybord and output the G.C.D of them to the screen 

#include "big_core_defines.h"
#include "graphic_vga.h"
#include "string.h"


int GCD(int a,int b);


int main() {
    // define paremeters
    char str1[10];
    char str2[10];
    int gcd = 0 , a = 0 , b = 0 ; 

    rvc_printf("Enter two integers :\n"); //give tow parameers to calculate G.C.D.

    rvc_printf("a = ");// parmeter 1
    rvc_scanf(str1, 10);
  
    rvc_printf("\n");
    
    rvc_printf("b = ");//parameter 2
    rvc_scanf(str2, 10);
 
    rvc_printf("\n");

    a = atoi(str1);//convert paremeter 1 to integer
    b = atoi(str2);//convert paremeter 2 to integer
    gcd = GCD(a,b);//call to GCD function
        


    rvc_printf("The G.C.D of ("); //plot to the screen.log in fpga_mafia\target\core_rrv\tests\PS2_GCD\screen.log
    rvc_print_int(a);
    rvc_printf(",");
    rvc_print_int(b);
    rvc_printf(") is : ");
    rvc_print_int(gcd);
    rvc_printf("\n");
    return 0;
}


int GCD(int a,int b) {
    // this algorithm calculate the G.C.D. betwwen tow parameters by Euclid

    while(a!=b)
    {
        if(a > b) 
            a -= b;
          
        else 
            b -= a;     
    }

    return a;
}