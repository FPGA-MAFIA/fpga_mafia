/* Test reading the CR value and print to Display */

#include "big_core_defines.h"
#include "graphic_vga.h"

int main(){

        int count_x;
        int count_y;

        for (int i = 0; i < 2; i++){
                READ_REG(count_x, CR_VGA_COUNTER_X);
                READ_REG(count_y, CR_VGA_COUNTER_Y);
                //printf("X: "%d, Y: %d\n", count_x[i], count_y[i]);
                rvc_printf("X: ");
                rvc_print_int(count_x);
                rvc_printf(", Y: ");
                rvc_print_int(count_y);
                rvc_printf("\n");
        }

        return 0;
}