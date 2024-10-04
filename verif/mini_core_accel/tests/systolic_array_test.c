//===========================================================
// testing 4x4 systolic array grid
//===========================================================

//./build.py -dut mini_core_accel -test systolic_array_test -app -hw -sim -clean

#include "mini_core_accel_defines.h"
#include "mafia_accel.h"


int main() {

    // initialize activations (inputs) and weights
    int8_t activations[4][4] = {{1,2,3,4}, {5,6,7,8}, {9,10,11,12}, {13,14,15,16}};
    int8_t weights[4][4]     = {{2,3,4,5}, {6,7,8,9}, {10,11,12,13}, {14,15,16,17}};
    
    // set systolic array CR's with data
    set_systolic_array(activations, weights); // re-arrange the systolic array value.
                                              // Writing the function here will save some clock cycles wasted for jump and return   

    // starting calculation
    int start = 1;
    WRITE_REG(SYSTOLIC_ARRAY_START, start);

    int polling = 0;

    while(!polling){
        READ_REG(polling, SYSTOLIC_ARRAY_VALID);  
    }

    // Call systolic_array_result function to get the results
    int16_t (*results)[4] = systolic_array_result();  // No need to declare the matrix here

    // reset systolic array for next calculation
    start = 0;
    WRITE_REG(SYSTOLIC_ARRAY_START, start);


    return 0;
}