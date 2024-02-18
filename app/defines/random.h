/**********************************************************
 * random numbers library - based on 32bit LFSR algorithm
**********************************************************/

#ifndef RANDOM_H
#define RANDOM_H

unsigned int lfsr_seed;

void set_lfsr_seed(int seed){
    lfsr_seed = seed;
}

// generate 32bit pseudo random number
unsigned int get_random_int(){
    
    int feedback_bit = ((lfsr_seed >> 31) ^ (lfsr_seed >> 21) ^ (lfsr_seed >> 1) ^ (lfsr_seed >> 0)) & 1; // polynomial of bits: 31, 21, 1, 0. Achieving the biggest period
    lfsr_seed = (lfsr_seed >> 1) | (feedback_bit << 31);   
    return lfsr_seed;

}

// generate pseudo random number between 0 - 127
unsigned int get_random_0_127(){

    //return get_random_int() & 0x7F;
    return get_random_int() % 128;

}

// generate pseuso random number in range between min and max
unsigned int get_random_range(int min, int max) {
    if (min >= max) {
        return min; // Return min if the range is invalid.
    }
    unsigned int range = (unsigned int)(max - min + 1);
    return (get_random_int() % range) + min;
}














#endif