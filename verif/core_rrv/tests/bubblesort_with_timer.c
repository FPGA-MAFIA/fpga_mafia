#include "interrupt_handler.h"

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
int main() {
    //enable the mie timer interrupts CSR:
    unsigned int csr_mie = read_mie();
    csr_mie = csr_mie | 0x00000888;
    write_mie(csr_mie); // enable msie, mtie, meie bits in mie

    int arr[] = {64, 34, 25, 12, 22, 11, 90};
    int n = sizeof(arr)/sizeof(arr[0]);

    bubbleSort(arr, n);
    printSorted(arr, n);

    rvc_printf("\n");
    rvc_print_int(COUNT_MACHINE_TIMER_INTRPT[0]);
    return 0;
}

