#include "accel_core_defines.h"
#define SUCCESS 1
#define FAIL 0 
int wait_for_buffer(int w_idx, uint32_t** data_address, uint32_t** meta_address);
/*
int main(){
    // vec input 3
    // matrix 3x6
    // bias 6
    // while not in use - W1 -> W2 -> W3 -> W1
    int x = 0x04030201; // input vec
    uint32_t* address = (uint32_t*)(CR_MUL_IN_META + 1);
    WRITE_REG(address, x);

    address = (uint32_t*)CR_MUL_IN_META; // input metadata
    uint32_t my_var = (1 << 16) | (3 << 8) | 6;
    WRITE_REG(address, my_var);
    uint32_t* data_address;
    uint32_t* meta_address;
    

    //
    int w_meta;
    do
    {
        READ_REG(w_meta, (uint32_t*)(CR_MUL_IN_META));
    } while (!(w_meta & (1 << 16))); // while the 16th bit is 0
    int w1_1 = 0x04030201;
    WRITE_REG((uint32_t*)(CR_MUL_IN_META) , w1_1);
    WRITE_REG((uint32_t*)(CR_MUL_W1_DATA),meta_to_write);
    int w2_1 = 0x08070605;
    int w3_1 = 0x0C0B0A09;
    int w1_2 = 0x100F0E0D;
    int w2_2 = w1_1;
    int w3_2 = w2_2;
    int w_arr[6] = {w1_1, w2_1, w3_1, w1_2, w2_2, w3_2};
    for (int i = 0; i < 6; i++) // 2 times
    {
            meta_to_write = i | meta_to_write; 
            wait_for_buffer(i%3+1, &data_address, &meta_address);
            WRITE_REG((data_address), w_arr[i]);
            WRITE_REG((meta_address),meta_to_write);
    }
    // Create a pointer to the variable
    return 0;
}

int wait_for_buffer(int w_idx, uint32_t** data_address,  uint32_t** meta_address){
    int w_meta = 0;
    switch (w_idx) {
        case 0:
            *meta_address = (uint32_t*)(CR_MUL_IN_META);
            *data_address = (uint32_t*)(CR_MUL_IN_DATA);
            break;
        case 1:
            *meta_address = (uint32_t*)(CR_MUL_W1_META);
            *data_address = (uint32_t*)(CR_MUL_W1_DATA);
            break;
        case 2:
            *meta_address = (uint32_t*)(CR_MUL_W2_META);
            *data_address = (uint32_t*)(CR_MUL_W2_DATA);
            break;
        case 3:
            *meta_address = (uint32_t*)(CR_MUL_W3_META);
            *data_address = (uint32_t*)(CR_MUL_W3_DATA);
            break;
        default:
            return FAIL;
    
    }
    do
    {
        READ_REG(w_meta, *meta_address);
    } while (!(w_meta & (1 << 16))); // while the 16th bit is 0
    return SUCCESS;

    
}
*/

int main () {
    int read_buff;
    int inp_vec = 0x04030201;
    int w_meta;
    int inp_meta;
    int w1_1 = 0x02010201;
    int w2_1 = 0x03020302;
    int w3_1 = 0x04030403;
    int w1_2 = 0x05040504;
    int w2_2 = 0x06050605;
    int w3_2 = 0x07060706;

    //MAT num 1
        

        inp_meta = (1 << 16) + (2 << 8) + 3; //mat 2x3
        w_meta =  (1 << 16) + (3 << 8) + 0; //2 + 1 elem each row
        //write inp
        do
        {
            READ_REG(read_buff, (uint32_t*)(CR_MUL_IN_META));
        } while ((read_buff & (1 << 16))); // while the 16th bit is 1
        WRITE_REG((uint32_t*)(CR_MUL_IN_DATA), inp_vec);
        WRITE_REG((uint32_t*)(CR_MUL_IN_META) , inp_meta);

        //write w1
        do
        {
            READ_REG(read_buff, (uint32_t*)(CR_MUL_W1_META));
        } while ((read_buff & (1 << 16))); // while the 16th bit is 1
        WRITE_REG((uint32_t*)(CR_MUL_W1_DATA), w1_1);
        WRITE_REG((uint32_t*)(CR_MUL_W1_META) , w_meta);
        
        //write w2
        do
        {
            READ_REG(read_buff, (uint32_t*)(CR_MUL_W2_META));
        } while ((read_buff & (1 << 16))); // while the 16th bit is 1
        WRITE_REG((uint32_t*)(CR_MUL_W2_DATA), w2_1);
        WRITE_REG((uint32_t*)(CR_MUL_W2_META) ,  w_meta + 1);
        
        //write w3
        do
        {
            READ_REG(read_buff, (uint32_t*)(CR_MUL_W3_META));
        } while ((read_buff & (1 << 16))); // while the 16th bit is 1
        WRITE_REG((uint32_t*)(CR_MUL_W3_DATA), w3_1);
        WRITE_REG((uint32_t*)(CR_MUL_W3_META) ,  w_meta + 2);
        
        //wait for don
        do
        {
            READ_REG(read_buff, (uint32_t*)(CR_MUL_IN_META));
        } while (!(read_buff & (1 << 16))); // while the 16th bit is 1

    //MAT num 2
        inp_meta = (1 << 16) + (3 << 8) + 6; //mat 3x6
        w_meta =  (1 << 16) + (4 << 8) + 0; //3 + 1 elem each row
        //write inp
        do
        {
            READ_REG(read_buff, (uint32_t*)(CR_MUL_IN_META));
        } while ((read_buff & (1 << 16))); // while the 16th bit is 1
        WRITE_REG((uint32_t*)(CR_MUL_IN_META) , inp_meta);

        //write w1
        do
        {
            READ_REG(read_buff, (uint32_t*)(CR_MUL_W1_META));
        } while ((read_buff & (1 << 16))); // while the 16th bit is 1
        WRITE_REG((uint32_t*)(CR_MUL_W1_DATA), w1_1);
        WRITE_REG((uint32_t*)(CR_MUL_W1_META) , w_meta);
        
        //write w2
        do
        {
            READ_REG(read_buff, (uint32_t*)(CR_MUL_W2_META));
        } while ((read_buff & (1 << 16))); // while the 16th bit is 1
        WRITE_REG((uint32_t*)(CR_MUL_W2_DATA), w2_1);
        WRITE_REG((uint32_t*)(CR_MUL_W2_META) ,  w_meta + 1);
        
        //write w3
        do
        {
            READ_REG(read_buff, (uint32_t*)(CR_MUL_W3_META));
        } while ((read_buff & (1 << 16))); // while the 16th bit is 1
        WRITE_REG((uint32_t*)(CR_MUL_W3_DATA), w3_1);
        WRITE_REG((uint32_t*)(CR_MUL_W3_META) ,  w_meta + 2);
        
        //write w1
        do
        {
            READ_REG(read_buff, (uint32_t*)(CR_MUL_W1_META));
        } while ((read_buff & (1 << 16))); // while the 16th bit is 1
        WRITE_REG((uint32_t*)(CR_MUL_W1_DATA), w1_2);
        WRITE_REG((uint32_t*)(CR_MUL_W1_META) , w_meta + 3);

        //write w2
        do
        {
            READ_REG(read_buff, (uint32_t*)(CR_MUL_W2_META));
        } while ((read_buff & (1 << 16))); // while the 16th bit is 1
        WRITE_REG((uint32_t*)(CR_MUL_W2_DATA), w2_2);
        WRITE_REG((uint32_t*)(CR_MUL_W2_META) ,  w_meta + 4);
        
        //write w3
        do
        {
            READ_REG(read_buff, (uint32_t*)(CR_MUL_W3_META));
        } while ((read_buff & (1 << 16))); // while the 16th bit is 1
        WRITE_REG((uint32_t*)(CR_MUL_W3_DATA), w3_2);
        WRITE_REG((uint32_t*)(CR_MUL_W3_META) ,  w_meta + 5);
        
        //write inp
        do
        {
            READ_REG(read_buff, (uint32_t*)(CR_MUL_IN_META));
        } while (!(read_buff & (1 << 16))); // while the 16th bit is 1
        
    for (int i = 0; i < 3; i++)
    {
    }
    return 0;
}