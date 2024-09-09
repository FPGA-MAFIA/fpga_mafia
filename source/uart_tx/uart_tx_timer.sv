//-----------------------------------------------------------------------------
// Title            : baud rate timer
// Project          : design of a uart transmiter
//-----------------------------------------------------------------------------
// File             : uart_tx_shift_register.sv
// Original Author  : Morin Binyamin
// Code Owner       : Morin Binyamin
// Created          : 9/2024
//-----------------------------------------------------------------------------
// Description : generate signle coresponding to boud rate of 11520
//-----------------------------------------------------------------------------

module uart_tx_timer
import uart_tx_pkg::*;
#(parameter MAX_VALUE = N_TIMER)
(
    input logic  clk,
    input logic  te,  // when te=0 timer clears. when te=1 timer counts
    input logic  resetN, 
    output logic t1

);

logic [$clog2(MAX_VALUE)-1:0] timer, next_timer;

always_ff @(posedge clk or negedge resetN) begin: counter_ff
        if(!resetN) begin
            timer <= '0;
        end
        else begin
            timer <= next_timer;
        end
end

logic inc_en, inc_dis;
assign inc_en  = te && (timer <= MAX_VALUE);
assign inc_dis = te && (timer > MAX_VALUE);

always_comb begin
    next_timer = timer;
    if(!te) begin
        next_timer = 0;
    end
    if(inc_en) begin
        next_timer = timer + 1;
    end
    if(inc_dis) begin
        next_timer = timer;
    end
end

assign t1 = (timer > MAX_VALUE) ? 1'b1 : 1'b0;


endmodule