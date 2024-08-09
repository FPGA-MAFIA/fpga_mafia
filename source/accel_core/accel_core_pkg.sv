package accel_core_pkg;

    /****************************************CR SPACE*******************************/

    // Define CR memory sizes
    parameter CR_MEM_OFFSET       = 'h00FE_0000;
    parameter CR_MEM_REGION_FLOOR = CR_MEM_OFFSET;
    parameter CR_MEM_REGION_ROOF  = 'h00FF_0000 - 1;

    // Region bits
    parameter LSB_REGION = 0;
    parameter MSB_REGION = 23;

    // CR Address Offsets

    parameter CR_0 = CR_MEM_OFFSET + 'h200 ;
    parameter CR_1 = CR_MEM_OFFSET + 'h204 ;
    parameter CR_2 = CR_MEM_OFFSET + 'h208 ;
    parameter CR_3 = CR_MEM_OFFSET + 'h20C ;
    parameter CR_4 = CR_MEM_OFFSET + 'h210 ;
    parameter CR_5 = CR_MEM_OFFSET + 'h214 ;
    parameter CR_6 = CR_MEM_OFFSET + 'h218 ;


    typedef struct packed {
        logic [7:0] xor_inp1;
        logic [7:0] xor_inp2;
        logic [7:0] xor_result;
    } t_cr;

    /****************************************ACCELERATORS*******************************/
    parameter WIDTH = 8;
    typedef struct packed {
        logic [2*WIDTH:0] AQQ_0;
        logic [WIDTH-1:0] Mu;
    } stage_mul_inp_t;

endpackage
