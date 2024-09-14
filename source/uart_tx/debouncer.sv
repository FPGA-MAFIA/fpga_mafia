//-----------------------------------------------------------------------------
// Title            : debouncer
// Project          : design of a uart transmiter
//-----------------------------------------------------------------------------
// File             : debouncer.sv
// Original Author  : Morin Binyamin
// Code Owner       : Morin Binyamin
// Created          : 9/2024
//-----------------------------------------------------------------------------
// Description : bush button debouncer
// RTL schematics :https://www.fpga4student.com/2017/04/simple-debouncing-verilog-code-for.html
//-----------------------------------------------------------------------------

module debouncer
import uart_tx_pkg::*;
#(parameter CLK_DIVIDER = 499999) // division of the clock by 2*499999 + 2
(
    input logic  clk,
    input logic  resetN,
    input logic  trigger_in,
    output logic trigger_out

);


logic slow_clk, next_slow_clk;
logic [$clog2(CLK_DIVIDER):0] counter, next_counter;

always_ff@(posedge clk or negedge resetN) begin :clk_register_logic
    if(!resetN) begin
        counter  <= 0;
        slow_clk <= 0;
    end
    // In that logic we devide the clock by (2*(CLK_DEVIDER+1)) FIXME - possibly refactor to make it easier 
    // counter <= (counter == CLK_DIVIDER) ? 0 : counter + 1;
    // slow_clk <= (slow_clk == CLK_DIVIDER/2) ? ~slow_clk : slow_clk;
    else begin
        counter  <= next_counter;   
        slow_clk <= next_slow_clk;  
    end
end

always_comb begin : clk_divider_next_logic
    next_counter  = counter;
    next_slow_clk = slow_clk;
    if(counter == CLK_DIVIDER) begin
        next_counter  = 0;
        next_slow_clk = ~slow_clk; 
    end
    else begin
        next_counter = counter + 1;
    end
end


logic q1, q2;
always_ff@(posedge slow_clk or negedge resetN) begin :debouncer_logic
    if(!resetN) begin
        q1 <= 0;
        q2 <= 0;
    end
    else begin
        q1 <= trigger_in;
        q2 <= q1;
    end
end

assign trigger_out = (q1 & !q2);


endmodule
