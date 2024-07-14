//-----------------------------------------------------------------------------
// Title            : booth multiplier
// Project          : mini_core_accelerator
//-----------------------------------------------------------------------------
// File             : booth_multiplier
// Original Author  : 
// Code Owner       : 
// Created          :
//-----------------------------------------------------------------------------
// Description : 8 bit signed multiplier
//-----------------------------------------------------------------------------
`include "macros.vh"

module booth_multiplier
import mini_core_accel_pkg::*;
import mini_core_pkg::*;
(
    input logic                     clock,
    input logic                     rst,
    input var t_booth_mul_req       input_req,
    output var t_booth_output       output_rsp,
    output logic                    busy

);

t_booth_states              state, next_state;
logic [2*NUM_WIDTH:0]       acc_multiplier_lsb, next_acc_multiplier_lsb; 
logic [$clog2(NUM_WIDTH):0] itr_num, next_itr_num;
int8                        multiplicand, next_multiplicand;


// state machine logic and state transitions
always_comb begin: state_machine
    next_state              = state;
    next_itr_num            = itr_num;
    next_acc_multiplier_lsb = acc_multiplier_lsb;
    next_multiplicand       = multiplicand;
    case(state) 
        IDLE: begin
            if(input_req.valid) begin
                next_state              = SUB_OR_ADD_AM;
                next_multiplicand       = input_req.multiplicand;  // store multiplicand
                next_acc_multiplier_lsb = {{(NUM_WIDTH){1'b0}}, input_req.multiplier, 1'b0}; 
            end
            else begin
                next_state = IDLE;
            end
        end
        SUB_OR_ADD_AM: begin
            if(acc_multiplier_lsb[1:0] == 2'b01) begin
                next_acc_multiplier_lsb[2*NUM_WIDTH:NUM_WIDTH+1] = acc_multiplier_lsb[2*NUM_WIDTH:NUM_WIDTH+1] + multiplicand;
            end
            else if(acc_multiplier_lsb[1:0] == 2'b10) begin
                next_acc_multiplier_lsb[2*NUM_WIDTH:NUM_WIDTH+1] = acc_multiplier_lsb[2*NUM_WIDTH:NUM_WIDTH+1] + ~multiplicand + 1'b1;
            end
            // in any case we go to the next atate
            next_state   = ARITHMETIC_SHIFT_RIGHT;
            next_itr_num = itr_num - 1;
        end
        ARITHMETIC_SHIFT_RIGHT: begin
            next_acc_multiplier_lsb = $signed(acc_multiplier_lsb) >>> 1; 
            if(itr_num != 0) begin
                    next_state = SUB_OR_ADD_AM;
            end
            else begin
                next_state = IDLE;
            end
        end

    endcase

end

// output logic
assign output_rsp.valid  = ((state == ARITHMETIC_SHIFT_RIGHT) && (itr_num == 0)) ? 1'b1                                   : 1'b0;
// in our implementation the accumulator has NUM_WIDTH bits. When the multiplicand equals -128 it causes overflow and the result is incorrect.
// I have added a fix by multiplying it by 1.
// FIXME - consider implementing in differente implementation to avoid that 
assign output_rsp.result = ((state == ARITHMETIC_SHIFT_RIGHT) && (itr_num == 0) && (multiplicand == -8'd128)) ? ~next_acc_multiplier_lsb[2*NUM_WIDTH:1] + 1 :
                           ((state == ARITHMETIC_SHIFT_RIGHT) && (itr_num == 0))                              ?  next_acc_multiplier_lsb[2*NUM_WIDTH:1]     :
                                                                                                                                                        1'b0;      // FIXME refactor the acc_multiplier_lsb
assign busy = (state == IDLE) ? 1'b0 : 1'b1;

logic rst_itr_num_en;
assign rst_itr_num_en = rst || (state == IDLE);

`MAFIA_DFF(multiplicand, next_multiplicand, clock)
`MAFIA_RST_VAL_DFF(state, next_state, clock, rst, IDLE)
`MAFIA_RST_VAL_DFF(itr_num, next_itr_num, clock, rst_itr_num_en, NUM_WIDTH) 
`MAFIA_RST_DFF(acc_multiplier_lsb, next_acc_multiplier_lsb, clock, rst)

endmodule