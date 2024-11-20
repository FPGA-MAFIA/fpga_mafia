#include "accel_funcs.h"
#define ONLY_INIT 0 
#define USE_ACCEL 1 
#define DEBUG 0

/** TO USE THE ACCEL_CORE:
 * define values: NUM_OF_MATS ; MEM_SIZE
 * inputs: rows[], cols[], mats_and_bias[], input vector[]
 * 
 */

/*this is how the user insert the matrices*/
	int rows[NUM_OF_MATS] = {2 , 2 , 4};/*USER EDIT*/
	int cols[NUM_OF_MATS] = {2 , 4 , 5};/*USER EDIT*/
	int mats_and_bias[] = /*USER EDIT*/
	{
	/* Matrix Number 0 */
	1, 2,
	3, 4,
	//bias
	5, 6,

	/* Matrix Number 1 */
	1, 2, 3, 3,
	4, 5, 6, 6,
	//bias
	7, 8 ,9, 9,

	/* Matrix Number 1 */
	1, 2, 3, 4, 5,
	6, 7, 8 ,9 ,10,
	11,12,13,14,15,
	17,18,19,20,21,
	//bias
	22,23,24,25,26
	};

	int input_vec[MAX_INPUT_SIZE] = //USER EDIT, make sure input_len = rows[0] 
	{
	//input
	1, 2
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
			for (int j = 0 ; j < cols[k] ; j++)  {//each col
				input_vec[j] = (output_vec[j] > 0) ? output_vec[j] : 0;
			}
		}
		result = output_vec[0];
	}
	WRITE_REG((uint32_t*)(CR_MUL_IN_DATA), (int)(&result));
	WRITE_REG((uint32_t*)(CR_MUL_IN_DATA), result);
	result = sigmoid_func(result);
	WRITE_REG((uint32_t*)(CR_MUL_IN_DATA), result);
    return 0;
}