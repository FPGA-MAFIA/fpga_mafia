#include <stdio.h>

int gcd(int a, int b) {
    if (b == 0) return a;
    return gcd(b, a % b);
}

int main() {
    int a = 48, b = 18;
    int c = gcd(a, b);
    // printf("%d\n", gcd(a, b));
    return 0;
}

