//-------------------------------------------------------------------------------
// Title            : uart_tx output flip flop
// Project          : design of a uart transmiter
//-------------------------------------------------------------------------------
// File             : uart_tx_pkg.sv
// Original Author  : Morin Binyamin
// Code Owner       : Morin Binyamin
// Created          : 9/2024
//-------------------------------------------------------------------------------
// Description : output ff with asynchronous rst. synchronous set, enable, clr(R)
//-------------------------------------------------------------------------------

module uart_tx_output_ff
import uart_tx_pkg::*;(
    input logic  clk,
    input logic  resetN, 
    input logic  set,
    input logic  enable,
    input logic  data_in, 
    input logic  clear,
    output logic data_out 

);

always_ff @(posedge clk or negedge resetN) begin
    if(!resetN) begin
        data_out <= 0;
    end
    else if(clear) begin  // synchronous clear
        data_out <= 0;  
    end
    else if(set) begin  // synchronous set
        data_out <= 1;
    end
    else if(enable) begin
        data_out <= data_in;
    end
end

endmodule