//-------------------------------------
// accelerators farm package
//-------------------------------------

package mini_core_accel_pkg;

parameter NUM_WIDTH       = 8;
typedef   logic [NUM_WIDTH-1:0] int8;

typedef enum {
    IDLE,  
    SUB_OR_ADD_AM,             // subtract or add accumulator with multiplicand
    ARITHMETIC_SHIFT_RIGHT,
    DONE            
} t_booth_states;

typedef struct packed {
    logic  valid;
    int8   multiplicand;
    int8   multiplier;
}t_mul_input_req;

typedef struct packed {
   logic                    valid;
   logic [2*NUM_WIDTH-1:0]  result;
   logic                    busy;
}t_mul_output_rsp;

typedef struct packed { // {start, multiplicand, multiplier}
    t_mul_input_req [7:0] core2mul;
}t_core2mul_req;

// response from multiplier 
typedef struct packed {
    t_mul_output_rsp [7:0] mul2core;
}t_mul2core_rsp;

// TODO - I keept the cr's naming looks the same as CR's addresses and 
// not as array. Consider refactoring for naming consistency in the future 
typedef struct packed {
    logic [16:0] cr_core2mul_0;
    logic [16:0] cr_core2mul_1;
    logic [16:0] cr_core2mul_2;
    logic [16:0] cr_core2mul_3;
    logic [16:0] cr_core2mul_4;
    logic [16:0] cr_core2mul_5;
    logic [16:0] cr_core2mul_6;
    logic [16:0] cr_core2mul_7;
    logic [17:0] cr_mul2core_0;
    logic [17:0] cr_mul2core_1;
    logic [17:0] cr_mul2core_2;
    logic [17:0] cr_mul2core_3;
    logic [17:0] cr_mul2core_4;
    logic [17:0] cr_mul2core_5;
    logic [17:0] cr_mul2core_6;
    logic [17:0] cr_mul2core_7;
} t_accel_cr;

// define CR's
parameter CR_MEM_OFFSET       = 'h00FE_0000;
parameter CR_MEM_REGION_FLOOR = CR_MEM_OFFSET;
parameter CR_MEM_REGION_ROOF  = 'h00FF_0000 - 1;

parameter CR_CORE2MUL_0     = CR_MEM_OFFSET + 'hf000;
parameter CR_CORE2MUL_1     = CR_MEM_OFFSET + 'hf001;
parameter CR_CORE2MUL_2     = CR_MEM_OFFSET + 'hf002;
parameter CR_CORE2MUL_3     = CR_MEM_OFFSET + 'hf003;
parameter CR_CORE2MUL_4     = CR_MEM_OFFSET + 'hf004;
parameter CR_CORE2MUL_5     = CR_MEM_OFFSET + 'hf005;
parameter CR_CORE2MUL_6     = CR_MEM_OFFSET + 'hf006;
parameter CR_CORE2MUL_7     = CR_MEM_OFFSET + 'hf007;

parameter CR_MUL2CORE_0     = CR_MEM_OFFSET + 'hf0008;
parameter CR_MUL2CORE_1     = CR_MEM_OFFSET + 'hf0009;
parameter CR_MUL2CORE_2     = CR_MEM_OFFSET + 'hf000a;
parameter CR_MUL2CORE_3     = CR_MEM_OFFSET + 'hf000b;
parameter CR_MUL2CORE_4     = CR_MEM_OFFSET + 'hf000c;
parameter CR_MUL2CORE_5     = CR_MEM_OFFSET + 'hf000d;
parameter CR_MUL2CORE_6     = CR_MEM_OFFSET + 'hf000e;
parameter CR_MUL2CORE_7     = CR_MEM_OFFSET + 'hf000f;



endpackage