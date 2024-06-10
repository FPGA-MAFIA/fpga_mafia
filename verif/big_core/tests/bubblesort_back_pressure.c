#include "big_core_defines.h"
#include "graphic_vga.h"

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

void eot(int arr[]) {
    for(int i =0; i<7; i++){
        D_MEM_SCRATCH[i]=arr[i];
    }
}
int main() {
    int arr[] = {64, 34, 25, 12, 22, 11, 90};
    int n = sizeof(arr)/sizeof(arr[0]);

    bubbleSort(arr, n);
    eot(arr);

    // print sorted arr for testing re issue of vga mem
    for(int i=0; i<n; i++){
        rvc_print_int(arr[i]);
        rvc_printf(" ");
    }

    // printf("Sorted array: \n");
    // for (int i=0; i < n; i++)
    //     printf("%d ", arr[i]);
    // printf("\n");
    return 0;
}

