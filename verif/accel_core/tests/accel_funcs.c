// Define uint32_t as unsigned int
#define SUCCESS 1
#define FAIL 0 
#include "accel_core_defines.h"
uint32_t *address = (uint32_t *)0x00FE0200;
typedef struct {
    int words_in_row;
    int rows_num;
    int elem_in_row;
    int** p_trans_1D_mat_and_bias;
} t_matrix_accel;
/*
mat=    
    [1 2 3 4 5 6 7
     8 9 0 1 2 3 4
     5 6 7 8 9 0 1 
     2 3 4 5 6 7 8 
     9 0 1 2 3 4 5]
bias = 
    [1 2 3 4 5 6 7]
trans_mat =
    [1852 9100
     2963 0200
     3074 1300
     ...]
words in row = 2; (ceil(rows + 1 /4))
elem in row = rows + 1;
rows = cols
*/
t_matrix_accel* transposed_mat_array;

int xor_accel(int x, int y) {
    int result = 0;
    WRITE_REG(address,x);
    WRITE_REG((address+1), y);
    READ_REG(result,(address+2));
    return result;
}

/**
 * @brief - takes a matrix and sets it up so it will be supported by the accel farm. 
 *          Notes: Matrix is transposed, each 4 weights are compressed to one word, bias
 *                 is at the end the matrix.
 * @param mat - a pointer to the matrix
 * @param row - num of rows
 * @param col -num of cols
 * @param bias - each layer computes U = Av + B. A is the weights matrix and B is the
 *               bias element.
 * @return  Null if failed, a pointer on succes
 *          the user is responsible to free the alocated mem
 */
int** mat_set(int** mat, int row, int col, int* bias) 
{

}

/**
 * @brief - write buffer, write to input, w1, w2 or w3
 * @param w_idx - the index of the buffer to be written (0,1, 2, 3)
 * @param data  - data to be written to buffer (matrix combined to an rray)
 * @param words_num - the number of words to be written to the buffer
 * @return - 0 if failed, 1 on success
 * @note - this function is not reposible to check if the buffer is free
 */
int buffer_write(int w_idx, int* data, int row, int words_in_row)
{
    uint32_t* address;
    switch (w_idx) {
        case 0:
            address = (uint32_t*)(CR_MUL_IN_META + 1);
            break;
        case 1:
            address = (uint32_t*)(CR_MUL_W1_META + 1);
            break;
        case 2:
            address = (uint32_t*)(CR_MUL_W2_META + 1);
            break;
        case 3:
            address = (uint32_t*)(CR_MUL_W3_META + 1);
            break;
        default:
            printf("Default case: Action for unknown w_idx\n");
            return FAIL;
    
    }
    for(int i=0; i<words_in_row; i++)
        WRITE_REG((uint32_t*)(address + i), data[row*words_in_row + i]);
    return SUCCESS;
}

/**
 * @brief - Calculates a layer of a neural network by computing Av + B.
 *          A is the weights matrix and B is the bias vector.
 *          ouput of the network then passes through a sigmoid activation function!
 * @param input_vec - the vector that contains the input of the network
 * @param mat_A  - weight matrix of the network. A column is a single neuron. 
 * @param vec_B  - weight matrix of the network. A column is a single neuron. 

 * @return - 0 if failed, 1 on success
 */
int calc_layer(int* input_vec, int* mat_A, int* vec_B)
{
    
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
int init_accel_core(int num_of_mats, int** mat_array int* rows, int* cols , int **bias)
{
    /*args check*/

    /*allcate mem in global*/
    

    /*insert mats*/
    for (int i =0 ; i < num_of_mats , i ++) {
        if (!insert_mat(mat_array[i] , rows[i] , cols[i], i)) {
            //free everything
            return FAIL;
        } 
    }
    return SUCCESS;
}


// Fucntion to transpose a matrix
int* transpose_matrix(int* mat, int rows, int cols) {
    int* transposed = (int*)malloc(cols * rows * sizeof(int));
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            transposed[j * rows + i] = mat[i * cols + j];
        }
    }
    
    return transposed;
}

// Function to compress the transposed matrix with bias and padding
int* compress_matrix(int* mat, int* bias, int rows, int cols) {
    int elements_per_row = cols + 1;  // Adding the bias as the extra element
    int words_in_row = (int)ceil((double)elements_per_row / 4);  // Number of 32-bit words per row
    int* compressed_mat = (int*)malloc(rows * words_in_row * sizeof(int));

    // Compress each row
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < words_in_row; j++) {
            int combined_value = 0;

            // Combine up to 4 elements from the matrix, bias, and padding
            for (int k = 0; k < 4; k++) {
                int idx = 4 * j + k;
                if (idx < cols) {
                    combined_value |= (mat[i * cols + idx] << (8 * (3 - k)));  // Add matrix element
                } else if (idx == cols) {
                    combined_value |= (bias[i] << (8 * (3 - k)));  // Add bias element after the last matrix element
                }
            }

            compressed_mat[i * words_in_row + j] = combined_value;  // Store the combined value
        }
    }

    return compressed_mat;
}

int insert_mat(int* mat , int rows ,int cols ,int* bias, int mat_idx) {
    int* mat_transposed = transpose_matrix(mat, rows, cols);
    int* mat_compressed = compress_matrix(mat_transposed, bias, cols, rows);
} 


