//-------------------------------------------------------------------------------
// Title            : uart_tx controller
// Project          : design of a uart transmiter
//-------------------------------------------------------------------------------
// File             : uart_tx_pkg.sv
// Original Author  : Morin Binyamin
// Code Owner       : Morin Binyamin
// Created          : 9/2024
//-------------------------------------------------------------------------------
// Description : UART cpntroller
//-------------------------------------------------------------------------------


module uart_tx_ctrl
import uart_tx_pkg::*;
(
    input logic                    clk,
    input logic                    resetN,
    input logic                    write_din,
    input var t_uart_tx_ctrl_in    uart_tx_ctrl_in,
    output var t_uart_tx_ctrl_out  uart_tx_ctrl_out
);


t_states state, next_state;

always_ff @(posedge clk or negedge resetN) begin: state_register
    if(!resetN) begin
        state <= IDLE;
    end  
    else begin
        state <= next_state;
    end
end

always_comb begin: next_state_logic
    next_state = state;
    case(state)
        IDLE: begin
            if(!write_din)
                next_state = IDLE;
            else if(write_din)
                next_state = SEND_START;    
        end
        SEND_START: begin
            if(!(uart_tx_ctrl_in.t1))
                next_state = SEND_START;
            else if(uart_tx_ctrl_in.t1)
                next_state = CLEAR_TIMER;
        end
        CLEAR_TIMER: begin
            next_state = SEND_DATA;
        end
        SEND_DATA: begin
            if(!(uart_tx_ctrl_in.t1))
                next_state = SEND_DATA;
            else if(uart_tx_ctrl_in.t1)
                next_state = TEST_EOC;
        end
        TEST_EOC: begin
            if(!(uart_tx_ctrl_in.eoc_dcount))
                next_state = SHIFT_COUNT;
            else if(uart_tx_ctrl_in.eoc_dcount)
                next_state = SEND_STOP;
        end
        SHIFT_COUNT: begin
            next_state = SEND_DATA;
        end
        SEND_STOP: begin
            if(!(uart_tx_ctrl_in.t1))
                next_state = SEND_STOP;
            else if(uart_tx_ctrl_in.t1)
                next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end

always_comb begin : output_logic
    uart_tx_ctrl_out = '0;
    case(state)
        IDLE: begin
            uart_tx_ctrl_out.ena_load   = 1;
            uart_tx_ctrl_out.clr_dcount = 1;
            uart_tx_ctrl_out.set_tx     = 1;   // in IDLE transmit '1'
        end
        SEND_START: begin
            uart_tx_ctrl_out.te     = 1;
            uart_tx_ctrl_out.clr_tx = 1;
        end
        SEND_DATA: begin
            uart_tx_ctrl_out.te     = 1;
            uart_tx_ctrl_out.ena_tx = 1;  
        end
        SHIFT_COUNT: begin
            uart_tx_ctrl_out.ena_shift  = 1;
            uart_tx_ctrl_out.ena_dcount = 1;
        end
        SEND_STOP: begin
            uart_tx_ctrl_out.te     = 1;
            uart_tx_ctrl_out.set_tx = 1;
        end
    endcase
end


endmodule