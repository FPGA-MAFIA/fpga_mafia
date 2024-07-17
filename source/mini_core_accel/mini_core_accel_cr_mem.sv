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
    input  var t_mul_core_rsp  mul_core_rsp,
    output var t_core_mul_req  core_mul_req 
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
        // all mul cr's will be initialized with multiplier and multiplicant with int8 size
          CR_MUL_0      : next_accel_cr.cr_mul_0[15:0] = data[15:0]; 
          CR_MUL_1      : next_accel_cr.cr_mul_1[15:0] = data[15:0];
          CR_MUL_2      : next_accel_cr.cr_mul_2[15:0] = data[15:0];
          CR_MUL_3      : next_accel_cr.cr_mul_3[15:0] = data[15:0];
          CR_MUL_4      : next_accel_cr.cr_mul_4[15:0] = data[15:0];
          CR_MUL_5      : next_accel_cr.cr_mul_5[15:0] = data[15:0];
          CR_MUL_6      : next_accel_cr.cr_mul_6[15:0] = data[15:0];
          CR_MUL_7      : next_accel_cr.cr_mul_7[15:0] = data[15:0];
          //in cr_mul_ctrl reg the even index is the data valid(start) from core to multipliers
          CR_MUL_CTRL   : next_accel_cr.cr_mul_ctrl    = data;
          default       : next_accel_cr.cr_mul_ctrl    = 32'b0;
        endcase
        // data comming from the multipliers with the result and valid of the result
        next_accel_cr.cr_mul_0[31:16] = mul_core_rsp.mul0.result;
        next_accel_cr.cr_mul_1[31:16] = mul_core_rsp.mul1.result;
        next_accel_cr.cr_mul_2[31:16] = mul_core_rsp.mul2.result;
        next_accel_cr.cr_mul_3[31:16] = mul_core_rsp.mul3.result;
        next_accel_cr.cr_mul_4[31:16] = mul_core_rsp.mul4.result;
        next_accel_cr.cr_mul_5[31:16] = mul_core_rsp.mul5.result;
        next_accel_cr.cr_mul_6[31:16] = mul_core_rsp.mul6.result;
        next_accel_cr.cr_mul_7[31:16] = mul_core_rsp.mul7.result;
        // update when result is ready
        next_accel_cr.cr_mul_ctrl[1]   = mul_core_rsp.mul0.valid;
        next_accel_cr.cr_mul_ctrl[3]   = mul_core_rsp.mul1.valid;
        next_accel_cr.cr_mul_ctrl[5]   = mul_core_rsp.mul2.valid;
        next_accel_cr.cr_mul_ctrl[7]   = mul_core_rsp.mul3.valid;
        next_accel_cr.cr_mul_ctrl[9]   = mul_core_rsp.mul4.valid;
        next_accel_cr.cr_mul_ctrl[11]  = mul_core_rsp.mul5.valid;
        next_accel_cr.cr_mul_ctrl[13]  = mul_core_rsp.mul6.valid;
        next_accel_cr.cr_mul_ctrl[15]  = mul_core_rsp.mul7.valid;
    end

end

// reading data
always_comb begin : read_from_accel_cr
    if(rden) begin
        unique casez(address)
            CR_MUL_0    : pre_q = accel_cr.cr_mul_0;
            CR_MUL_1    : pre_q = accel_cr.cr_mul_1;
            CR_MUL_2    : pre_q = accel_cr.cr_mul_2;
            CR_MUL_3    : pre_q = accel_cr.cr_mul_3;
            CR_MUL_4    : pre_q = accel_cr.cr_mul_4;
            CR_MUL_5    : pre_q = accel_cr.cr_mul_5;
            CR_MUL_6    : pre_q = accel_cr.cr_mul_6;
            CR_MUL_7    : pre_q = accel_cr.cr_mul_7;
            CR_MUL_CTRL : pre_q = accel_cr.cr_mul_ctrl;
            default     : ; // do nothing 
        endcase
        //the odd index is the start bit of the multiplier
        core_mul_req.mul0.valid = accel_cr.cr_mul_ctrl[0];
        core_mul_req.mul1.valid = accel_cr.cr_mul_ctrl[2];
        core_mul_req.mul2.valid = accel_cr.cr_mul_ctrl[4];
        core_mul_req.mul3.valid = accel_cr.cr_mul_ctrl[6];
        core_mul_req.mul4.valid = accel_cr.cr_mul_ctrl[8];
        core_mul_req.mul5.valid = accel_cr.cr_mul_ctrl[10];
        core_mul_req.mul6.valid = accel_cr.cr_mul_ctrl[12];
        core_mul_req.mul7.valid = accel_cr.cr_mul_ctrl[14];
        // multiplier is reading the multiplicand
        core_mul_req.mul0.multiplicand = accel_cr.cr_mul_0[7:0];
        core_mul_req.mul1.multiplicand = accel_cr.cr_mul_1[7:0];
        core_mul_req.mul2.multiplicand = accel_cr.cr_mul_2[7:0];
        core_mul_req.mul3.multiplicand = accel_cr.cr_mul_3[7:0];
        core_mul_req.mul4.multiplicand = accel_cr.cr_mul_4[7:0];
        core_mul_req.mul5.multiplicand = accel_cr.cr_mul_5[7:0];
        core_mul_req.mul6.multiplicand = accel_cr.cr_mul_6[7:0];
        core_mul_req.mul7.multiplicand = accel_cr.cr_mul_7[7:0];
        // multiplier is reading the multiplier
        core_mul_req.mul0.multiplier = accel_cr.cr_mul_0[15:8];
        core_mul_req.mul1.multiplier = accel_cr.cr_mul_1[15:8];
        core_mul_req.mul2.multiplier = accel_cr.cr_mul_2[15:8];
        core_mul_req.mul3.multiplier = accel_cr.cr_mul_3[15:8];
        core_mul_req.mul4.multiplier = accel_cr.cr_mul_4[15:8];
        core_mul_req.mul5.multiplier = accel_cr.cr_mul_5[15:8];
        core_mul_req.mul6.multiplier = accel_cr.cr_mul_6[15:8];
        core_mul_req.mul7.multiplier = accel_cr.cr_mul_7[15:8];
    end
end

`MAFIA_DFF(q, pre_q, Clk)

endmodule // Module 