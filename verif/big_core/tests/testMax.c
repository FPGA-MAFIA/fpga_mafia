#include "big_core_defines.h"
#include "graphic_vga.h"


int main(){

    int x =1, y=4,z=8;
    int max =x;

    if(max<y) max =y;
    if(z>max) max =z;

    rvc_print_int(max);
    return 0;
}