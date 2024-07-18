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
    input  var t_mul2core_rsp  mul2core_rsp,
    output var t_core2mul_req  core2mul_req 
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
        // each CR_CORE2MUL_I concantinated with {start, multiplicand, multiplier}
          CR_CORE2MUL_0      : next_accel_cr.cr_core2mul_0   = data[16:0]; 
          CR_CORE2MUL_1      : next_accel_cr.cr_core2mul_1   = data[16:0];
          CR_CORE2MUL_2      : next_accel_cr.cr_core2mul_2   = data[16:0];
          CR_CORE2MUL_3      : next_accel_cr.cr_core2mul_3   = data[16:0];
          CR_CORE2MUL_4      : next_accel_cr.cr_core2mul_4   = data[16:0];
          CR_CORE2MUL_5      : next_accel_cr.cr_core2mul_5   = data[16:0];
          CR_CORE2MUL_6      : next_accel_cr.cr_core2mul_6   = data[16:0];
          CR_CORE2MUL_7      : next_accel_cr.cr_core2mul_7   = data[16:0];
          default            : ; // do nothing
        endcase
        // hard wired 
        next_accel_cr.cr_mul2core_0 = {mul2core_rsp.mul2core[0].busy, mul2core_rsp.mul2core[0].valid, mul2core_rsp.mul2core[0].result};
        next_accel_cr.cr_mul2core_1 = {mul2core_rsp.mul2core[1].busy, mul2core_rsp.mul2core[1].valid, mul2core_rsp.mul2core[1].result};
        next_accel_cr.cr_mul2core_2 = {mul2core_rsp.mul2core[2].busy, mul2core_rsp.mul2core[2].valid, mul2core_rsp.mul2core[2].result};
        next_accel_cr.cr_mul2core_3 = {mul2core_rsp.mul2core[3].busy, mul2core_rsp.mul2core[3].valid, mul2core_rsp.mul2core[3].result};
        next_accel_cr.cr_mul2core_4 = {mul2core_rsp.mul2core[4].busy, mul2core_rsp.mul2core[4].valid, mul2core_rsp.mul2core[4].result};
        next_accel_cr.cr_mul2core_5 = {mul2core_rsp.mul2core[5].busy, mul2core_rsp.mul2core[5].valid, mul2core_rsp.mul2core[5].result};
        next_accel_cr.cr_mul2core_6 = {mul2core_rsp.mul2core[6].busy, mul2core_rsp.mul2core[6].valid, mul2core_rsp.mul2core[6].result};
        next_accel_cr.cr_mul2core_7 = {mul2core_rsp.mul2core[7].busy, mul2core_rsp.mul2core[7].valid, mul2core_rsp.mul2core[7].result};

    end
end

// reading data
always_comb begin : read_from_accel_cr
    pre_q = 0;
    if(rden) begin
        unique casez(address)
            CR_MUL2CORE_0     : pre_q = accel_cr.cr_mul2core_0;
            CR_MUL2CORE_1     : pre_q = accel_cr.cr_mul2core_1;
            CR_MUL2CORE_2     : pre_q = accel_cr.cr_mul2core_2;
            CR_MUL2CORE_3     : pre_q = accel_cr.cr_mul2core_3;
            CR_MUL2CORE_4     : pre_q = accel_cr.cr_mul2core_4;
            CR_MUL2CORE_5     : pre_q = accel_cr.cr_mul2core_5;
            CR_MUL2CORE_6     : pre_q = accel_cr.cr_mul2core_6;
            CR_MUL2CORE_7     : pre_q = accel_cr.cr_mul2core_7;
            default      : ; // do nothing 
        endcase

        // hard wired from cr to multipliers
        {core2mul_req.core2mul[0].valid, core2mul_req.core2mul[0].multiplier, core2mul_req.core2mul[0].multiplicand} = {accel_cr.cr_core2mul_0[16], 
                                                                                                                        accel_cr.cr_core2mul_0[7:0],
                                                                                                                        accel_cr.cr_core2mul_0[15:8]};


        {core2mul_req.core2mul[1].valid, core2mul_req.core2mul[1].multiplier, core2mul_req.core2mul[1].multiplicand} = {accel_cr.cr_core2mul_1[16], 
                                                                                                                        accel_cr.cr_core2mul_1[7:0],
                                                                                                                        accel_cr.cr_core2mul_1[15:8]};

        {core2mul_req.core2mul[2].valid, core2mul_req.core2mul[2].multiplier, core2mul_req.core2mul[2].multiplicand} = {accel_cr.cr_core2mul_2[16], 
                                                                                                                        accel_cr.cr_core2mul_2[7:0],
                                                                                                                        accel_cr.cr_core2mul_2[15:8]};

        {core2mul_req.core2mul[3].valid, core2mul_req.core2mul[3].multiplier, core2mul_req.core2mul[3].multiplicand} = {accel_cr.cr_core2mul_3[16], 
                                                                                                                        accel_cr.cr_core2mul_3[7:0],
                                                                                                                        accel_cr.cr_core2mul_3[15:8]};                                                                                                                                                                                                                                                                                                                                 
        
        {core2mul_req.core2mul[4].valid, core2mul_req.core2mul[4].multiplier, core2mul_req.core2mul[4].multiplicand} = {accel_cr.cr_core2mul_4[16], 
                                                                                                                        accel_cr.cr_core2mul_4[7:0],
                                                                                                                        accel_cr.cr_core2mul_4[15:8]};
        
        {core2mul_req.core2mul[5].valid, core2mul_req.core2mul[5].multiplier, core2mul_req.core2mul[5].multiplicand} = {accel_cr.cr_core2mul_5[16], 
                                                                                                                        accel_cr.cr_core2mul_5[7:0],
                                                                                                                        accel_cr.cr_core2mul_5[15:8]};
        
        {core2mul_req.core2mul[6].valid, core2mul_req.core2mul[6].multiplier, core2mul_req.core2mul[6].multiplicand} = {accel_cr.cr_core2mul_6[16], 
                                                                                                                        accel_cr.cr_core2mul_6[7:0],
                                                                                                                        accel_cr.cr_core2mul_6[15:8]};
        
        {core2mul_req.core2mul[7].valid, core2mul_req.core2mul[7].multiplier, core2mul_req.core2mul[7].multiplicand} = {accel_cr.cr_core2mul_7[16], 
                                                                                                                        accel_cr.cr_core2mul_7[7:0],
                                                                                                                        accel_cr.cr_core2mul_7[15:8]};
        /*
        // TODO possible refactor is needed to use less lines
        core2mul_req.core2mul0.valid = accel_cr.cr_core2mul_0[16];
        core2mul_req.core2mul1.valid = accel_cr.cr_core2mul_1[16];
        core2mul_req.core2mul2.valid = accel_cr.cr_core2mul_2[16];
        core2mul_req.core2mul3.valid = accel_cr.cr_core2mul_3[16];
        core2mul_req.core2mul4.valid = accel_cr.cr_core2mul_4[16];
        core2mul_req.core2mul5.valid = accel_cr.cr_core2mul_5[16];
        core2mul_req.core2mul6.valid = accel_cr.cr_core2mul_6[16];
        core2mul_req.core2mul7.valid = accel_cr.cr_core2mul_7[16];
        // multiplier is recieving the multiplier
        core2mul_req.core2mul0.multiplier = accel_cr.cr_core2mul_0[7:0];
        core2mul_req.core2mul1.multiplier = accel_cr.cr_core2mul_1[7:0];
        core2mul_req.core2mul2.multiplier = accel_cr.cr_core2mul_2[7:0];
        core2mul_req.core2mul3.multiplier = accel_cr.cr_core2mul_3[7:0];
        core2mul_req.core2mul4.multiplier = accel_cr.cr_core2mul_4[7:0];
        core2mul_req.core2mul5.multiplier = accel_cr.cr_core2mul_5[7:0];
        core2mul_req.core2mul6.multiplier = accel_cr.cr_core2mul_6[7:0];
        core2mul_req.core2mul7.multiplier = accel_cr.cr_core2mul_7[7:0];
        // multiplier is recieving the multiplicand
        core2mul_req.core2mul0.multiplicand = accel_cr.cr_core2mul_0[15:8];
        core2mul_req.core2mul1.multiplicand = accel_cr.cr_core2mul_1[15:8];
        core2mul_req.core2mul2.multiplicand = accel_cr.cr_core2mul_2[15:8];
        core2mul_req.core2mul3.multiplicand = accel_cr.cr_core2mul_3[15:8];
        core2mul_req.core2mul4.multiplicand = accel_cr.cr_core2mul_4[15:8];
        core2mul_req.core2mul5.multiplicand = accel_cr.cr_core2mul_5[15:8];
        core2mul_req.core2mul6.multiplicand = accel_cr.cr_core2mul_6[15:8];
        core2mul_req.core2mul7.multiplicand = accel_cr.cr_core2mul_7[15:8];
        */
        
    end
end

`MAFIA_DFF(q, pre_q, Clk)

endmodule // Module 