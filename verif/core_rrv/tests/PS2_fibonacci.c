//======================================
//    Calculate fibbonaci numbers
//======================================

#include "big_core_defines.h"
#include "graphic_vga.h"

int fibonacci(int n) {

    if (n == 1 || n == 2)
        return 1;

    return fibonacci(n-1) + fibonacci(n-2);    
}


int main(){

    char str[30]; // max number is 99
    int n;

    rvc_printf("ENTER A NUMBER:\n>");
    rvc_scanf(str, 30); // max size is 2 (not include '\n')
    n = (str[0]-48);  // TODO - add str_len function
    rvc_printf("\n>");
    rvc_print_int(fibonacci(n));

    return 0;
}