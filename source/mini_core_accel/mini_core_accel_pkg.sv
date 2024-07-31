//-------------------------------------
// accelerators farm package
//-------------------------------------

package mini_core_accel_pkg;

parameter  NUM_WIDTH_INT8  = 8;
typedef  logic [7:0]       int8;
typedef  logic [15:0]      int16;

typedef enum {
    PRE_START,
    COMPUTE,
    DONE          
} t_mul_int8_states;

typedef struct packed {
    int8   multiplicand;
    int8   multiplier;
}t_mul_int8_input;

typedef struct packed {
    logic done;
    int16 result;
}t_mul_int8_output;

typedef struct packed { // {multiplicand, multiplier}
    t_mul_int8_input [7:0] core2mul_int8;
}t_accel_farm_input;

// response from multiplier 
typedef struct packed {
    t_mul_int8_output [7:0] mul2core_int8;
}t_accel_farm_output;

typedef struct packed {
    logic [15:0] cr_core2mul_int8;    // {multiplicand, multiplier}
    logic [15:0] cr_mul2core_result;  // 16 bit result
    logic        cr_mul2core_done;    // result is ready
}t_cr_int8_multiplier;

typedef struct packed {
    t_cr_int8_multiplier [7:0] cr_int8_multiplier;
}t_accel_cr_int8_multipliers;

// FIXME  used for degub purposes untill we will have dedicated ref model
typedef struct packed {
    logic [31:0] cr_debug_0;
} t_cr_debug;

// define CR's
parameter CR_MEM_OFFSET       = 'h00FE_0000;
parameter CR_MEM_REGION_FLOOR =  CR_MEM_OFFSET;
parameter CR_MEM_REGION_ROOF  = 'h00FF_0000 - 1;

// define CR's for INT8 multiplier
parameter CR_CORE2MUL_INT8_0     = CR_MEM_OFFSET + 'hf000;
parameter CR_CORE2MUL_INT8_1     = CR_MEM_OFFSET + 'hf001;
parameter CR_CORE2MUL_INT8_2     = CR_MEM_OFFSET + 'hf002;
parameter CR_CORE2MUL_INT8_3     = CR_MEM_OFFSET + 'hf003;
parameter CR_CORE2MUL_INT8_4     = CR_MEM_OFFSET + 'hf004;
parameter CR_CORE2MUL_INT8_5     = CR_MEM_OFFSET + 'hf005;
parameter CR_CORE2MUL_INT8_6     = CR_MEM_OFFSET + 'hf006;
parameter CR_CORE2MUL_INT8_7     = CR_MEM_OFFSET + 'hf007;


parameter CR_MUL2CORE_INT8_0        = CR_MEM_OFFSET + 'hf008;
parameter CR_MUL2CORE_INT8_DONE_0   = CR_MEM_OFFSET + 'hf009;
parameter CR_MUL2CORE_INT8_1        = CR_MEM_OFFSET + 'hf00a;
parameter CR_MUL2CORE_INT8_DONE_1   = CR_MEM_OFFSET + 'hf00b;
parameter CR_MUL2CORE_INT8_2        = CR_MEM_OFFSET + 'hf00c;
parameter CR_MUL2CORE_INT8_DONE_2   = CR_MEM_OFFSET + 'hf00d;
parameter CR_MUL2CORE_INT8_3        = CR_MEM_OFFSET + 'hf00e;
parameter CR_MUL2CORE_INT8_DONE_3   = CR_MEM_OFFSET + 'hf00f;
parameter CR_MUL2CORE_INT8_4        = CR_MEM_OFFSET + 'hf010;
parameter CR_MUL2CORE_INT8_DONE_4   = CR_MEM_OFFSET + 'hf011;
parameter CR_MUL2CORE_INT8_5        = CR_MEM_OFFSET + 'hf012;
parameter CR_MUL2CORE_INT8_DONE_5   = CR_MEM_OFFSET + 'hf013;
parameter CR_MUL2CORE_INT8_6        = CR_MEM_OFFSET + 'hf014;
parameter CR_MUL2CORE_INT8_DONE_6   = CR_MEM_OFFSET + 'hf015;
parameter CR_MUL2CORE_INT8_7        = CR_MEM_OFFSET + 'hf016;
parameter CR_MUL2CORE_INT8_DONE_7   = CR_MEM_OFFSET + 'hf017; 

// used for debug purposes
parameter CR_DEBUG_0                = CR_MEM_OFFSET + 'hff00;

endpackage