
`include "macros.vh"

module accel_core_mul_wrapper 
import accel_core_pkg::*;
(
    input logic Clock,
    input logic Rst,
    input logic clear,
    input logic start,
    input t_buffer_inout neuron_in,
    input t_buffer_weights w1,
    output logic signed [7:0] result,
    output logic out_valid
);
logic signed [WEIGHT_WIDTH-1:0] Mu;
logic signed [WEIGHT_WIDTH-1:0] Qu;
logic signed [2*WEIGHT_WIDTH-1:0] product;

shift_multiplier
  #(
    .M_width(WEIGHT_WIDTH),
    .Q_width(WEIGHT_WIDTH)
  )
  dut (
    .Clock(Clock),
    .Rst(Rst),
    .Mu(Mu),
    .Qu(Qu),
    .product(product)
  );

// Define state encoding
    typedef enum logic [1:0] {
        st_idle = 2'b00,
        st_wait = 2'b01,
        st_mac  = 2'b10,
        st_done = 2'b11
    } state_t;

    state_t current_state, next_state;
    logic unsigned [7:0] counter, counter2;
    parameter int c_mul_reaction_time=10;
    logic unsigned [7:0] mul_idx;
    logic done;
    logic signed [31:0] tmp_result;

    // Sequential logic: state register
    always_ff @(posedge Clock) begin
        if (Rst || clear) begin 
            tmp_result = 0;
            counter=0;
            counter2=0;
            mul_idx=0;
            done = 1'b0;
            current_state <= st_idle;  // Reset to idle state
        end 
        else begin
            //things that happen every everyclock
            done = 1'b0;
            current_state <= next_state;
            Mu = neuron_in.data[mul_idx];
            Qu = w1.data[mul_idx];
            mul_idx = mul_idx + 1;
            case (current_state) 
            st_idle: begin
                    tmp_result = w1.data[(w1.meta_data.data_len - 1)]; //the bias element is the last element in the weights vec
                    mul_idx = 0;
                    counter = c_mul_reaction_time - 1;
                end
            st_wait: begin
                counter=counter-1;
                if (counter == 0) begin
                    counter2 = w1.meta_data.data_len - 1;
                end
            end

            st_mac: begin
                tmp_result = tmp_result + product;
                counter2 = counter2 - 1;
            end
            st_done: begin 
                    done = 1'b1;  
                    if(tmp_result > 127) // saturation
                        tmp_result = 127;
                    else if (tmp_result < -128) 
                        tmp_result = -128;
            end 
        endcase
        end
    end

    // Combinational logic: next state logic
    always_comb begin
        // Default: hold the current state
        next_state = current_state;
        case (current_state)
            st_idle: begin
                if (start) begin
                    next_state = st_wait;  // Transition to wait state when start is asserted
                end
            end

            st_wait: begin
                if (counter == 0) begin
                    next_state = st_mac;
                end
            end

            st_mac: begin
                if (counter2 == 0) begin
                    next_state = st_done;
                end
            end

            st_done: begin
                next_state = st_idle;
            end

            default: next_state = st_idle;  // Default to idle state
        endcase
    end

assign out_valid = done;
assign result = tmp_result[7:0];
endmodule