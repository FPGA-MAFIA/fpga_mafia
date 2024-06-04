// compare between two numbers

#include "big_core_defines.h"
#include "graphic_vga.h"

int main() {

    char str1[10];
    char str2[10];

    rvc_printf("INPUT1:\n> ");
    rvc_scanf(str1, 10);
    rvc_printf("\nYOUR INPUT: ");
    rvc_printf(str1);
    
    rvc_printf("\n");
    
    rvc_printf("INPUT2:\n> ");
    rvc_scanf(str2, 10);
    rvc_printf("\nYOUR INPUT: ");
    rvc_printf(str2);
    
    rvc_printf("\n");

    int num1 = str1[0] - '0';
    int num2 = str2[0] - '0';

    if(num1 >= num2)
        rvc_print_int(num1);
    else
        rvc_print_int(num2);

    return 0;
}
