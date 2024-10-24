#include "accel_funcs.c"
int main()
{
    int num_of_mats = 3 ;
    int rows[3] = {2, 4, 3};
    int cols[3] = {4, 3, 5};
    int *bias[3];
    int *mat_array[3];
    mat_array[0] = (int[])  {-1, 2 ,-1 , 2,
                             -2, 1, -2 ,1};
    bias[0] = (int[]){       1, 2, 3, 4};
    //-----------------------------------------
    mat_array[1] = (int[]){ 1, -2, 1,
                            -2, 1, -2,
                            1 ,-2, 1,
                            -2 ,1, -2};
    bias[1] = (int[])     { 1, 2, 3};
    //-----------------------------------------
    mat_array[2] = (int[]){ -1, 2, -1, 2, -1,
                            2, -1, 2, -1, 2,
                            -1, 2, -1, 2, -1};
    bias[2] = (int[]){      1, 2, 3, 4, 5};
     //-----------------------------------------

    if(init_accel_core (mat_array, rows, cols,num_of_mats ,bias) == FAIL)
        {
            return FAIL;
        }
    int data[2] = {5, 2};
    calc_network(data,2);
    cleanup(3);
  return 0;
}
