
#include "ann_test.h"
#include "big_core_defines.h"
#include "graphic_vga.h"

#define WEIGHTS_SLL_VAL 8
#define NUM_OF_LAYERS 2 
#define NUM_OF_INPUTS 12
#define NUM_OF_NEURONS_L1 6
#define NUM_OF_NEURONS_L2 6
#define SIGMOID_STRECH 5
#define SUCCESS 0
#define FAIL -1

/*matrices*/
int weights_L1[NUM_OF_INPUTS][NUM_OF_NEURONS_L1] = {
    {-8, -50, 108, 76, 38, 62},
    {-159, -48, 118, 179, 45, 53},
    {20, -23, 54, -89, -253, 27},
    {7, 31, -15, -31, -3, 2},
    {70, 8, 11, -5, -9, -17},
    {-217, -127, 205, 145, -237, 34},
    {17, -2, 11, -28, -12, -8},
    {84, -30, 46, 17, 36, 129},
    {50, 308, 66, -158, -26, 407},
    {-5, -1, 25, 2, 1, 0},
    {-65, 150, 272, 54, -96, 72},
    {-7, -9, 30, 63, 10, 14}
};

int biases_L1[NUM_OF_NEURONS_L1] = {
    180,
    261,
    3,
    186,
    142,
    -85
};

int weights_L2[NUM_OF_NEURONS_L1][NUM_OF_NEURONS_L2] = {
    {-34, 224, 21, -134, 3, -87},
    {92, 16, 164, -10, 143, -159},
    {-66, 245, -145, 7, 239, -231},
    {-227, 205, 86, 130, -67, 164},
    {-204, 240, -45, -327, -86, -24},
    {374, -13, -121, 44, -129, -163}
};

int biases_L2[NUM_OF_NEURONS_L2] = {
    -78,
    66,
    66,
    211,
    42,
    156
};

int weights_output[NUM_OF_NEURONS_L2] = {
    226,
    -112,
    -254,
    325,
    -317,
    294
};

int bias_output = -39;

/***********************main*************************************/

int main() {       
     
    /*init Weights*/
    //int inputs[NUM_OF_INPUTS] = {1,0,0,600,1,40,3,60000,2,1,1,50000} ; //change for each specfic run
    //int L1[NUM_OF_NEURONS_L1] = {0};
    //int L2[NUM_OF_NEURONS_L2] = {0};

    //layer_calc(inputs , NUM_OF_INPUTS , L1 , NUM_OF_NEURONS_L1 , weights_L1 , biases_L1);
    //layer_calc(L1 , NUM_OF_NEURONS_L1 , L2 , NUM_OF_NEURONS_L2 , weights_L2 , biases_L2);
    //int sra_val = (NUM_OF_LAYERS + 1) * WEIGHTS_SLL_VAL - SIGMOID_STRECH;
    //int output = score_calc(L2 , NUM_OF_NEURONS_L2 , weights_output , bias_output , sra_val );
    
    //printf("output is: %d" , output);
    rvc_printf("yolo");
    //rvc_print_int(output);
    
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
    if (x > 150)
        return 1;
    if (x > -150)
        return 0;
    return sigmoid_scaled32[x + 150];
}

int neuron_calc(int* prevL , int prevL_len , int weights[][6] , int bias[] , int out_neuro_idx) {
    int sum = bias[out_neuro_idx];
    for (int j = 0 ; j < prevL_len ; j++) {
        sum += prevL[j] * weights[out_neuro_idx][j];
    }
    return Relu_func(sum);
}

int score_calc(int* prevL , int prevL_len , int *weights , int bias , int SRA) {
    int sum = bias;
    for (int j = 0 ; j < prevL_len ; j++) {
        sum += prevL[j] * weights[j];
    }
    return sigmoid_func_scaled32(sum >> SRA);
}


void layer_calc (int* prevL , int prevL_len , int *nextL , int nextL_len , int weights[][6] , int *bias) {
    for (int j = 0 ; j < nextL_len ; j++) {
        nextL[j] = neuron_calc(prevL , prevL_len , weights , bias , j);
    }
}

