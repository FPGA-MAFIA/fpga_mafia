#include "accel_funcs.h"

/** TO USE THE ACCEL_CORE:
 * define values: NUM_OF_MATS ; NUM_OF_INPUTS ; MEM_SIZE
 * inputs: rows[], cols[], mats_and_bias[], input vector[]
 * 
 */



int main()
{
    /**this is how the user insert the matrices**/
	int rows[NUM_OF_MATS] = {2};/*USER EDIT*/
	int cols[NUM_OF_MATS] = {2};/*USER EDIT*/
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
	
    int input_vec[] = //USER EDIT, make sure input_len = rows[0] 
        {
            //input
            1, 5
        };


	int MEM[MEM_SIZE]; //USER EDIT
	
    for (int i = 0 ; i < MEM_SIZE ; i++) //isn't required but good for debug
        MEM[i] = 0;
    int mem_add = (int)MEM;
	//Debug line
		WRITE_REG((uint32_t*)(CR_MUL_IN_DATA), mem_add);

	if(init_accel_core(mats_and_bias , rows , cols, &mem_add) == FAIL)
        return FAIL;
	
	int result = -2;
	for (int i = 0 ; i < NUM_OF_INPUTS ; i++) {
		result = calc_network(input_vec + i * rows[0]);
		
		result = sigmoid_func(result);
	}
	
    return 0;
}