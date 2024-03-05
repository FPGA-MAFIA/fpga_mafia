
#include "big_core_defines.h"
#include "graphic_vga.h"
int main(){

char str[30];

rvc_printf("ENTER A STRING:\n> ");
rvc_scanf(str, 30);
rvc_printf("\nYOU ENTERED: ");
rvc_printf(str);


return 0;
}