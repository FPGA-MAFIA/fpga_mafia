#include "big_core_defines.h"

int gcd(int a, int b) {
    if (b == 0) return a;
    return gcd(b, a % b);
}

int main() {
    int a = 48, b = 18;
    int gcd_res = gcd(a, b);
    D_MEM_SCRATCH[0]=gcd_res;
    return 0;
}

