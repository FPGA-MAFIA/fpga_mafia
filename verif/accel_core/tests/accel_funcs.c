// Define uint32_t as unsigned int
#define SUCCESS 1
#define FAIL 0 
#include "accel_core_defines.h"
#include <stdlib.h>

uint32_t *address = (uint32_t *)0x00FE0200;
typedef struct {
    int words_in_row;
    int rows_num; // TRANSPOSED
    int elem_in_row;
    int** p_accel_mat; //pointer to 1D array mat
} t_matrix_accel;
int g_num_of_mats;
t_matrix_accel* accel_mat_vec;

int xor_accel(int x, int y) {
    int result = 0;
    WRITE_REG(address,x);
    WRITE_REG((address+1), y);
    READ_REG(result,(address+2));
    return result;
}



/////////////////////////////// INIT ////////////////////////////////////////////
/**
 * @brief - copy the matrix
 * @param mat - flat 1D array matrix
 * @param rows - number of rows in mat
 * @param cols - number of columns in mat
 * @param output - pointer to the copied matrix
 * @return SUCCESS or FAIL
 */
int copy_matrix(int *mat, int rows, int cols, int** output) {
    if (!output || !mat || rows <= 0 || cols <= 0)
        return FAIL;

    // Allocate memory for the new matrix
    *output = (int*)malloc(rows * cols * sizeof(int));
    if (*output == NULL) {
        return FAIL; // Memory allocation failed
    }

    // Copy the matrix data
    for (int i = 0; i < rows * cols; i++) {
        (*output)[i] = mat[i];
    }

    return SUCCESS;
}

/**
 * @brief - transpose the matrix
 * @param mat - the matrix (assumed to be a flat 1D array)
 * @param rows - number of rows in mat
 * @param cols - number of columns in mat
 * @return SUCCESS or FAIL
 */
int transpose_mat(int *mat, int rows, int cols) {
    // Check for valid input
    if (mat == NULL || rows <= 0 || cols <= 0) {
        return FAIL;
    }

    int transposed[cols][rows];  // Temporary array to hold transposed matrix

    // Transpose the matrix
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            transposed[j][i] = mat[i * cols + j];
        }
    }

    // Copy transposed matrix back into original matrix (1D form)
    for (int i = 0; i < cols; i++) {
        for (int j = 0; j < rows; j++) {
            mat[i * rows + j] = transposed[i][j];
        }
    }

    return SUCCESS;
}

/**
 * @brief - insert vec as col to the right
 * @param p_mat - pointer to the matrix (assumed to be a flat 1D array)
 * @param rows - number of rows in mat
 * @param cols - number of columns in mat
 * @param vec - vector that has "rows" elements
 * @return SUCCESS or FAIL
 */
int insert_col(int **p_mat, int rows, int cols, int* vec) {
    if (!p_mat || !(*p_mat) || !vec)
        return FAIL;

    int* mat = *p_mat;
    // Allocate space for the new matrix with one more column
    int* new_mat = (int*)malloc(rows * (cols + 1) * sizeof(int));
    if (new_mat == NULL) {
        return FAIL; // Memory allocation failure
    }

    // Copy the old matrix and insert vec as the last column
    for (int i = 0; i < rows; i++) {
        // Copy the current row from old matrix
        for (int j = 0; j < cols; j++) {
            new_mat[i * (cols + 1) + j] = mat[i * cols + j];
        }
        // Insert the new column (vec)
        new_mat[i * (cols + 1) + cols] = vec[i];
    }

    // Replace the old matrix with the new one (you might want to return or update the original pointer)
    free(*p_mat); // Free old matrix memory
    *p_mat = new_mat;

    return SUCCESS;
}

/**
 * @brief - treats each element as int 8,
            for each row: compress four elements to one. if the number of
            element isn't divisable by 4 complete with 0's
 * @param p_mat - pointer to the matrix (assumed to be a flat 1D array)
 * @param rows - number of rows in mat
 * @param cols - number of columns in mat
 * @return SUCCESS or FAIL
 */

int compress_mat(int** p_mat, int rows, int cols) {
    if (!p_mat || !(*p_mat))
        return FAIL;

    int* mat = *p_mat;
    // Calculate new number of columns (each 4 int8s -> 1 int32)
    int new_cols = (cols + 3) / 4; // Equivalent to ceil(cols / 4.0)

    // Allocate space for the compressed matrix
    int *compressed_mat = (int*)malloc(rows * new_cols * sizeof(int));
    if (compressed_mat == NULL) {
        return FAIL; // Memory allocation failure
    }

    // Compress the matrix row by row
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < new_cols; j++) {
            // Pack up to 4 int8 elements into a single int32
            int packed = 0;
            for (int k = 0; k < 4; k++) {
                int col_idx = j * 4 + k;
                if (col_idx < cols) {
                    packed |= (mat[i * cols + col_idx] & 0xFF) << (k * 8);
                }
            }
            compressed_mat[i * new_cols + j] = packed;
        }
    }

    // Replace the original matrix with the compressed matrix
    free(*p_mat);
    *p_mat = compressed_mat;

    return SUCCESS;
}

/**
 * @brief - Initiates layer of a neural network. Sets a set of A matrices and
 *          B vectors in the core's memory.
 *          A is the weights matrix and B is the bias vector.
 * @param mat_array  - array of weight matrices. The i'th matrix is the weights matrix of
 *                      the i'th layer of the network. A column is a single neuron. 
 *                      each weight matrix consists of int* mat, 
 * @param vec_B  - weight matrix of the network. A column is a single neuron. 

 * @return - 0 if failed, 1 on success
 */
int init_accel_core(int** mat_array , int* rows, int* cols, int num_of_mats, int **bias_array)
{
    g_num_of_mats = num_of_mats;
    /*args check*/
    if (!mat_array || !rows || !cols || !bias_array) { //invalid input null pointer
        return FAIL; // Invalid input
    }

    for (int i = 0 ; i < num_of_mats ; i++) { //invalid matrix
        if (!(mat_array[i]) || !(bias_array[i]) || (rows[i] <= 0) || (cols[i] <= 0))
            return FAIL;
    }

    for (int i = 0 ; i < num_of_mats - 1; i++) { //matrix size doesnt match
        if (cols[i] != rows[i+1])
            return FAIL;
    }

    /*allocating mem*/
    accel_mat_vec = (t_matrix_accel*)malloc(num_of_mats * sizeof(t_matrix_accel));
    for (int i = 0 ; i < num_of_mats ; i++) {
        accel_mat_vec[i].p_accel_mat = 
        (int**)malloc(sizeof(int**));
    }

    /*insert the matricses*/
    for (int i = 0 ; i < num_of_mats ; i++) {
        int row = rows[i];
        int col = cols[i];
        copy_matrix(mat_array[i] , row, col, accel_mat_vec[i].p_accel_mat);
        transpose_mat(*(accel_mat_vec[i].p_accel_mat) , row , col);
        row = cols[i];
        col = rows[i];
        insert_col(accel_mat_vec[i].p_accel_mat , row , col , bias_array[i]) ;
        col = col + 1;
        compress_mat(accel_mat_vec[i].p_accel_mat , row , col);
        accel_mat_vec[i].words_in_row = (col + 3) / 4; //ceil (col /4)
        accel_mat_vec[i].elem_in_row = col;
        accel_mat_vec[i].rows_num = row;
    }

    return SUCCESS;
}

///////////////////////////// CLEANUP ////////////////////////////////////////
/**
 * @brief - free the strucrt
 */
 void cleanup(int num_of_mats) {
    if (!accel_mat_vec) return; // Check if accel_mat_vec is already NULL

    for (int i = 0; i < num_of_mats; i++) {
        if (accel_mat_vec[i].p_accel_mat) {
            free(*(accel_mat_vec[i].p_accel_mat)); // Free the matrix data (1D array)
            free(accel_mat_vec[i].p_accel_mat);    // Free the pointer to the matrix
        }
    }

    free(accel_mat_vec); // Free the accel_mat_vec array itself
    accel_mat_vec = NULL; // Set to NULL to avoid dangling pointers
 }


//////////////////////////// PROCCESS ////////////////////////////////////////
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
    int words_num = accel_mat_vec[matrix_idx].words_in_row;
    int* data = (*accel_mat_vec[matrix_idx].p_accel_mat) + words_num*neuron_idx;
    for(int i=0; i<words_num; i++)
        WRITE_REG((uint32_t*)(address + i + 1), data[i]);
    int w_metadata = neuron_idx + (accel_mat_vec[matrix_idx].elem_in_row << 8) + (1 << 16);
    // write the metadata
    WRITE_REG((uint32_t*)address, w_metadata);       
    return SUCCESS;
}



/**
 * @brief - Calculates a layer of a neural network by computing Av + B.
 *          A is the weights matrix and B is the bias vector.
 *          ouput of the network then passes through a sigmoid activation function!
 * @param idx - the index of the layer to calculate
 * @return - 0 if failed, 1 on success
 */
int calc_layer(int matrix_idx)
{
    //if(matrix_idx<0 || matrix_idx >= g_num_of_mats)
    //    return FAIL;

    // wait for previous layer to be completed
    int read_buff;
    do
    {
        READ_REG(read_buff, (uint32_t*)(CR_MUL_IN_META));
    } while ((read_buff & (1 << 16))); // while the 16th bit is 1
    //Write metadata of input vector
    int input_meta = (accel_mat_vec[matrix_idx].rows_num) + ((accel_mat_vec[matrix_idx].elem_in_row-1) << 8) + (1 << 16);
    WRITE_REG((uint32_t*)(CR_MUL_IN_META), input_meta);
    // Write data to buffers
    t_matrix_accel curr_mat = accel_mat_vec[matrix_idx];
    for (int i = 0; i < curr_mat.rows_num; i++)
    {
        if(buffer_write(i, matrix_idx) == FAIL)
            return FAIL;
    }
    return SUCCESS;
}


/**
 * @brief - Calculates the entire network output of a neural network
 * @param input_vec - the vector that contains the input of the network.
 * @param input_vec_len - the length of the input vec
 * @return - a number between 0 and 100 (100 times the output of the sigmoid). -1 on fail
 */ 
int calc_network(int* input_vec, int input_vec_len)
{
    //args check
    if(!input_vec || input_vec_len != accel_mat_vec[0].elem_in_row - 1)
        return -1;
    int read_buff;
    // wait for accel to be free
    do
    {
        READ_REG(read_buff, (uint32_t*)(CR_MUL_IN_META));
    } while ((read_buff & (1 << 16))); // while the 16th bit is 1
    //parse input vector
    int** p_input_vec; // FREE THIS!
    copy_matrix(input_vec, 1, input_vec_len, p_input_vec);
    if(!compress_mat(p_input_vec, 1, input_vec_len))
        return -1;
    int words_in_compressed_inp = ( input_vec_len + 3) / 4;
    // load input vec to cr space
    for (int i = 0; i < words_in_compressed_inp; i++)
    {
        WRITE_REG((uint32_t*)(CR_MUL_IN_DATA+i), *p_input_vec[i]);
    }
    // calc layer for each layer
    for (int i = 0; i < g_num_of_mats; i++)
    {
        calc_layer(i);
    }
    free(*p_input_vec);
    int result;
    //read network result
    READ_REG(result, (uint32_t*)(CR_MUL_OUT_META+1));
    //sigmoid(&result);
    return result;
}