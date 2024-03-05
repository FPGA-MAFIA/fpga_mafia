
#include "big_core_defines.h"
#include "graphic_vga.h"
int main(){

char str[4];

rvc_scanf(str, 4);


// manually cast and zero extend the  char to int
int a_char = (int)str[0];
int b_char = (int)str[1];
int c_char = (int)str[2];
int d_char = (int)str[3];


rvc_print_unsigned_int_hex(a_char);
rvc_printf("\n");
rvc_print_unsigned_int_hex(b_char);
rvc_printf("\n");
rvc_print_unsigned_int_hex(c_char);
rvc_printf("\n");
rvc_print_unsigned_int_hex(d_char);
rvc_printf("\n");

return 0;
}