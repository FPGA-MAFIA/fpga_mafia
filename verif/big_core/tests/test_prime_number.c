#include "big_core_defines.h"
#include "graphic_vga.h"


/**
 * @brief - This function checks if the number passed as a parameter is a prime number.
 * @param:  int x : the number that we check
 * @result: 1 prime, 0 else 
*/
int isPrime(int x);


int main()
{
    if(isPrime(17))
    {
        rvc_printf("YES!");
    }
    else
    {
        rvc_printf("NO");
    }
    return 0;
}

int isPrime(int x)
{
    if( x<=1 )
        return 0;
    if( x==2 || x==3 )
        return 1;
    if( x%2 == 0 )
        return 0;
    for(int i=3; i<x; i+=2) // we can run up to sqrt(x) but we don't know if our core supports sqrt yet :(
    {
        if( x%i == 0 )
            return 0;
    }
    return 1;
}