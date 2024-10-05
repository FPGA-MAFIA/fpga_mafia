//-------------------------------------
// accelerators farm package
//-------------------------------------

package mini_core_accel_pkg;

parameter  INT8_MULTIPLIER_NUM = 16;
parameter  NEURON_MAC_NUM      = 2;
parameter  NUM_WIDTH_INT8      = 8;
typedef  logic [7:0]       int8;
typedef  logic [15:0]      int16;


//-------------------------
// int8 multiplier structs
//-------------------------
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

//-------------------------
// neuron mac structs
//-------------------------
typedef struct packed {
    logic [7:0][15:0] mul_result;  // result fron int8_multiplier
    logic [7:0]       bias; 
}t_neuron_mac_input;

typedef struct packed {
    logic [7:0] int8_result;
}t_neuron_mac_output;

//-------------------------
// systolic array structs
//-------------------------
parameter DIMENTION = 4;  // 4x4 grid. Do not change the grid size without updating structs

typedef struct packed{
    int8  weight;     // input weight
    int8  activation; // input activation
    logic start;      // start calculation
    logic done;       // stop calculation
} t_pe_unit_input;

typedef struct packed {
    int8  activation;  // activation passed to neighboured PE's
    int8  weight;      // weight passed to neighboured PE's
    logic done;        // done signal passing neighboured PE's
} t_pe_unit_output;

typedef struct packed { // naming of each element is treated as a matrix 4x4 elements
     int16 pe00_result;
     int16 pe01_result;
     int16 pe02_result;
     int16 pe03_result;
     int16 pe10_result;
     int16 pe11_result;
     int16 pe12_result;
     int16 pe13_result;
     int16 pe20_result;
     int16 pe21_result;
     int16 pe22_result;
     int16 pe23_result;
     int16 pe30_result;
     int16 pe31_result;
     int16 pe32_result;
     int16 pe33_result;
} t_pe_results;

typedef struct packed{
    logic [31:0]  cr_systolic_array_weights31_0;
    logic [31:0]  cr_systolic_array_weights63_32;
    logic [31:0]  cr_systolic_array_weights95_64;
    logic [31:0]  cr_systolic_array_weights127_96;
    logic [31:0]  cr_systolic_array_active31_0;
    logic [31:0]  cr_systolic_array_active63_32;
    logic [31:0]  cr_systolic_array_active95_64;
    logic [31:0]  cr_systolic_array_active127_96;
    logic         cr_systolic_array_start;
    logic         cr_systolic_array_valid;
    // results
    int16         cr_pe00_result;
    int16         cr_pe01_result;
    int16         cr_pe02_result;
    int16         cr_pe03_result;
    int16         cr_pe10_result;
    int16         cr_pe11_result;
    int16         cr_pe12_result;
    int16         cr_pe13_result;
    int16         cr_pe20_result;
    int16         cr_pe21_result;
    int16         cr_pe22_result;
    int16         cr_pe23_result;
    int16         cr_pe30_result;
    int16         cr_pe31_result;
    int16         cr_pe32_result;
    int16         cr_pe33_result;
} t_cr_systolic_array;

typedef enum {
    IDLE,
    STEP0,
    STEP1,
    STEP2,
    STEP3,
    STEP4,
    STEP5,
    STEP6,
    WAIT
} t_systolic_array_ctrl_states;
//-------------------------
// cr structs
//-------------------------
typedef struct packed {
    logic [7:0]  cr_core2mul_multiplicant_int8;  
    logic [7:0]  cr_core2mul_multiplier_int8; 
    logic [15:0] cr_mul2core_result;  // 16 bit result
    logic        cr_mul2core_done;    // result is ready
}t_cr_int8_multiplier;

typedef struct packed {
    t_cr_int8_multiplier [INT8_MULTIPLIER_NUM-1:0] cr_int8_multiplier;
}t_accel_cr_int8_multipliers;

typedef struct packed{
    logic [7:0] neuron_mac_bias0;
    logic [7:0] neuron_mac_bias1;
    logic [7:0] neuron_mac_result0;
    logic [7:0] neuron_mac_result1;
}t_accel_cr_neuron_mac;

//-------------------------
// Debug structs
//-------------------------
// FIXME  used for degub purposes untill we will have dedicated ref model
typedef struct packed {
    logic [31:0] cr_debug_0;
    logic [31:0] cr_debug_1;
    logic [31:0] cr_debug_2;
    logic [31:0] cr_debug_3;
} t_cr_debug;

//----------------------------
// acceleration farm structs
//----------------------------
// data connecting CR to dedicated unit
typedef struct packed { 
    t_mul_int8_input   [INT8_MULTIPLIER_NUM-1:0] core2mul_int8;      // {multiplicand, multiplier}
    t_neuron_mac_input [NEURON_MAC_NUM-1:0]      int8_mul2neuron_mac;  // {mul_result[7:0][15:0], bias}
    t_cr_systolic_array                          cr_systolic_array;  
}t_accel_farm_input;

// response from multiplier 
typedef struct packed {
    t_mul_int8_output   [INT8_MULTIPLIER_NUM-1:0] mul2core_int8;
    t_neuron_mac_output [NEURON_MAC_NUM-1:0]      neuron_mac_result;
    t_cr_systolic_array                           cr_systolic_array;
}t_accel_farm_output;



// define CR's
parameter CR_MEM_OFFSET       = 'h00FE_0000;
parameter CR_MEM_REGION_FLOOR =  CR_MEM_OFFSET;
parameter CR_MEM_REGION_ROOF  = 'h00FF_0000 - 1;


//FIXME refactor to be more compact
//=====================================
//   define CR's for INT8 multiplier
//=====================================
parameter CR_CORE2MUL_INT8_MULTIPLICANT_0     = CR_MEM_OFFSET + 'hf000;
parameter CR_CORE2MUL_INT8_MULTIPLIER_0       = CR_MEM_OFFSET + 'hf001;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_1     = CR_MEM_OFFSET + 'hf002;
parameter CR_CORE2MUL_INT8_MULTIPLIER_1       = CR_MEM_OFFSET + 'hf003;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_2     = CR_MEM_OFFSET + 'hf004;
parameter CR_CORE2MUL_INT8_MULTIPLIER_2       = CR_MEM_OFFSET + 'hf005;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_3     = CR_MEM_OFFSET + 'hf006;
parameter CR_CORE2MUL_INT8_MULTIPLIER_3       = CR_MEM_OFFSET + 'hf007;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_4     = CR_MEM_OFFSET + 'hf008;
parameter CR_CORE2MUL_INT8_MULTIPLIER_4       = CR_MEM_OFFSET + 'hf009;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_5     = CR_MEM_OFFSET + 'hf00a;
parameter CR_CORE2MUL_INT8_MULTIPLIER_5       = CR_MEM_OFFSET + 'hf00b;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_6     = CR_MEM_OFFSET + 'hf00c;
parameter CR_CORE2MUL_INT8_MULTIPLIER_6       = CR_MEM_OFFSET + 'hf00d;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_7     = CR_MEM_OFFSET + 'hf00e;
parameter CR_CORE2MUL_INT8_MULTIPLIER_7       = CR_MEM_OFFSET + 'hf00f;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_8     = CR_MEM_OFFSET + 'hf010;
parameter CR_CORE2MUL_INT8_MULTIPLIER_8       = CR_MEM_OFFSET + 'hf011;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_9     = CR_MEM_OFFSET + 'hf012;
parameter CR_CORE2MUL_INT8_MULTIPLIER_9       = CR_MEM_OFFSET + 'hf013;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_10    = CR_MEM_OFFSET + 'hf014;
parameter CR_CORE2MUL_INT8_MULTIPLIER_10      = CR_MEM_OFFSET + 'hf015;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_11    = CR_MEM_OFFSET + 'hf016;
parameter CR_CORE2MUL_INT8_MULTIPLIER_11      = CR_MEM_OFFSET + 'hf017;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_12    = CR_MEM_OFFSET + 'hf018;
parameter CR_CORE2MUL_INT8_MULTIPLIER_12      = CR_MEM_OFFSET + 'hf019;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_13    = CR_MEM_OFFSET + 'hf01a;
parameter CR_CORE2MUL_INT8_MULTIPLIER_13      = CR_MEM_OFFSET + 'hf01b;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_14    = CR_MEM_OFFSET + 'hf01c;
parameter CR_CORE2MUL_INT8_MULTIPLIER_14      = CR_MEM_OFFSET + 'hf01d;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_15    = CR_MEM_OFFSET + 'hf01e;
parameter CR_CORE2MUL_INT8_MULTIPLIER_15      = CR_MEM_OFFSET + 'hf01f;


parameter CR_MUL2CORE_INT8_0        = CR_MEM_OFFSET + 'hf050;
parameter CR_MUL2CORE_INT8_DONE_0   = CR_MEM_OFFSET + 'hf051;
parameter CR_MUL2CORE_INT8_1        = CR_MEM_OFFSET + 'hf052;
parameter CR_MUL2CORE_INT8_DONE_1   = CR_MEM_OFFSET + 'hf053;
parameter CR_MUL2CORE_INT8_2        = CR_MEM_OFFSET + 'hf054;
parameter CR_MUL2CORE_INT8_DONE_2   = CR_MEM_OFFSET + 'hf055;
parameter CR_MUL2CORE_INT8_3        = CR_MEM_OFFSET + 'hf056;
parameter CR_MUL2CORE_INT8_DONE_3   = CR_MEM_OFFSET + 'hf057;
parameter CR_MUL2CORE_INT8_4        = CR_MEM_OFFSET + 'hf058;
parameter CR_MUL2CORE_INT8_DONE_4   = CR_MEM_OFFSET + 'hf059;
parameter CR_MUL2CORE_INT8_5        = CR_MEM_OFFSET + 'hf05a;
parameter CR_MUL2CORE_INT8_DONE_5   = CR_MEM_OFFSET + 'hf05b;
parameter CR_MUL2CORE_INT8_6        = CR_MEM_OFFSET + 'hf05c;
parameter CR_MUL2CORE_INT8_DONE_6   = CR_MEM_OFFSET + 'hf05d;
parameter CR_MUL2CORE_INT8_7        = CR_MEM_OFFSET + 'hf05e;
parameter CR_MUL2CORE_INT8_DONE_7   = CR_MEM_OFFSET + 'hf05f;
parameter CR_MUL2CORE_INT8_8        = CR_MEM_OFFSET + 'hf060;
parameter CR_MUL2CORE_INT8_DONE_8   = CR_MEM_OFFSET + 'hf061;
parameter CR_MUL2CORE_INT8_9        = CR_MEM_OFFSET + 'hf062;
parameter CR_MUL2CORE_INT8_DONE_9   = CR_MEM_OFFSET + 'hf063;
parameter CR_MUL2CORE_INT8_10       = CR_MEM_OFFSET + 'hf064;
parameter CR_MUL2CORE_INT8_DONE_10  = CR_MEM_OFFSET + 'hf065;
parameter CR_MUL2CORE_INT8_11       = CR_MEM_OFFSET + 'hf066;
parameter CR_MUL2CORE_INT8_DONE_11  = CR_MEM_OFFSET + 'hf067;
parameter CR_MUL2CORE_INT8_12       = CR_MEM_OFFSET + 'hf068;
parameter CR_MUL2CORE_INT8_DONE_12  = CR_MEM_OFFSET + 'hf069;
parameter CR_MUL2CORE_INT8_13       = CR_MEM_OFFSET + 'hf06a;
parameter CR_MUL2CORE_INT8_DONE_13  = CR_MEM_OFFSET + 'hf06b;
parameter CR_MUL2CORE_INT8_14       = CR_MEM_OFFSET + 'hf06c;
parameter CR_MUL2CORE_INT8_DONE_14  = CR_MEM_OFFSET + 'hf06d;
parameter CR_MUL2CORE_INT8_15       = CR_MEM_OFFSET + 'hf06e;
parameter CR_MUL2CORE_INT8_DONE_15  = CR_MEM_OFFSET + 'hf06f; 


//==================================
//   define CR's for neuron_mac
//==================================
parameter NEURON_MAC_BIAS0         = CR_MEM_OFFSET + 'hf100;
parameter NEURON_MAC_BIAS1         = CR_MEM_OFFSET + 'hf101; 
parameter NEURON_MAC_RESULT0       = CR_MEM_OFFSET + 'hf102; 
parameter NEURON_MAC_RESULT1       = CR_MEM_OFFSET + 'hf103;  

//=====================================
//   define CR's for systolic array
//=====================================
parameter SYSTOLIC_ARRAY_WEIGHTS31_0    = CR_MEM_OFFSET + 'hf200;
parameter SYSTOLIC_ARRAY_WEIGHTS63_32   = CR_MEM_OFFSET + 'hf201;
parameter SYSTOLIC_ARRAY_WEIGHTS95_64   = CR_MEM_OFFSET + 'hf202;
parameter SYSTOLIC_ARRAY_WEIGHTS127_96  = CR_MEM_OFFSET + 'hf203;
parameter SYSTOLIC_ARRAY_ACTIVE31_0     = CR_MEM_OFFSET + 'hf204;
parameter SYSTOLIC_ARRAY_ACTIVE63_32    = CR_MEM_OFFSET + 'hf205;
parameter SYSTOLIC_ARRAY_ACTIVE95_64    = CR_MEM_OFFSET + 'hf206;
parameter SYSTOLIC_ARRAY_ACTIVE127_96   = CR_MEM_OFFSET + 'hf207;
parameter SYSTOLIC_ARRAY_START          = CR_MEM_OFFSET + 'hf208;
parameter SYSTOLIC_ARRAY_VALID          = CR_MEM_OFFSET + 'hf209;

parameter PE00_RESULT                   = CR_MEM_OFFSET + 'hf20a;
parameter PE01_RESULT                   = CR_MEM_OFFSET + 'hf20b;
parameter PE02_RESULT                   = CR_MEM_OFFSET + 'hf20c;
parameter PE03_RESULT                   = CR_MEM_OFFSET + 'hf20d;
parameter PE10_RESULT                   = CR_MEM_OFFSET + 'hf20e;
parameter PE11_RESULT                   = CR_MEM_OFFSET + 'hf20f;
parameter PE12_RESULT                   = CR_MEM_OFFSET + 'hf210;
parameter PE13_RESULT                   = CR_MEM_OFFSET + 'hf211;
parameter PE20_RESULT                   = CR_MEM_OFFSET + 'hf212;
parameter PE21_RESULT                   = CR_MEM_OFFSET + 'hf213;
parameter PE22_RESULT                   = CR_MEM_OFFSET + 'hf214;
parameter PE23_RESULT                   = CR_MEM_OFFSET + 'hf215;
parameter PE30_RESULT                   = CR_MEM_OFFSET + 'hf216;
parameter PE31_RESULT                   = CR_MEM_OFFSET + 'hf217;
parameter PE32_RESULT                   = CR_MEM_OFFSET + 'hf218;
parameter PE33_RESULT                   = CR_MEM_OFFSET + 'hf219;


//=====================================
//   define CR's for dwbug purposes
//=====================================
parameter CR_DEBUG_0                = CR_MEM_OFFSET + 'hff00;
parameter CR_DEBUG_1                = CR_MEM_OFFSET + 'hff01;
parameter CR_DEBUG_2                = CR_MEM_OFFSET + 'hff02;
parameter CR_DEBUG_3                = CR_MEM_OFFSET + 'hff03;

endpackage