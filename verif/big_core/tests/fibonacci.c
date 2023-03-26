#include "../../../app/defines/big_core_defines.h"

int fibonacci(int n) {
    if (n <= 1) return 0;
    if (n == 2) return 1;
    return fibonacci(n-1) + fibonacci(n-2);
}

int main() {
    int n = 10;
    int res = fibonacci(n);
    D_MEM_SCRATCH[0]=res;
    return 0;
}

