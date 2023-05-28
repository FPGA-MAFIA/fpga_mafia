#include "LOTR_defines.h"
#include "graphic.h"
int main() {
    int UniqeId = CR_WHO_AM_I[0];
    switch (UniqeId) //the CR Address
    {
        case 0x4 : //  
        rvc_printf("HI\n");
        break;
        default :
            while(1); 
        break;
       
    }// case

return 0;

}