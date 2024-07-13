//-------------------------------------
// accelerators farm package
//-------------------------------------

package mini_core_accel_pkg;

parameter NUM_WIDTH = 8;

typedef enum {
    IDLE,  
    SUB_OR_ADD_AM,             // subtract or add accumulator with multiplicand
    ARITHMETIC_SHIFT_RIGHT            
} t_booth_states;

typedef struct packed {
    logic                  Valid;
    logic [NUM_WIDTH-1:0]  Multiplicand;
    logic [NUM_WIDTH-1:0]  Multiplier;

}t_booth_mul_req;

typedef struct packed {
   logic                    Valid;
   logic [2*NUM_WIDTH-1:0]  Result;
}t_booth_output;

endpackage