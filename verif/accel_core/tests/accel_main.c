#include "accel_funcs.h"
#define ONLY_INIT 0 
#define USE_ACCEL 0 
#define DEBUG 0

/** TO USE THE ACCEL_CORE:
 * define values: NUM_OF_MATS ; MEM_SIZE
 * inputs: rows[], cols[], mats_and_bias[], input vector[]
 * 
 */

/*this is how the user insert the matrices*/
	int rows[NUM_OF_MATS] = {15 , 15 ,15, 15};/*USER EDIT*/
	int cols[NUM_OF_MATS] = {15, 15, 15 ,  1};/*USER EDIT*/
	int mats_and_bias[] = /*USER EDIT*/
	{
	// Mat 1
	-3,  2,  1, -2, -2,  0,  2,  0,  2, -1, -1,  2, -1, -2, -2,
	-3, -3, -2,  0, -2, -3,  1, -3,  0,  0,  1,  3,  2,  1,  3,
	3,  2, -1, -3,  3,  3, -3,  3, -2,  0,  0,  3, -3, -3,  1,
	1,  1, -3, -1, -1, -2,  2, -2,  0,  0, -2,  1, -3, -3, -3,
	-3,  0,  1,  2, -1,  1,  0, -1,  2, -2, -3,  1,  3, -1,  3,
	0,  3,  3,  2, -1,  1,  1, -1,  2, -2, -3,  3, -3, -3,  0,
	3, -3,  2,  3, -1, -2,  2, -3, -2,  3, -3,  0, -1, -2, -3,
	-1,  1,  2,  0,  2,  3,  2,  0, -2,  3, -1, -1,  0, -1, -3,
	-1, -2,  0,  2, -1,  1, -3, -2, -1,  1,  2,  1, -2, -3,  3,
	-2, -3, -2,  1, -3,  0,  2, -1,  3, -1, -1, -1,  0,  1,  3,
	-2,  1, -2, -3,  1,  3,  0,  3,  1,  1,  1,  1,  2,  1,  1,
	-1,  2, -1, -2, -1,  0, -3,  3,  1,  1,  3, -3,  0, -2, -3,
	1,  0,  3, -2, -1, -3, -2, -3, -3,  3,  1,  3,  3, -3, -1,
	-2,  2, -2, -2, -3,  0, -3,  1, -3, -3,  0, -2, -2, -1,  0,
	1, -2,  0, -2,  3,  2,  0, -1,  3,  0, -2,  1, -1,  0, -3,
	// Bias 1
	0, -1,  0,  1, -3, -3, -1,  0,  0, -2,  3,  2,  0,  3,  1,
	// Mat 2
	-2, -1, -3, -2,  1,  0, -3,  0,  1,  0,  3, -2, -3, -2,  0,
	2, -2,  2,  3, -3, -2,  2, -3, -2,  2, -3,  2, -1,  2,  1,
	0,  0,  0,  0, -1,  3,  3,  3, -3, -2, -3, -2,  1,  0, -1,
	-2,  1, -3,  0, -2,  3, -1, -1,  0, -1, -1,  3,  3,  3,  3,
	3,  0,  0,  3, -2, -1,  1,  2,  0, -3,  2, -3,  1, -1,  3,
	-3, -1,  1,  2, -1, -1, -2, -2,  0, -1,  0, -3,  1,  3,  3,
	0,  3, -3, -1, -2,  2,  1,  2,  1,  2,  2,  2,  1,  3,  1,
	3, -1,  3, -3, -2,  0, -3,  3,  3,  0, -2,  3,  2,  1,  2,
	1, -1,  1, -3,  1, -3,  3,  2,  3,  2,  1,  0,  1, -3, -1,
	1,  0,  0,  2,  2,  2,  1,  2,  3,  1,  1,  2,  0, -1,  0,
	0, -3,  3, -1, -2, -1, -1, -1,  1,  3, -3,  0, -1, -2, -2,
	1, -2, -2, -1,  3, -2, -3,  1,  3, -3,  2,  1,  3, -2,  2,
	3, -3,  2,  0,  2, -1,  3,  0, -3, -2,  3, -2, -2, -2,  2,
	-1, -3, -1,  3,  0, -1,  1,  1, -1, -1, -3,  0,  0, -3, -3,
	-2,  3,  3, -1,  3,  2,  2, -1, -3,  2, -1, -3,  2,  3, -2,
	// Bias 2
	-2,  1,  2,  2, -3, -2,  0, -1, -1, -3,  2, -1,  1,  0, -3,
	// Mat 3
	-1,  1, -1,  2,  2, -1,  0,  2, -1,  3,  3,  0, -1,  1, -1,
	3,  3,  1,  3, -1, -3,  2,  0, -1,  3,  2, -3,  2, -2,  0,
	3,  1,  3,  2,  1,  3,  3,  3, -2, -1, -2, -1, -2, -3,  1,
	-1, -3, -2, -2,  0,  0, -1,  3, -3,  1, -1, -1, -2,  0,  0,
	1, -2,  0,  2, -3, -1,  2,  3, -1,  3, -1, -2,  1, -2,  2,
	0, -3, -3,  1,  0, -2, -2,  0, -1, -3, -2, -3, -1, -3, -2,
	2, -2, -3,  2,  3, -1, -3,  3,  0, -3, -1,  0, -1, -2,  3,
	3,  1, -3,  2,  0, -1, -3, -1,  3, -1, -3, -1, -2, -3,  2,
	-3,  1, -3, -1,  1,  3, -1,  1, -3, -2,  0,  2, -1,  1, -1,
	3, -1,  1,  0, -3,  0, -1,  0,  1, -3,  0,  0,  3,  2,  1,
	0, -2, -1,  2, -2,  1, -3,  2,  3,  2, -3,  2,  3,  2, -1,
	-2, -1,  1,  1, -2, -3, -2, -2,  3, -1,  1,  0, -1, -2, -3,
	-2,  2,  2,  3, -3,  1,  0,  1, -3,  2, -3, -3,  1,  3,  0,
	1, -1,  2, -2, -2,  2,  2,  1,  3, -2, -2, -3, -2,  1,  2,
	1,  2,  3,  3, -2,  1,  1,  1,  0,  1,  1, -2,  3, -3,  2,
	// Bias 3
	3, -1, -1, -2, -1,  0,  0, -2, -3, -1,  2, -2,  0, -3,  3,
	// Mat 4
	2,
	0,
	-1,
	0,
	3,
	3,
	0,
	0,
	3,
	1,
	2,
	1,
	0,
	-2,
	1,
	// Bias 4
	-2
	};

	int input_vec[MAX_INPUT_SIZE] = //USER EDIT, make sure input_len = rows[0] 
	{
	//input
		1, 2, 3, 2, 3, 1, 0, 1, 2, 3,
		1, 2, 3, 1, 0, 2, 3, 1, 2, 3,
		3, 0, 1, 3, 1, 2, 2, 3, 0, 1
	};

int main()
{
	int result = -2;

    if (USE_ACCEL) {
		int MEM[MEM_SIZE]; //USER EDIT
		if (DEBUG) {
			for (int i = 0 ; i < MEM_SIZE ; i++) //isn't required but good for debug
				MEM[i] = 0;
		}
		int mem_add = (int)MEM;
		//Debug line
		if (DEBUG)
			WRITE_REG((uint32_t*)(CR_MUL_IN_DATA), mem_add);

		if(init_accel_core(mats_and_bias , rows , cols, &mem_add) == FAIL)
			return FAIL;
		
		if (!ONLY_INIT) {
			result = calc_network(input_vec) ;
		}
	}
	else {
		int output_vec[MAX_INPUT_SIZE];
		if(!ONLY_INIT) {
			int temp_res = 0;
			int mat_offset = 0;
			for (int k = 0 ; k < NUM_OF_MATS ; k++) { //for each matrix
				for (int j = 0 ; j < cols[k] ; j++)  {//each col
					temp_res = mats_and_bias[mat_offset + rows[k] * cols[k] + j];
					for (int i = 0 ; i < rows[k] ; i++ ) { //sums all the rows + bias
						temp_res += input_vec[i] * mats_and_bias[mat_offset + i * cols[k] + j];
					}
					if (temp_res > 127)
						output_vec[j] = 127;
					else if (temp_res < -128)
						output_vec[j] = -128;
					else 
						output_vec[j] = temp_res;
				}
				if (k != NUM_OF_MATS - 1) {
					mat_offset += (rows[k] + 1) * cols[k];
					for (int j = 0 ; j < cols[k] ; j++)  {//each col
						input_vec[j] = (output_vec[j] > 0) ? output_vec[j] : 0;
					}
				}
			}
			result = output_vec[0];
		}
	}
	WRITE_REG((uint32_t*)(CR_MUL_IN_DATA), result);
	result = sigmoid_func(result);
	WRITE_REG((uint32_t*)(CR_MUL_IN_DATA), result);
    return 0;
}