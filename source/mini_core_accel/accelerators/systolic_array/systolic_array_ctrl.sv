`include "macros.vh"

module systolic_array_ctrl
import mini_core_accel_pkg::*;
(
    input logic             clk,
    input logic             rst,
    input logic [127:0]     all_weights,      // hard wired to cr's
    input logic [127:0]     all_activations,  // hard wired to cr's
    input logic             start,         // hard wired to cr
    output logic            valid,            // hard wired to cr data is valid 
    output var t_pe_results pe_results

);
 
logic [31:0] weights;
logic [31:0] activation;
logic        first_done; 

//-----------------------------------
//         Systolic 4x4 grid
//----------------------------------- 
systolic_array_net systolic_array_net
(
    .clk(clk),
    .rst(rst),
    .weights(weights),     
    .activation(activation),  
    .first_done(first_done),  
    .start(start),
    .pe_results(pe_results),
    .valid(valid)        
);

t_systolic_array_ctrl_states state, next_state;

//state register
`MAFIA_RST_VAL_DFF(state, next_state, clk, (rst || !start), IDLE)

always_comb begin: next_state_logic
    next_state = state;
    case(state)
        IDLE: begin
            if(!start)
                next_state = IDLE;
            else
                next_state = STEP0;
        end
        STEP0: begin
            next_state = STEP1;
        end
        STEP1: begin
            next_state = STEP2;
        end
        STEP2: begin
            next_state = STEP3;
        end
        STEP3: begin
            next_state = STEP4;
        end
        STEP4: begin
            next_state = STEP5;
        end
        STEP5: begin
            next_state = STEP6;
        end
        STEP6: begin
            next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end

always_comb begin: outputs
    weights    = '0;
    activation = '0;
    first_done =  0;
        case(state)
        IDLE: begin
            ;// do nothing 
        end
        STEP0: begin
            weights    = {8'h0, 8'h0, 8'h0, all_weights[7:0]};
            activation = {8'h0, 8'h0, 8'h0, all_activations[7:0]};
        end
        STEP1: begin
            weights    = {8'h0, 8'h0, all_weights[23:16], all_weights[15:8]};
            activation = {8'h0, 8'h0, all_activations[23:16], all_activations[23:16]};
        end
        STEP2: begin
            weights    = {8'h0, all_weights[47:40], all_weights[39:32], all_weights[31:24]};
            activation = {8'h0, all_activations[47:40], all_activations[39:32], all_activations[31:24]};
        end
        STEP3: begin
            first_done = 1;
            weights    = {all_weights[79:72], all_weights[71:64], all_weights[63:56], all_weights[55:48]};
            activation = {all_activations[79:72], all_activations[71:64], all_activations[63:56], all_activations[55:48]};
        end
        STEP4: begin
            first_done = 1;
            weights    = {all_weights[103:96], all_weights[95:88], all_weights[87:80], 8'h0};
            activation = {all_activations[103:96], all_activations[95:88], all_activations[87:80], 8'h0};
        end
        STEP5: begin
            first_done = 1;
            weights    = {all_weights[119:112], all_weights[111:104], 8'h0, 8'h0};
            activation = {all_activations[119:112], all_activations[111:104], 8'h0, 8'h0};
        end
        STEP6: begin
            first_done = 1;
            weights    = {all_weights[127:0], 8'h0, 8'h0, 8'h0};
            activation = {all_activations[127:120], 8'h0, 8'h0, 8'h0};
        end
        default: ; //do nothing;
    endcase
end

endmodule