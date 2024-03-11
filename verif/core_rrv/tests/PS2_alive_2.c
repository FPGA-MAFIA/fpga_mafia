
#include "big_core_defines.h"
#include "graphic_vga.h"
#include "interrupt_handler.h"
int main(){

char str1[30];
char str2[30];

rvc_printf("INPUT:\n> ");
rvc_scanf(str1, 30);
rvc_printf("\nYOUR INPUT: ");
rvc_printf(str1);

//rvc_printf("\nENTER A STRING2:\n> ");
rvc_printf("\nINPUT:\n> ");
rvc_scanf(str2, 30);
rvc_printf("\nYOUR INPUT: ");
rvc_printf(str2);


return 0;
}