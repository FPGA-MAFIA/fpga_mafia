
//------------------------------------------------------------
// Title : alive_lfsr
// Project : big_core_cachel1
//------------------------------------------------------------
// Description :
//generating LENGTH pseudo random numbers created using LFSR
//------------------------------------------------------------
#include "interrupt_handler.h"

#define LENGTH 15

// Function to generate the next LFSR value
unsigned int lfsr(unsigned int current_state) {
    // Feedback polynomial: x^8 + x^6 + x^5 + x^4 + 1
    // We use taps at positions 8, 6, 5, and 4.
    unsigned int bit = ((current_state >> 7) ^ (current_state >> 5) ^ (current_state >> 4) ^ (current_state >> 3)) & 1;
    return (current_state << 1) | bit; // Shift left and add feedback bit
}

// Function to generate a pseudo-random number in the range 0-99
unsigned int lfsr_random_0_99(unsigned int seed) {
    unsigned int random_value = 0;
    for (int i = 0; i < 7; ++i) { // Generate 7 bits
        seed = lfsr(seed); // Update LFSR state
        random_value = (random_value << 1) | (seed & 1); // Append LSB of LFSR state to random_value
    }
    return random_value % 100; // Modulate by 100 to get a range of 0-99
}

void bubbleSort(int arr[], int n) {
    int i, j;
    for (i = 0; i < n-1; i++) {
        for (j = 0; j < n-i-1; j++) {
            if (arr[j] > arr[j+1]) {
                int temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            }
        }
    }
}

void printSorted(int arr[], int n){
    int i;
    for (i = 0; i < n; i++) {
        rvc_print_int(arr[i]);
        rvc_printf(" ");
    }
}

int check_sort(int arr[], int n){
    int i;
    for(i=0; i < n-1; i++){
        if(arr[i] > arr[i+1])
            return 0;
        i++;
    }

    return 1; 
}
int main() {    
    //enable the mie timer interrupts CSR:
    unsigned int csr_mie = read_mie();
    csr_mie = csr_mie | 0x00000888;
    write_mie(csr_mie); // enable msie, mtie, meie bits in mie

    unsigned int seed = 0xACE1u; // Non-zero seed
    unsigned int random_numbers[LENGTH];

    // Fill the array with pseudo-random numbers within the range 0-99
    for (int i = 0; i < LENGTH; ++i) 
        random_numbers[i] = lfsr_random_0_99(seed + i); // Use varying seeds for each number

    int n = sizeof(random_numbers)/sizeof(random_numbers[0]);

    bubbleSort(random_numbers, n);
    //printSorted(random_numbers, n); // leave that line comment for shorter V_TIMEOUT

    if(check_sort(random_numbers, n))
        rvc_printf("SORT PASS\n");
    else    
        rvc_printf("SORT FAILD\n");

    rvc_print_int(COUNT_MACHINE_TIMER_INTRPT[0]);


    return 0;
}
