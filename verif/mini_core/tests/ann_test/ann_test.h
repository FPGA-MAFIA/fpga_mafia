#ifndef ANN_TEST_H
#define ANN_TEST_H

int Step_func(int x);

int Relu_func(int x);

/**
 * @brief sigmoid with 2^5 scaling 
 * y = 1 / (1 + exp (- x / 32))
 * @param x = 2^5 * wanted input because of scaling
 * @return 100 * y val in percentage
 */
int sigmoid_func_scaled32(int x);

/**
 * @brief calc one of the neuro in the next 
 * @param prevL : last layeers values
 * @param prevL_len last layer size
 * @param weights pointer to the table of weights
 * @param out_neuro_idx the index of the neuron we want to calc.
 * @result 
 */
int neuron_calc(int* prevL , int prevL_len , int weights[][6] , int bias[] , int out_neuro_idx);

int score_calc(int* prevL , int prevL_len , int *weights , int bias , int SRA);


void layer_calc (int* prevL , int prevL_len , int *nextL , int nextL_len , int weights[][6] , int *bias);

#endif /*ANN_TEST_H*/
