#include "big_core_defines.h"
#include "graphic_vga.h"
int main(){
    clear_screen();
    rvc_printf("   JOYSTICK LOCATION\n\n");
    rvc_printf("   X \n");
    rvc_printf("   Y \n");
    while(1){
        int x_value;
        int y_value;
        READ_REG(x_value, CR_JOYSTICK_X);
        READ_REG(y_value, CR_JOYSTICK_Y);
        set_cursor(4,5);
        rvc_printf("    ");
        set_cursor(4,5);
        rvc_print_int(x_value);
        set_cursor(6,5);
        rvc_printf("    ");
        set_cursor(6,5);
        rvc_print_int(y_value);
        rvc_delay(1000000);
    }
    return 0;
}