#include "LOTR_defines.h"
#include "graphic_lotr.h"

void print_large_integer(int *arr, int size) {
    int i;
    for (i = 0; i < size; i++) {
        rvc_print_int(arr[i]);
    }
}

void print_fixed_point_large(int *value, int size) {
    print_large_integer(value, size);
    rvc_printf(".");
    print_large_integer(value + size, size);
}


void calculate_pi(int iterations, int precision) {
  int i;
  int size = precision / 9 + 1;
  int pi_numerator[2 * size];

  // Initialize the pi_numerator array to zero using a for loop
  for (i = 0; i < 2 * size; i++) {
      pi_numerator[i] = 0;
  }

  for (i = 0; i < iterations; ++i) {
    int term_numerator = (i % 2 == 0 ? 1 : -1) * 1000000000 / (2 * i + 1);
    int j;
    for (j = 2 * size - 1; j > 0; --j) {
      term_numerator = (pi_numerator[j] / 1000000000) * j;
      pi_numerator[j] += term_numerator;
      pi_numerator[j] %= 1000000000;
    }
    pi_numerator[0] += term_numerator;

    rvc_printf("ITER ");
    rvc_print_int(i + 1);
    rvc_printf(". ");
    print_fixed_point_large(pi_numerator, size);
    rvc_printf("\n");
  }
}


int run_t0() {
  int iterations = 1000; // Increase for a more accurate result
  int precision = 36; // Set the number of digits to be calculated and displayed
  rvc_printf("CALC \n");
  calculate_pi(iterations, precision);
  return 0;
}

int main() {
    int UniqeId  = CR_WHO_AM_I[0];
    switch (UniqeId) {
        case 0x4 : run_t0(); // Core 1 Thread 0
        break;
        default :
            while(1);
        break;
    }

    if(UniqeId != 0x4){
        while(1);
    }

    return 0;
}
