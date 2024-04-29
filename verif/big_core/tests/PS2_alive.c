
#include "big_core_defines.h"
#include "graphic_vga.h"
#include "interrupt_handler.h"
int main(){

char str[30];

//clear_screen();  // uncomment that line when running only with -app for clean screen in FPGA

rvc_printf("ENTER A STRING:\n> ");
rvc_scanf(str, 30);
rvc_printf("\nYOU ENTERED: ");
rvc_printf(str);


return 0;
}