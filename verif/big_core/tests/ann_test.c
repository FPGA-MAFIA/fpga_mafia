
#include "ann_test.h"
#include "big_core_defines.h"
#include "graphic_vga.h"

#define WEIGHTS_SLL_VAL 6 
#define NUM_OF_LAYERS 2 
#define NUM_OF_INPUTS 12
#define NUM_OF_NEURONS_L1 6
#define NUM_OF_NEURONS_L2 6
#define SIGMOID_STRECH 5
#define SUCCESS 0
#define FAIL -1

/*matrixes*/

int weights_L1[NUM_OF_INPUTS][NUM_OF_NEURONS_L1] = {
    {4, -10, 18, 2, 8, 31},
    {-3, 10, 10, -1, -54, 27},
    {5, 0, 16, 23, 54, -66},
    {-4, -3, 2, -2, 2, 1},
    {20, 13, 29, 3, 1, 2},
    {50, 11, -46, 23, -48, -41},
    {5, -4, -4, 8, 6, 3},
    {-25, -42, -20, 0, -27, -7},
    {-10, -79, -29, 81, -38, -17},
    {5, -5, -4, 0, -4, -2},
    {72, -18, -3, 29, 4, 4},
    {4, 7, 15, -6, -18, -5}
};

int biases_L1[NUM_OF_NEURONS_L1] = {4, 5, 55, 29, 18, 36};

int weights_L2[NUM_OF_NEURONS_L1][NUM_OF_NEURONS_L2] = {
    {-18, -58, -45, 7, -41, 85},
    {-11, -16, -78, 52, 44, -20},
    {-9, 62, 43, 6, -16, 57},
    {38, 14, 37, -61, 30, 20},
    {-49, 31, -34, 5, -42, -2},
    {-35, 60, -20, 26, -67, -2}
};

int biases_L2[NUM_OF_NEURONS_L2] = {1, 31, -26, 20, 39, 34};

int weights_output[NUM_OF_NEURONS_L2] = {71, -51, 109, 71, 62, -36};

int bias_output = -16;

/***********************main*************************************/
/**
 * @param inputs[0] = FRANCE
 * @param inputs[1] = SPAIN
 * @param inputs[2] = GERMANY
 * @param inputs[3] = CREDIT SCORE
 * @param inputs[4] = GENDER
 * @param inputs[5] = AGE
 * @param inputs[6] = TENURE
 * @param inputs[7] = BALANCE
 * @param inputs[8] = NumOfProducts
 * @param inputs[9] = HasCrCard
 * @param inputs[10] = IsActiveMember
 * @param inputs[11] = EstimatedSalary
 */
int main() {        
    /*load data*/
    
    /*init Weights*/
    int inputs[NUM_OF_INPUTS] = {0, 1, 0, 12, 1, 20, 3, 127, 2, 1, 1, 127} ; //change for each specfic run
    int L1[NUM_OF_NEURONS_L1] = {0};
    int L2[NUM_OF_NEURONS_L2] = {0};

    layer_calc(inputs , NUM_OF_INPUTS , L1 , NUM_OF_NEURONS_L1 , weights_L1 , biases_L1);
    layer_calc(L1 , NUM_OF_NEURONS_L1 , L2 , NUM_OF_NEURONS_L2 , weights_L2 , biases_L2);
    int output = score_calc(L2 , NUM_OF_NEURONS_L2 , weights_output , bias_output);
    
    //printf("output is: %d" , output);
    rvc_printf(" logog");
    rvc_print_int(output);

    return 0;
}


/***************helpers func*******************************/
int Step_func(int x) {
    if (x > 0)
        return 1;
    return 0;
}

int Relu_func(int x) {
    if (x > 0)
        return x;
    return 0;
}



int sigmoid_scaled32[300] = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 3, 3, 3, 3, 3, 3, 3, 3,
    3, 3, 3, 4, 4, 4, 4, 4, 4, 4,
    4, 4, 5, 5, 5, 5, 5, 5, 6, 6,
    6, 6, 6, 6, 7, 7, 7, 7, 7, 8,
    8, 8, 8, 9, 9, 9, 9, 10, 10, 10,
    10, 11, 11, 11, 12, 12, 12, 13, 13, 13,
    14, 14, 14, 15, 15, 16, 16, 16, 17, 17,
    18, 18, 19, 19, 20, 20, 21, 21, 22, 22,
    23, 23, 24, 25, 25, 26, 26, 27, 28, 28,
    29, 29, 30, 31, 31, 32, 33, 33, 34, 35,
    36, 36, 37, 38, 38, 39, 40, 41, 41, 42,
    43, 44, 45, 45, 46, 47, 48, 48, 49, 50,
    51, 52, 52, 53, 54, 55, 55, 56, 57, 58,
    59, 59, 60, 61, 62, 62, 63, 64, 64, 65,
    66, 67, 67, 68, 69, 69, 70, 71, 71, 72,
    72, 73, 74, 74, 75, 75, 76, 77, 77, 78,
    78, 79, 79, 80, 80, 81, 81, 82, 82, 83,
    83, 84, 84, 84, 85, 85, 86, 86, 86, 87,
    87, 87, 88, 88, 88, 89, 89, 89, 90, 90,
    90, 90, 91, 91, 91, 91, 92, 92, 92, 92,
    93, 93, 93, 93, 93, 94, 94, 94, 94, 94,
    94, 95, 95, 95, 95, 95, 95, 96, 96, 96,
    96, 96, 96, 96, 96, 96, 97, 97, 97, 97,
    97, 97, 97, 97, 97, 97, 97, 98, 98, 98,
    98, 98, 98, 98, 98, 98, 98, 98, 98, 98,
    98, 98, 98, 98, 98, 98, 98, 98, 98, 98,
    98, 98, 98, 98, 98, 98, 98, 98, 98, 98
    };

int sigmoid_func_scaled32(int x) {
    
    if (x > 149)
        return 100;
    if (x < -150)
        return 0;
    return sigmoid_scaled32[x + 150];
}

int neuron_calc(int* prevL , int prevL_len , int weights[][6] , int bias[] , int out_neuro_idx) {
    int sum = bias[out_neuro_idx];
    for (int j = 0 ; j < prevL_len ; j++) {
        sum += prevL[j] * weights[j][out_neuro_idx];
    }
    return Relu_func(sum);
}

int score_calc(int* prevL , int prevL_len , int *weights , int bias) {
    int sum = bias;
    int sra_val = (NUM_OF_LAYERS + 1) * WEIGHTS_SLL_VAL - SIGMOID_STRECH;
    for (int neuron_idx = 0 ; neuron_idx < prevL_len ; neuron_idx++) {
        sum += prevL[neuron_idx] * weights[neuron_idx];
    }
    return sigmoid_func_scaled32(sum >> sra_val);
    //return 0;
}


void layer_calc (int* prevL , int prevL_len , int *nextL , int nextL_len , int weights[][6] , int *bias) {
    for (int neuron_idx = 0 ; neuron_idx < nextL_len ; neuron_idx++) {
        nextL[neuron_idx] = neuron_calc(prevL , prevL_len , weights , bias , neuron_idx);
    }
}

