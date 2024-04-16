
#include "big_core_defines.h"
#include "graphic_vga.h"
#include "interrupt_handler.h"
int main(){

char str[30];

rvc_printf("1)\n> ");
rvc_scanf(str, 30);
rvc_printf("\n: ");
rvc_printf(str);

rvc_printf("\n2)\n> ");
rvc_scanf(str, 30);
rvc_printf("\n: ");
rvc_printf(str);

return 0;
}