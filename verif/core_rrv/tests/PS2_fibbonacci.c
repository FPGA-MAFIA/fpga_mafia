#include "big_core_defines.h"
#include "graphic_vga.h"

int atoi(const char *str);
int strlen(const char *str);
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

int atoi(const char *str) {
    int result = 0;
    int sign = 1;
    int i = 0;
    
    // Skip leading whitespaces
    while (str[i] == ' ') {
        i++;
    }
    
    // Check for sign
    if (str[i] == '+' || str[i] == '-') {
        sign = (str[i++] == '-') ? -1 : 1;
    }
    
    // Convert digits to integer
    while (str[i] >= '0' && str[i] <= '9') {
        result = result * 10 + (str[i++] - '0');
    }
    
    return sign * result;
}

int strlen(const char *str) {
    int len = 0;
    
    while (str[len] != '\0') {
        len++;
    }
    
    return len;
}

int fibbonacci(int n) {
    if (n <= 1) {
        return n;
    }
    
    return fibbonacci(n - 1) + fibbonacci(n - 2);
}