//-------------------------------------
// accelerators farm package
//-------------------------------------

package mini_core_accel_pkg;

parameter NUM_WIDTH = 8;
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

typedef struct packed {
    t_mul_input_req mul0;
    t_mul_input_req mul1;
    t_mul_input_req mul2;
    t_mul_input_req mul3;
    t_mul_input_req mul4;
    t_mul_input_req mul5;
    t_mul_input_req mul6;
    t_mul_input_req mul7;
}t_core_mul_req;

// response from multiplier 
typedef struct packed {
    t_mul_output_rsp mul0;
    t_mul_output_rsp mul1;
    t_mul_output_rsp mul2;
    t_mul_output_rsp mul3;
    t_mul_output_rsp mul4;
    t_mul_output_rsp mul5;
    t_mul_output_rsp mul6;
    t_mul_output_rsp mul7;
}t_mul_core_rsp;

typedef struct packed {
    logic [31:0] cr_mul_0;
    logic [31:0] cr_mul_1;
    logic [31:0] cr_mul_2;
    logic [31:0] cr_mul_3;
    logic [31:0] cr_mul_4;
    logic [31:0] cr_mul_5;
    logic [31:0] cr_mul_6;
    logic [31:0] cr_mul_7;
    logic [31:0] cr_mul_ctrl;
} t_accel_cr;

// define CR's
parameter CR_MEM_OFFSET       = 'h00FE_0000;
parameter CR_MEM_REGION_FLOOR = CR_MEM_OFFSET;
parameter CR_MEM_REGION_ROOF  = 'h00FF_0000 - 1;

parameter CR_MUL_0    = CR_MEM_OFFSET + 'hf000;
parameter CR_MUL_1    = CR_MEM_OFFSET + 'hf001;
parameter CR_MUL_2    = CR_MEM_OFFSET + 'hf002;
parameter CR_MUL_3    = CR_MEM_OFFSET + 'hf003;
parameter CR_MUL_4    = CR_MEM_OFFSET + 'hf004;
parameter CR_MUL_5    = CR_MEM_OFFSET + 'hf005;
parameter CR_MUL_6    = CR_MEM_OFFSET + 'hf006;
parameter CR_MUL_7    = CR_MEM_OFFSET + 'hf007;
parameter CR_MUL_CTRL = CR_MEM_OFFSET + 'hf0008;

endpackage