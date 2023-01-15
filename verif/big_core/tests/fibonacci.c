#include <stdio.h>

int fibonacci(int n) {
    if (n <= 0) return 0;
    if (n == 1) return 1;
    return fibonacci(n-1) + fibonacci(n-2);
}

int main() {
    int n = 10;
    int res = fibonacci(n);
    // printf("%d\n", fibonacci(n));
    return 0;
}

