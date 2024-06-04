#include "math_functions1.h"
#include "math_functions2.h"
#include "big_core_defines.h"
#include "graphic_vga.h"

// That test demonstrates the usage of the function defined in another file
// this is useful when we want to separate the code in different files
// when doing this, we need to include the header or *.c file that contains the function definition
// The header or the *.c file must be locates in test directory named exactly as the file that includes the main function 
int main(){

    int x = 5;
    int y = 3;

    int s = sum(x,y); 
    rvc_print_int(s);

    int diff = sub(x,y); 
    rvc_print_int(diff);

    int cust = custom(x,y); 
    rvc_print_int(cust);

    return 0;
}