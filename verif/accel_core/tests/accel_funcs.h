#ifndef ACCEL_FUNCS_H
#define ACCEL_FUNCS_H

#include "accel_core_defines.h"

#define SUCCESS 0
#define FAIL 1
#define NUM_OF_MATS 1 /*USER EDIT*/
#define NUM_OF_INPUTS 1 /*USER EDIT, needs to be edited as well in the defines*/
#define MEM_SIZE 10	/*USER EDIT*/


/* this is Imaginary struct, this the way it is arranged in the memory
typedef struct {
    int words_in_row; //struct addr
    int rows_num;     //struct addr + 4
    int elem_in_row;  //struct addr + 8
    int*accel_mat;    //struct addr + c and on
} t_matrix_accel;
*/

enum {
    WORDS_IN_ROW = 0,
    ROW_NUM,
    ELEM_IN_ROW,
    MAT
};

/**
 * @brief sigmoid func
 * @return -1 for invalid args, 100 * sigmoid((a - 128)/32)
 */
int sigmoid_func(int a);

/**
 * @brief - transpose the matrix without using malloc
 * @param mat - the matrix (assumed to be a flat 1D array)
 * @param rows - number of rows in mat
 * @param cols - number of columns in mat
 * @param heap_address - heap space to use grows upwards
 * @return SUCCESS or FAIL the new matrix should be assigned to param mat
 */
int transpose_mat(int *mat, int rows, int cols , int* p_heap_address);

/**
 * @brief - treats each element as int 8,
            for each row: compress four elements to one. if the number of
            element isn't divisable by 4 complete with 0's
            inserets the compressed mat to the heap and increase the pointer accordingly.
 * @param mat - pointer to the matrix (assumed to be a flat 1D array)
 * @param rows - number of rows in mat
 * @param cols - number of columns in mat
 * @param heap_address - heap space to use grows upwards
 * @return SUCCESS or FAIL
 */
int insert_compressed_mat(int* mat, int rows, int cols , int* p_heap_address);

/**
 * @brief - Initiates layer of a neural network. Sets a set of A matrices and
 *          B vectors in the core's memory.
 *          A is the weights matrix and B is the bias vector.
 * @return - 0 if failed, 1 on success
 */
int init_accel_core(int mats_and_bias[] , int rows[], int cols[], int* p_heap_address);

/**
 * @brief - Calculates the entire network output of a neural network
 * @param input_vec - the vector that contains the input of the network.
 * @return - a number between 0 and 100 (100 times the output of the sigmoid). -1 on fail
 */
int calc_network(int input_vec[]);

/**
 * @brief - write buffer, write to input, w1, w2 or w3
 * @param neuron_idx - the index of the current neuron to calculate
 * @param data  - data to be written to buffer (one row fromm the matrix)
 * @param words_num - the number of words to be written to the buffer
 * @return - 0 if failed, 1 on success
 * @note - this function is not reposible to check if the buffer is free
 */
int buffer_write(int neuron_idx, int mat_idx);

/**
 * @brief - Calculates a layer of a neural network by computing Av + B.
 *          A is the weights matrix and B is the bias vector.
 *          ouput of the network then passes through a sigmoid activation function!
 * @param idx - the index of the layer to calculate
 * @return - 0 if failed, 1 on success
 */
int calc_layer(int idx);



#endif /*ACCEL_FUNCS_H*/


int sigmoid[] = {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 
                3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
                4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5,
                5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7,
                7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9,
                9, 10, 10, 10, 10, 11, 11, 11, 12,
                12, 12, 13, 13, 13, 14, 14, 14, 15,
                15, 16, 16, 16, 17, 17, 18, 18, 19,
                19, 20, 20, 21, 21, 22, 22, 23, 23,
                24, 25, 25, 26, 26, 27, 28, 28, 29,
                29, 30, 31, 31, 32, 33, 33, 34, 35,
                36, 36, 37, 38, 38, 39, 40, 41, 41,
                42, 43, 44, 45, 45, 46, 47, 48, 48,
                49, 50, 51, 52, 52, 53, 54, 55, 55,
                56, 57, 58, 59, 59, 60, 61, 62, 62,
                63, 64, 64, 65, 66, 67, 67, 68, 69,
                69, 70, 71, 71, 72, 72, 73, 74, 74,
                75, 75, 76, 77, 77, 78, 78, 79, 79,
                80, 80, 81, 81, 82, 82, 83, 83, 84,
                84, 84, 85, 85, 86, 86, 86, 87, 87,
                87, 88, 88, 88, 89, 89, 89, 90, 90,
                90, 90, 91, 91, 91, 91, 92, 92, 92,
                92, 93, 93, 93, 93, 93, 94, 94, 94,
                94, 94, 94, 95, 95, 95, 95, 95, 95,
                96, 96, 96, 96, 96, 96, 96, 96, 96,
                97, 97, 97, 97, 97, 97, 97, 97, 97,
                97, 97, 98, 98, 98, 98, 98, 98, 98,
                98, 98, 98};

int sigmoid_func(int a) {
    if (a < -128 || a > 127) //invalid arg
        return -1;
    return sigmoid[a + 128];
}

/*
int xor_accel(int x, int y) {
    int result = 0;
    WRITE_REG(address,x);
    WRITE_REG((address+1), y);
    READ_REG(result,(address+2));
    return result;
}
*/
///////////////////////////// INIT  //////////////////////////////////////////

int g_mats_base_addr[NUM_OF_MATS + 1];
    
int transpose_mat(int *mat, int rows, int cols , int* p_heap_address) {
    int curr_idx , new_idx;
    for (int i = 0 ; i < rows ; i++) {
        for (int j = 0 ; j < cols ; j++) {
            curr_idx = i * cols + j;
            new_idx = j * rows + i;
            WRITE_REG((uint32_t*)(*p_heap_address + 4 * new_idx) , mat[curr_idx]);
        }
    }
    int temp_heap_addr = *p_heap_address ;
    for (int i = 0 ; i < rows * cols ; i++) {
        READ_REG(mat[i], (uint32_t*)(temp_heap_addr));
        temp_heap_addr += 4;
    }
    return 0;
}

int insert_compressed_mat(int* mat, int rows, int cols , int* p_heap_address) {
    int words_in_row = ((rows + 1) + 3) / 4;  //ceil (rows + 1) / 4
    WRITE_REG((uint32_t*)(*p_heap_address), words_in_row);
    *p_heap_address += 4;

    int rows_num = cols;
    WRITE_REG((uint32_t*)(*p_heap_address), rows_num);
    *p_heap_address += 4;

    int elem_in_row = rows + 1;  //struct addr + 8
    WRITE_REG((uint32_t*)(*p_heap_address), elem_in_row);
    *p_heap_address += 4;

    for (int i = 0; i < rows_num; i++) {
        for (int j = 0; j < words_in_row; j++) {
            // Pack up to 4 int8 elements into a single int32
            int packed = 0;
            for (int k = 0; k < 4; k++) {
                int idx =   i* elem_in_row +    //elements in prev rows
                            4* j +              //elem in prev words in the row
                            k;                  //idx in word
                if (4* j + k < elem_in_row) { //row offset too large
                    packed |= (mat[idx] & 0xFF) << (k * 8);
                }
            }
            WRITE_REG((uint32_t*)(*p_heap_address), packed);
            *p_heap_address += 4;
        }
    }
    return SUCCESS;
}

int init_accel_core(int mats_and_bias[],
                    int rows[],
                    int cols[],
                    int* p_heap_address) {
    /*args check*/

    int heap_add_base = *p_heap_address;
    if (!mats_and_bias || !rows || !cols) { //invalid input null pointer
        return FAIL; // Invalid input
    }

    for (int i = 0 ; i < NUM_OF_MATS ; i++) { //invalid matrix
        if ((rows[i] <= 0) || (cols[i] <= 0)) {
            return FAIL;
        }
    }

    for (int i = 0 ; i < NUM_OF_MATS - 1; i++) { //matrix size doesn't match
        if (cols[i] != rows[i+1]) {
            return FAIL;
        }
    }

    /*transpose the matricses*/
    int curr_offset = 0;
    for (int i = 0 ; i < NUM_OF_MATS ; i++) {
        transpose_mat(mats_and_bias + curr_offset , rows[i] + 1 , cols[i], p_heap_address);
        curr_offset += (rows[i] + 1) * cols[i];
    }

    /*insert and compress matrices*/
    curr_offset = 0;
    for (int i = 0 ; i < NUM_OF_MATS ; i++) {
        g_mats_base_addr[i] = *p_heap_address;
        insert_compressed_mat(mats_and_bias + curr_offset , rows[i], cols[i], p_heap_address);
        curr_offset += (rows[i] + 1) * cols[i];
    }
    g_mats_base_addr[NUM_OF_MATS] = *p_heap_address; //the vector
    return SUCCESS;
}

//////////////////////////// PROCCESS ////////////////////////////////////////

int calc_network(int input_vec[])
{
    //args check
    if(!input_vec)
        return -1;
        
    
    // wait for accel to be free
    int read_buff;
    do
    {
        READ_REG(read_buff, (uint32_t*)(CR_MUL_IN_META));
    } while ((read_buff & (1 << 16))); // while the 16th bit is 1

    //parse input vector
    int vec_len = (*(int*)(g_mats_base_addr[0]) + ELEM_IN_ROW) - 1;
    int vec_addr =  g_mats_base_addr[NUM_OF_MATS];
    insert_compressed_mat(input_vec, 1, vec_len , &vec_addr);

    int words_in_compressed_inp =   *((int*)(g_mats_base_addr[NUM_OF_MATS]) + 
                                    WORDS_IN_ROW);
    // load input vec to cr space
    for (int i = 0; i < words_in_compressed_inp; i++)
    {
        WRITE_REG(  (uint32_t*)(CR_MUL_IN_DATA+i), 
                    *((int*)(g_mats_base_addr[NUM_OF_MATS]) + MAT + i));
    }

    // calc layer for each layer
    for (int i = 0; i < NUM_OF_MATS; i++)
    {
        calc_layer(i);
    }
    
    int result;
    //read network result
    READ_REG(result, (uint32_t*)(CR_MUL_OUT_META+1));
    //sigmoid(&result);
    return result;
}

int calc_layer(int matrix_idx)
{
    if(matrix_idx<0 || matrix_idx >= NUM_OF_MATS)
        return FAIL;

    // wait for previous layer to be completed
    int read_buff;
    do
    {
        READ_REG(read_buff, (uint32_t*)(CR_MUL_IN_META));
    } while ((read_buff & (1 << 16))); // while the 16th bit is 1

    //The input data should be in the CR waiting for the metadata to be updated
    //Write metadata of input vector
    int input_meta = *((int*)(g_mats_base_addr[matrix_idx]) + ROW_NUM) +
                     ((*((int*)(g_mats_base_addr[matrix_idx]) + ELEM_IN_ROW) - 1) << 8) + 
                     (1 << 16);
    WRITE_REG((uint32_t*)(CR_MUL_IN_META), input_meta);
    
    // Write data to buffers
    int num_of_rows = *((int*)(g_mats_base_addr[matrix_idx]) + ROW_NUM);
    for (int i = 0 ; i < num_of_rows ; i++)
    {
        if(buffer_write(i, matrix_idx) == FAIL)
            return FAIL;
    }
    return SUCCESS;
}


/**
 * @brief - write buffer, write to input, w1, w2 or w3
 * @param neuron_idx - the index of the current neuron to calculate
 * @param matrix_idx - the idx of the matrix in the global array
 * @return - 0 if failed, 1 on success
 * @note - this function is not reposible to check if the buffer is free
 */
int buffer_write(int neuron_idx, int matrix_idx)
{
    // Decide which buffer to write to
    int w_idx = neuron_idx%3 + 1;
    int address;
    switch (w_idx) {
        case 1:
            address = (CR_MUL_W1_META);
            break;
        case 2:
            address = (CR_MUL_W2_META);
            break;
        case 3:
            address = (CR_MUL_W3_META);
            break;
        default:
            return FAIL;
    
    }
    int read_buff;
    // wait for the buffer to be free
    do
    {
        READ_REG(read_buff, (uint32_t*)(address));
    } while ((read_buff & (1 << 16))); // while the 16th bit is 1
    // write the data
    int words_num = *((int*)(g_mats_base_addr[matrix_idx]) + WORDS_IN_ROW);
    int elements_in_row = *((int*)(g_mats_base_addr[matrix_idx]) + ELEM_IN_ROW);
    int* data = (int*)(g_mats_base_addr[matrix_idx]) + 
                MAT +
                neuron_idx * words_num;
    for(int i=0; i<words_num; i++)
        WRITE_REG((uint32_t*)(address + i + 1), data[i]);
    int w_metadata = neuron_idx +
                     (elements_in_row << 8) + 
                     (1 << 16);
    // write the metadata
    WRITE_REG((uint32_t*)address, w_metadata);       
    return SUCCESS;
}
