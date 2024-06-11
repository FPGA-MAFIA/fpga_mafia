#include "big_core_defines.h"
#include "graphic_vga.h"

int main() {

    int x = 1;
    int y = 2;

    int z = x + y;

    rvc_print_int(z);
    
    return 0;
}
