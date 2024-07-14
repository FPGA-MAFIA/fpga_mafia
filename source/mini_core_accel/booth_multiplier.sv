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
    input logic                     Clock,
    input logic                     Rst,
    input var t_booth_mul_req       InputReq,
    output var t_booth_output       OutputRsp

);

t_booth_states State, NextState;
logic [2*NUM_WIDTH:0]  AccMultiplierLsb, NextAccMultiplierLsb; 
logic [$clog2(NUM_WIDTH):0] ItrNum, NextItrNum;
logic [NUM_WIDTH-1:0] Multiplicand, NextMultiplicand;

`MAFIA_DFF(Multiplicand, NextMultiplicand, Clock)
`MAFIA_RST_VAL_DFF(State, NextState, Clock, Rst, IDLE)
`MAFIA_RST_VAL_DFF(ItrNum,NextItrNum, Clock, Rst || (State == IDLE), NUM_WIDTH) 
`MAFIA_RST_DFF(AccMultiplierLsb, NextAccMultiplierLsb, Clock, Rst)

assign OutputRsp.Valid  = ((State == ARITHMETIC_SHIFT_RIGHT) && (ItrNum == 0)) ? 1'b1                                : 1'b0;
assign OutputRsp.Result = ((State == ARITHMETIC_SHIFT_RIGHT) && (ItrNum == 0)) ? NextAccMultiplierLsb[2*NUM_WIDTH:1] : 0;   // FIXME refactor to AccMultiplierLsb

always_comb begin: state_machine
    NextState            = State;
    NextItrNum           = ItrNum;
    NextAccMultiplierLsb = AccMultiplierLsb;
    NextMultiplicand     = Multiplicand;
    case(State) 
        IDLE: begin
            if(InputReq.Valid) begin
                NextState            = SUB_OR_ADD_AM;
                NextMultiplicand     = InputReq.Multiplicand;  // store multiplicand
                NextAccMultiplierLsb = {{(NUM_WIDTH){1'b0}}, InputReq.Multiplier, 1'b0}; 
            end
            else begin
                NextState = IDLE;
            end
        end
        SUB_OR_ADD_AM: begin
            if(AccMultiplierLsb[1:0] == 2'b01) begin
                NextAccMultiplierLsb[2*NUM_WIDTH:NUM_WIDTH+1] = AccMultiplierLsb[2*NUM_WIDTH:NUM_WIDTH+1] + Multiplicand;
            end
            else if(AccMultiplierLsb[1:0] == 2'b10) begin
                NextAccMultiplierLsb[2*NUM_WIDTH:NUM_WIDTH+1] = AccMultiplierLsb[2*NUM_WIDTH:NUM_WIDTH+1] + ~Multiplicand + 1'b1;
            end
            // in any case we go to the next atate
            NextState  = ARITHMETIC_SHIFT_RIGHT;
            NextItrNum = NextItrNum - 1;
        end
        ARITHMETIC_SHIFT_RIGHT: begin
            NextAccMultiplierLsb = $signed(AccMultiplierLsb) >>> 1; 
            if(ItrNum != 0) begin
                    NextState = SUB_OR_ADD_AM;
            end
            else begin
                NextState = IDLE;
            end
        end

    endcase

end


endmodule