//-------------------------------------
// accelerators farm package
//-------------------------------------

package mini_core_accel_pkg;

parameter NUM_WIDTH = 8;
typedef   logic [NUM_WIDTH-1:0] int8;

typedef enum {
    IDLE,  
    SUB_OR_ADD_AM,             // subtract or add accumulator with multiplicand
    ARITHMETIC_SHIFT_RIGHT            
} t_booth_states;

typedef struct packed {
    logic  valid;
    int8   multiplicand;
    int8   multiplier;

}t_booth_mul_req;

typedef struct packed {
   logic                    valid;
   logic [2*NUM_WIDTH-1:0]  result;
}t_booth_output;

endpackage