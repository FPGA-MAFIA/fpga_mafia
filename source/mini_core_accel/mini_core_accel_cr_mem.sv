//-----------------------------------------------------------------------------
// Title            : mini_core_accell_cr_mem
// Project          : fpga_mafia
//-----------------------------------------------------------------------------
// File             : mini_core_accell_cr_mem.sv
// Original Author  : 
// Code Owner       : 
// Adviser          : 
// Created          : 
//-----------------------------------------------------------------------------
// Description :
// The CR memory module - Control Registers memory.
// contains Flop based memory for the Control Registers.
// The memory is accessed by the core and the accelerator farm.


`include "macros.vh"

module mini_core_accell_cr_mem 
import mini_core_accel_pkg::*;
(
    input  logic       Clk,
    input  logic       Rst,

    // Core interface
    input  logic [31:0] data,
    input  logic [31:0] address,
    input  logic        wren,
    input  logic        rden,
    output logic [31:0] q,

    // Accelerators interface
    input  var t_accel_farm_output accel_farm_output,
    output var t_accel_farm_input  accel_farm_input 
);

integer i,j,k,l;

t_accel_cr_int8_multipliers accel_cr, next_accel_cr; // define a struct of structs for int8 multipliers
t_accel_cr_neuron_mac       cr_neuron_mac, next_cr_neuron_mac; 
t_cr_debug                  cr_debug, next_cr_debug;   // FIXME - remove cr for debug when we will have ref model

`MAFIA_DFF(accel_cr, next_accel_cr, Clk)
`MAFIA_DFF(cr_neuron_mac, next_cr_neuron_mac, Clk)
`MAFIA_DFF(cr_debug, next_cr_debug, Clk)

logic [31:0] pre_q;

// write to accel_cr
always_comb begin :wr_to_accel_cr
    next_accel_cr      = Rst ? '0 : accel_cr;
    next_cr_neuron_mac = Rst ? '0 : cr_neuron_mac;
    next_cr_debug      = Rst ? '0 : cr_debug;
    if(wren) begin // writing data from core to accelerators. 
        unique casez (address)
        // multiplicand and multiplier data comming from the core to the multiplier
        //FIXME refactor to be more compact
            // multiplier0
            CR_CORE2MUL_INT8_MULTIPLICANT_0     : next_accel_cr.cr_int8_multiplier[0].cr_core2mul_multiplicant_int8  = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_0       : next_accel_cr.cr_int8_multiplier[0].cr_core2mul_multiplier_int8    = data[7:0];
            // multiplier1
            CR_CORE2MUL_INT8_MULTIPLICANT_1     : next_accel_cr.cr_int8_multiplier[1].cr_core2mul_multiplicant_int8  = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_1       : next_accel_cr.cr_int8_multiplier[1].cr_core2mul_multiplier_int8    = data[7:0];
            // multiplier2
            CR_CORE2MUL_INT8_MULTIPLICANT_2     : next_accel_cr.cr_int8_multiplier[2].cr_core2mul_multiplicant_int8  = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_2       : next_accel_cr.cr_int8_multiplier[2].cr_core2mul_multiplier_int8    = data[7:0];
            // multiplier3
            CR_CORE2MUL_INT8_MULTIPLICANT_3     : next_accel_cr.cr_int8_multiplier[3].cr_core2mul_multiplicant_int8  = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_3       : next_accel_cr.cr_int8_multiplier[3].cr_core2mul_multiplier_int8    = data[7:0];
            // multiplier4
            CR_CORE2MUL_INT8_MULTIPLICANT_4     : next_accel_cr.cr_int8_multiplier[4].cr_core2mul_multiplicant_int8  = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_4       : next_accel_cr.cr_int8_multiplier[4].cr_core2mul_multiplier_int8    = data[7:0];
            // multiplier5
            CR_CORE2MUL_INT8_MULTIPLICANT_5     : next_accel_cr.cr_int8_multiplier[5].cr_core2mul_multiplicant_int8  = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_5       : next_accel_cr.cr_int8_multiplier[5].cr_core2mul_multiplier_int8    = data[7:0];
            // multiplier6
            CR_CORE2MUL_INT8_MULTIPLICANT_6     : next_accel_cr.cr_int8_multiplier[6].cr_core2mul_multiplicant_int8  = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_6       : next_accel_cr.cr_int8_multiplier[6].cr_core2mul_multiplier_int8    = data[7:0];
            // multiplier7
            CR_CORE2MUL_INT8_MULTIPLICANT_7     : next_accel_cr.cr_int8_multiplier[7].cr_core2mul_multiplicant_int8  = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_7       : next_accel_cr.cr_int8_multiplier[7].cr_core2mul_multiplier_int8    = data[7:0];
            // multiplier8
            CR_CORE2MUL_INT8_MULTIPLICANT_8     : next_accel_cr.cr_int8_multiplier[8].cr_core2mul_multiplicant_int8  = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_8       : next_accel_cr.cr_int8_multiplier[8].cr_core2mul_multiplier_int8    = data[7:0];
            // multiplier9
            CR_CORE2MUL_INT8_MULTIPLICANT_9     : next_accel_cr.cr_int8_multiplier[9].cr_core2mul_multiplicant_int8  = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_9       : next_accel_cr.cr_int8_multiplier[9].cr_core2mul_multiplier_int8    = data[7:0];
            // multiplier10
            CR_CORE2MUL_INT8_MULTIPLICANT_10    : next_accel_cr.cr_int8_multiplier[10].cr_core2mul_multiplicant_int8 = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_10      : next_accel_cr.cr_int8_multiplier[10].cr_core2mul_multiplier_int8   = data[7:0];
            // multiplier11
            CR_CORE2MUL_INT8_MULTIPLICANT_11    : next_accel_cr.cr_int8_multiplier[11].cr_core2mul_multiplicant_int8 = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_11      : next_accel_cr.cr_int8_multiplier[11].cr_core2mul_multiplier_int8   = data[7:0];
            // multiplier12
            CR_CORE2MUL_INT8_MULTIPLICANT_12    : next_accel_cr.cr_int8_multiplier[12].cr_core2mul_multiplicant_int8 = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_12      : next_accel_cr.cr_int8_multiplier[12].cr_core2mul_multiplier_int8   = data[7:0];
            // multiplier13
            CR_CORE2MUL_INT8_MULTIPLICANT_13    : next_accel_cr.cr_int8_multiplier[13].cr_core2mul_multiplicant_int8 = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_13      : next_accel_cr.cr_int8_multiplier[13].cr_core2mul_multiplier_int8   = data[7:0];
            // multiplier14
            CR_CORE2MUL_INT8_MULTIPLICANT_14    : next_accel_cr.cr_int8_multiplier[14].cr_core2mul_multiplicant_int8 = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_14      : next_accel_cr.cr_int8_multiplier[14].cr_core2mul_multiplier_int8   = data[7:0];
            // multiplier15
            CR_CORE2MUL_INT8_MULTIPLICANT_15    : next_accel_cr.cr_int8_multiplier[15].cr_core2mul_multiplicant_int8 = data[7:0]; 
            CR_CORE2MUL_INT8_MULTIPLIER_15      : next_accel_cr.cr_int8_multiplier[15].cr_core2mul_multiplier_int8   = data[7:0];

            // neuron_mac0
            NEURON_MAC_BIAS0                    : next_cr_neuron_mac.neuron_mac_bias0                                = data[7:0];
            // neuron_mac1
            NEURON_MAC_BIAS1                    : next_cr_neuron_mac.neuron_mac_bias1                                = data[7:0];
            
            // cr's for debug
            CR_DEBUG_0                          : next_cr_debug.cr_debug_0                                           = data[31:0];
            CR_DEBUG_1                          : next_cr_debug.cr_debug_1                                           = data[31:0];
            CR_DEBUG_2                          : next_cr_debug.cr_debug_2                                           = data[31:0];
            CR_DEBUG_3                          : next_cr_debug.cr_debug_3                                           = data[31:0]; 
            default            : ; // do nothing
        endcase
    end
        // hard wired {done, result}
        for(int i = 0; i < INT8_MULTIPLIER_NUM; i++) begin
            {next_accel_cr.cr_int8_multiplier[i].cr_mul2core_done, next_accel_cr.cr_int8_multiplier[i].cr_mul2core_result} = 
                                                                                {accel_farm_output.mul2core_int8[i].done, accel_farm_output.mul2core_int8[i].result};
        end
        // hard wired result from neuron mac
        next_cr_neuron_mac.neuron_mac_result0 = accel_farm_output.neuron_mac_result[0].int8_result;
        next_cr_neuron_mac.neuron_mac_result1 = accel_farm_output.neuron_mac_result[1].int8_result;
       
end

// reading data
always_comb begin : read_from_accel_cr
    pre_q =  q;
    if(rden) begin
        unique casez(address)
        //FIXME refactor to be more compact
            CR_MUL2CORE_INT8_0      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[0].cr_mul2core_result};  // result of multiplier0
            CR_MUL2CORE_INT8_DONE_0 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[0].cr_mul2core_done};    // done bit of multiplier0
            // multiplier1
            CR_MUL2CORE_INT8_1      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[1].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_1 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[1].cr_mul2core_done};
            // multiplier2
            CR_MUL2CORE_INT8_2      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[2].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_2 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[2].cr_mul2core_done};
            // multipler3
            CR_MUL2CORE_INT8_3      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[3].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_3 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[3].cr_mul2core_done};
            // multiplier4
            CR_MUL2CORE_INT8_4      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[4].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_4 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[4].cr_mul2core_done};
            // multiplier5
            CR_MUL2CORE_INT8_5      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[5].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_5 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[5].cr_mul2core_done};
            // multiplier6
            CR_MUL2CORE_INT8_6      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[6].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_6 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[6].cr_mul2core_done};
            // multiplier7
            CR_MUL2CORE_INT8_7      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[7].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_7 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[7].cr_mul2core_done};
            // multiplier8
            CR_MUL2CORE_INT8_8      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[8].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_8 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[8].cr_mul2core_done};
            // multiplier9
            CR_MUL2CORE_INT8_9      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[9].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_9 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[9].cr_mul2core_done};
            // multiplier10
            CR_MUL2CORE_INT8_10      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[10].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_10 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[10].cr_mul2core_done};
            // multiplier11
            CR_MUL2CORE_INT8_11      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[11].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_11 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[11].cr_mul2core_done};
            // multiplier12
            CR_MUL2CORE_INT8_12      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[12].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_12 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[12].cr_mul2core_done};
            // multiplier13
            CR_MUL2CORE_INT8_13      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[13].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_13 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[13].cr_mul2core_done};
            // multiplier14
            CR_MUL2CORE_INT8_14      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[14].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_14 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[14].cr_mul2core_done};
            // multiplier15
            CR_MUL2CORE_INT8_15      : pre_q = {16'b0, accel_cr.cr_int8_multiplier[15].cr_mul2core_result};
            CR_MUL2CORE_INT8_DONE_15 : pre_q = {31'b0, accel_cr.cr_int8_multiplier[15].cr_mul2core_done};

            // neuron_mac0
            NEURON_MAC_RESULT0      : pre_q = {24'b0, cr_neuron_mac.neuron_mac_result0};
            // neuron_mac1
            NEURON_MAC_RESULT1      : pre_q = {24'b0, cr_neuron_mac.neuron_mac_result1};
            
            // cr's for debug
            CR_DEBUG_0              : pre_q = cr_debug.cr_debug_0;
            CR_DEBUG_1              : pre_q = cr_debug.cr_debug_1;
            CR_DEBUG_2              : pre_q = cr_debug.cr_debug_2;
            CR_DEBUG_3              : pre_q = cr_debug.cr_debug_3; 

            default      : ; // do nothing 
        endcase
    end
        // hard wired from cr to multipliers
        for(int j=0; j < INT8_MULTIPLIER_NUM; j++) begin
            {accel_farm_input.core2mul_int8[j].multiplicand, accel_farm_input.core2mul_int8[j].multiplier} =
                                                {accel_cr.cr_int8_multiplier[j].cr_core2mul_multiplicant_int8, accel_cr.cr_int8_multiplier[j].cr_core2mul_multiplier_int8};
       end
       // hard wired neuron_mac results from multipliers
       accel_farm_input.int8_mul2neuron_mac[0].bias = cr_neuron_mac.neuron_mac_bias0;
       accel_farm_input.int8_mul2neuron_mac[1].bias = cr_neuron_mac.neuron_mac_bias1;
       
       for(int k=0; k<NEURON_MAC_NUM; k++) begin
            for(l=0; l< INT8_MULTIPLIER_NUM/2; l++) begin
                accel_farm_input.int8_mul2neuron_mac[k].mul_result[l] = accel_cr.cr_int8_multiplier[l+8*k].cr_mul2core_result;
            end
       end
end 

`MAFIA_RST_DFF(q, pre_q, Clk, Rst)

endmodule // Module 