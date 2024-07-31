`include "macros.vh"
// implementation of booth multiplier wor int8 input numbers

module multiplier_int8
import mini_core_accel_pkg::*;
(
    input logic                  clock,
    input logic                  rst,
    input var t_mul_int8_input   pre_mul_int_8_input, // we compare between present and new inputs to start activating the multiplier
    output var t_mul_int8_output mul_int8_output
);

t_mul_int8_states                state, n_state;
int8                             multiplicand, multiplier;
logic [2*NUM_WIDTH_INT8:0]       acc_multiplier_lsb, n_acc_multiplier_lsb;
logic [$clog2(NUM_WIDTH_INT8):0] itr_num, n_itr_num;

logic  start_computation;
assign start_computation  = (pre_mul_int_8_input.multiplicand != multiplicand) || (pre_mul_int_8_input.multiplier != multiplier);

always_comb begin: state_transition
    n_state = state;
    case(state)
        PRE_START: begin
            if(start_computation) begin
                n_state = PRE_START;
            end
            else begin
                n_state = COMPUTE; 
            end
        end
        COMPUTE: begin
            if(itr_num == 1) begin // we dont count zero
                n_state = DONE;
            end
            else if(start_computation) begin
                n_state = PRE_START;
            end
            else begin
                n_state = COMPUTE;
            end
        end
        DONE: begin
            if(start_computation) begin
                n_state = PRE_START;
            end
            else begin
                n_state = DONE;
            end
        end
        default: ; //do nothing  
    endcase
end

// state machine inner logic
always_comb begin: state_machine
    n_itr_num  = itr_num;
    n_acc_multiplier_lsb = acc_multiplier_lsb;
    case(state)
        PRE_START: begin
            n_acc_multiplier_lsb = {{(NUM_WIDTH_INT8){1'b0}}, multiplier, 1'b0};
            n_itr_num            =  NUM_WIDTH_INT8;
        end
        COMPUTE: begin
            if(acc_multiplier_lsb[1:0] == 2'b01) begin
                n_acc_multiplier_lsb = $signed({acc_multiplier_lsb[2*NUM_WIDTH_INT8:NUM_WIDTH_INT8+1] + multiplicand, acc_multiplier_lsb[NUM_WIDTH_INT8:0]}) >>> 1 ;
            end
            else if(acc_multiplier_lsb[1:0] == 2'b10) begin
                 n_acc_multiplier_lsb = $signed({acc_multiplier_lsb[2*NUM_WIDTH_INT8:NUM_WIDTH_INT8+1] + ~multiplicand + 1'b1, acc_multiplier_lsb[NUM_WIDTH_INT8:0]}) >>> 1 ;
            end
            else begin
                n_acc_multiplier_lsb = $signed(acc_multiplier_lsb) >>> 1;
            end
            // dec by one in any case
            n_itr_num = itr_num - 1;
        end
        DONE: begin
            // see assign 
        end
        default: ; // do nothing
    endcase
end


assign mul_int8_output.done   = (state == DONE) ? 1'b1 : 1'b0;
// in our implementation the accumulator has NUM_WIDTH_INT8 bits. When the multiplicand equals -128 it causes overflow and the result is incorrect.
// I have added a fix by multiplying it by 1.
// FIXME - consider implementing in differente implementation to avoid that 
assign mul_int8_output.result = ((state == DONE) && (multiplicand == -8'd128)) ? ~acc_multiplier_lsb[2*NUM_WIDTH_INT8:1] + 1 :
                                (state == DONE)                                ?  acc_multiplier_lsb[2*NUM_WIDTH_INT8:1]     :
                                                                                                                         1'b0;  

`MAFIA_RST_VAL_DFF(state, n_state, clock, rst, DONE)

// we sample the inputs once the input changed it triggers the multiplier to start calculations
`MAFIA_RST_DFF(multiplicand, pre_mul_int_8_input.multiplicand, clock, rst)
`MAFIA_RST_DFF(multiplier, pre_mul_int_8_input.multiplier, clock, rst)
`MAFIA_RST_DFF(itr_num, n_itr_num, clock, rst)
`MAFIA_RST_DFF(acc_multiplier_lsb, n_acc_multiplier_lsb, clock, rst)
`MAFIA_RST_VAL_DFF(itr_num, n_itr_num, clock, rst, NUM_WIDTH_INT8)




endmodule