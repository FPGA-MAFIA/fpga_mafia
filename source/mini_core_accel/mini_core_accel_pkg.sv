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
    int8   pre_multiplicand;
    int8   pre_multiplier;
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

// TODO - I keept the cr's naming looks the same as CR's addresses and 
// not as array. Consider refactoring for naming consistency in the future 
typedef struct packed {
    logic [15:0] cr_core2mul_int8_0;  // {multiplicand, multiplier}
    logic [15:0] cr_core2mul_int8_1;
    logic [15:0] cr_core2mul_int8_2;
    logic [15:0] cr_core2mul_int8_3;
    logic [15:0] cr_core2mul_int8_4;
    logic [15:0] cr_core2mul_int8_5;
    logic [15:0] cr_core2mul_int8_6;
    logic [15:0] cr_core2mul_int8_7;
    logic [16:0] cr_mul2core_int8_0;  // {done, result}
    logic [16:0] cr_mul2core_int8_1;
    logic [16:0] cr_mul2core_int8_2;
    logic [16:0] cr_mul2core_int8_3;
    logic [16:0] cr_mul2core_int8_4;
    logic [16:0] cr_mul2core_int8_5;
    logic [16:0] cr_mul2core_int8_6;
    logic [16:0] cr_mul2core_int8_7;
} t_accel_cr;

// define CR's
parameter CR_MEM_OFFSET       = 'h00FE_0000;
parameter CR_MEM_REGION_FLOOR =  CR_MEM_OFFSET;
parameter CR_MEM_REGION_ROOF  = 'h00FF_0000 - 1;

parameter CR_CORE2MUL_INT8_0     = CR_MEM_OFFSET + 'hf000;
parameter CR_CORE2MUL_INT8_1     = CR_MEM_OFFSET + 'hf001;
parameter CR_CORE2MUL_INT8_2     = CR_MEM_OFFSET + 'hf002;
parameter CR_CORE2MUL_INT8_3     = CR_MEM_OFFSET + 'hf003;
parameter CR_CORE2MUL_INT8_4     = CR_MEM_OFFSET + 'hf004;
parameter CR_CORE2MUL_INT8_5     = CR_MEM_OFFSET + 'hf005;
parameter CR_CORE2MUL_INT8_6     = CR_MEM_OFFSET + 'hf006;
parameter CR_CORE2MUL_INT8_7     = CR_MEM_OFFSET + 'hf007;

parameter CR_MUL2CORE_INT8_0     = CR_MEM_OFFSET + 'hf008;
parameter CR_MUL2CORE_INT8_1     = CR_MEM_OFFSET + 'hf009;
parameter CR_MUL2CORE_INT8_2     = CR_MEM_OFFSET + 'hf00a;
parameter CR_MUL2CORE_INT8_3     = CR_MEM_OFFSET + 'hf00b;
parameter CR_MUL2CORE_INT8_4     = CR_MEM_OFFSET + 'hf00c;
parameter CR_MUL2CORE_INT8_5     = CR_MEM_OFFSET + 'hf00d;
parameter CR_MUL2CORE_INT8_6     = CR_MEM_OFFSET + 'hf00e;
parameter CR_MUL2CORE_INT8_7     = CR_MEM_OFFSET + 'hf00f;



endpackage