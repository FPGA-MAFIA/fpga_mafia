#include "big_core_defines.h"
#include "graphic_vga.h"
#include "string.h"

int fibbonacci(int n);

int main() {
    int n;
    char str[10];

    rvc_printf("Enter the number of terms: ");
    rvc_scanf(str, 10);
    n = atoi(str);
    
    rvc_printf("\nFibonacci Item ");
    rvc_printf(str);
    rvc_printf(" is: ");
    rvc_print_int(fibbonacci(n));
    rvc_printf("\n");
   
    return 0;
}

int fibbonacci(int n) {
    if (n <= 1) {
        return n;
    }
    
    return fibbonacci(n - 1) + fibbonacci(n - 2);
}