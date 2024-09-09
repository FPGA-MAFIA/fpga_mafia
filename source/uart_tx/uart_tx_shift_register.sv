//-----------------------------------------------------------------------------
// Title            : 8 bits shift register
// Project          : design of a uart transmiter
//-----------------------------------------------------------------------------
// File             : uart_tx_shift_register.sv
// Original Author  : Morin Binyamin
// Code Owner       : Morin Binyamin
// Created          : 9/2024
//-----------------------------------------------------------------------------
// Description : 8 bits shift register
//-----------------------------------------------------------------------------


module uart_tx_shift_register
import uart_tx_pkg::*;
(
    input logic       clk,
    input logic       resetN,
    input logic [7:0] data_in, 
    input logic       pre_load,
    input logic       shift_en,
    output logic      dint
);

logic [7:0] data;

always_ff @(posedge clk or negedge resetN) begin
    if(!resetN) begin
        data <= '0;
    end
    else if(pre_load) begin
        data <= data_in;
    end
    else if(shift_en) begin
        data <= {1'b0, data[7:1]};
    end
end

assign dint = data[0];

endmodule