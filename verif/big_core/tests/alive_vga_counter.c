/* Test reading the CR value and print to Display */

#include "big_core_defines.h"
#include "graphic_vga.h"

int main(){

        int count_x[10];
        int count_y[10];

        for (int i = 0; i < 10; i++){
            READ_REG(count_x[i], CR_VGA_COUNTER_X);
            READ_REG(count_y[i], CR_VGA_COUNTER_Y);
        }

        for (int i = 0; i < 10; i++){
                //printf("X: "%d, Y: %d\n", count_x[i], count_y[i]);
                rvc_printf("X: ");
                rvc_print_int(count_x[i]);
                rvc_printf(", Y: ");
                rvc_print_int(count_y[i]);
                rvc_printf("\n");
        }

        return 0;
}