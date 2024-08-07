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
    parameter CR_SEG7_0      = CR_MEM_OFFSET + 'h0  ; // RW 8 bit
    parameter CR_SEG7_1      = CR_MEM_OFFSET + 'h4  ; // RW 8 bit
    parameter CR_SEG7_2      = CR_MEM_OFFSET + 'h8  ; // RW 8 bit
    parameter CR_SEG7_3      = CR_MEM_OFFSET + 'hC  ; // RW 8 bit
    parameter CR_SEG7_4      = CR_MEM_OFFSET + 'h10 ; // RW 8 bit
    parameter CR_SEG7_5      = CR_MEM_OFFSET + 'h14 ; // RW 8 bit

    typedef struct packed {
        logic [7:0] SEG7_0;
        logic [7:0] SEG7_1;
        logic [7:0] SEG7_2;
        logic [7:0] SEG7_3;
        logic [7:0] SEG7_4;
        logic [7:0] SEG7_5;
    } t_cr;

    /****************************************ACCELERATORS*******************************/
    parameter WIDTH = 8;
    typedef struct packed {
        logic [2*WIDTH:0] AQQ_0;
        logic [WIDTH-1:0] Mu;
    } stage_mul_inp_t;

endpackage
