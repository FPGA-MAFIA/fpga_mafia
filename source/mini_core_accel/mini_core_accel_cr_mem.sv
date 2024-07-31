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

t_accel_cr accel_cr;
t_accel_cr next_accel_cr;

`MAFIA_DFF(accel_cr, next_accel_cr, Clk)

logic [31:0] pre_q;

// write to accel_cr
always_comb begin :wr_to_accel_cr
    next_accel_cr = Rst ? '0 : accel_cr;
    if(wren) begin // writing data from core to accelerators. 
        unique casez (address)
        // each CR_CORE2MUL_I concantinated with {multiplicand, multiplier}
          CR_CORE2MUL_INT8_0     : next_accel_cr.cr_core2mul_int8_0   = data[15:0]; 
          CR_CORE2MUL_INT8_1     : next_accel_cr.cr_core2mul_int8_1   = data[15:0];
          CR_CORE2MUL_INT8_2     : next_accel_cr.cr_core2mul_int8_2   = data[15:0];
          CR_CORE2MUL_INT8_3     : next_accel_cr.cr_core2mul_int8_3   = data[15:0];
          CR_CORE2MUL_INT8_4     : next_accel_cr.cr_core2mul_int8_4   = data[15:0];
          CR_CORE2MUL_INT8_5     : next_accel_cr.cr_core2mul_int8_5   = data[15:0];
          CR_CORE2MUL_INT8_6     : next_accel_cr.cr_core2mul_int8_6   = data[15:0];
          CR_CORE2MUL_INT8_7     : next_accel_cr.cr_core2mul_int8_7   = data[15:0];
          default            : ; // do nothing
        endcase
    end
        // hard wired {done, result}
        next_accel_cr.cr_mul2core_int8_0 = {accel_farm_output.mul2core_int8[0].done, accel_farm_output.mul2core_int8[0].result};
        next_accel_cr.cr_mul2core_int8_1 = {accel_farm_output.mul2core_int8[1].done, accel_farm_output.mul2core_int8[1].result};
        next_accel_cr.cr_mul2core_int8_2 = {accel_farm_output.mul2core_int8[2].done, accel_farm_output.mul2core_int8[2].result};
        next_accel_cr.cr_mul2core_int8_3 = {accel_farm_output.mul2core_int8[3].done, accel_farm_output.mul2core_int8[3].result};
        next_accel_cr.cr_mul2core_int8_4 = {accel_farm_output.mul2core_int8[4].done, accel_farm_output.mul2core_int8[4].result};
        next_accel_cr.cr_mul2core_int8_5 = {accel_farm_output.mul2core_int8[5].done, accel_farm_output.mul2core_int8[5].result};
        next_accel_cr.cr_mul2core_int8_6 = {accel_farm_output.mul2core_int8[6].done, accel_farm_output.mul2core_int8[6].result};
        next_accel_cr.cr_mul2core_int8_7 = {accel_farm_output.mul2core_int8[7].done, accel_farm_output.mul2core_int8[7].result};

end

// reading data
always_comb begin : read_from_accel_cr
    pre_q =  q;
    if(rden) begin
        unique casez(address)
            CR_MUL2CORE_INT8_0     : pre_q = {15'b0, accel_cr.cr_mul2core_int8_0};
            CR_MUL2CORE_INT8_1     : pre_q = {15'b0, accel_cr.cr_mul2core_int8_1};
            CR_MUL2CORE_INT8_2     : pre_q = {15'b0, accel_cr.cr_mul2core_int8_2};
            CR_MUL2CORE_INT8_3     : pre_q = {15'b0, accel_cr.cr_mul2core_int8_3};
            CR_MUL2CORE_INT8_4     : pre_q = {15'b0, accel_cr.cr_mul2core_int8_4};
            CR_MUL2CORE_INT8_5     : pre_q = {15'b0, accel_cr.cr_mul2core_int8_5};
            CR_MUL2CORE_INT8_6     : pre_q = {15'b0, accel_cr.cr_mul2core_int8_6};
            CR_MUL2CORE_INT8_7     : pre_q = {15'b0, accel_cr.cr_mul2core_int8_7};
            default      : ; // do nothing 
        endcase
    end
        // hard wired from cr to multipliers
        {accel_farm_input.core2mul_int8[0].multiplicand, accel_farm_input.core2mul_int8[0].multiplier} = {accel_cr.cr_core2mul_int8_0[15:8], accel_cr.cr_core2mul_int8_0[7:0]};


        {accel_farm_input.core2mul_int8[1].multiplicand, accel_farm_input.core2mul_int8[1].multiplier} = {accel_cr.cr_core2mul_int8_1[15:8], accel_cr.cr_core2mul_int8_1[7:0]};

        {accel_farm_input.core2mul_int8[2].multiplicand, accel_farm_input.core2mul_int8[2].multiplier} = {accel_cr.cr_core2mul_int8_2[15:8], accel_cr.cr_core2mul_int8_2[7:0]};

        {accel_farm_input.core2mul_int8[3].multiplicand, accel_farm_input.core2mul_int8[3].multiplier} = { accel_cr.cr_core2mul_int8_3[15:8], accel_cr.cr_core2mul_int8_3[7:0]};                                                                                                                                                                                                                                                                                                                                 
        
        {accel_farm_input.core2mul_int8[4].multiplicand, accel_farm_input.core2mul_int8[4].multiplier} = {accel_cr.cr_core2mul_int8_4[15:8], accel_cr.cr_core2mul_int8_4[7:0]};
        
        {accel_farm_input.core2mul_int8[5].multiplicand, accel_farm_input.core2mul_int8[5].multiplier} = {accel_cr.cr_core2mul_int8_5[15:8], accel_cr.cr_core2mul_int8_5[7:0]};
        
        {accel_farm_input.core2mul_int8[6].multiplicand, accel_farm_input.core2mul_int8[6].multiplier} = {accel_cr.cr_core2mul_int8_6[15:8], accel_cr.cr_core2mul_int8_6[7:0]};
        
        {accel_farm_input.core2mul_int8[7].multiplicand, accel_farm_input.core2mul_int8[7].multiplier} = {accel_cr.cr_core2mul_int8_7[15:8], accel_cr.cr_core2mul_int8_7[7:0]};
       
end

`MAFIA_RST_DFF(q, pre_q, Clk, Rst)

endmodule // Module 