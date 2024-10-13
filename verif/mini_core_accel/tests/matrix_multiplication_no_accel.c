//===========================================================
// testing 4x4 matrix multiplication without acceleration
//===========================================================

//./build.py -dut mini_core_accel -test matrix_multiplication_no_accel -app -hw -sim -clean

#include "mini_core_accel_defines.h"
#include "mafia_accel.h"

void multiply_4x4_matrix(int8_t A[4][4], int8_t B[4][4], int16_t C[4][4]) {
    // Initialize result matrix C to zero
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            C[i][j] = 0;
        }
    }

    // Matrix multiplication logic
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            for (int k = 0; k < 4; k++) {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }
}


int main() {
    // Initialize two 4x4 matrices A and B
    int8_t A[4][4] = {
        {1, 2, 3, 4}, 
        {5, 6, 7, 8}, 
        {9, 10, 11, 12}, 
        {13, 14, 15, 16}
    };

    int8_t B[4][4] = {
        {17, 18, 19, 20}, 
        {21, 22, 23, 24}, 
        {25, 26, 27, 28}, 
        {29, 30, 31, 32}
    };

    // Declare result matrix C
    int16_t C[4][4];

    // Call the matrix multiplication function
    multiply_4x4_matrix(A, B, C);

    return 0;
}
