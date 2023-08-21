#include "fabric_defines.h"


//create a simple bubble sort function to tests the access to scratchpad on other tiles

void bubble_sort(int *array, int size) {
    int i, j, temp;
    for (i = 0; i < size; i++) {
        for (j = 1; j < (size - i); j++) {
            if (array[j - 1] > array[j]) {
                temp = array[j - 1];
                array[j - 1] = array[j];
                array[j] = temp; 
            }
        }
    }
}

int main()  {  
int array [10] = {4, 2, 3, 1, 5, 6, 7, 8, 9, 10};
int size = 10;
//write array to scratchpad
int i;


for (i = 0; i < size; i++) {
    TILE_3_3_SCRATCH[i] = array[i];
}
// run bubble sort on scratchpad
bubble_sort(TILE_3_3_SCRATCH, size);
// read array from scratchpad
for (i = 0; i < size; i++) {
    array[i] = TILE_3_3_SCRATCH[i];
}
// check that the array is sorted
for (i = 0; i < size; i++) {
    if (array[i] != i + 1) {
        return 1;
    }
}


return 0;
}  // main()
