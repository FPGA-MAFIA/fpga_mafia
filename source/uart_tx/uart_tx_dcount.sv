//-----------------------------------------------------------------------------
// Title            : dcount
// Project          : design of a uart transmiter
//-----------------------------------------------------------------------------
// File             : uart_tx_shift_register.sv
// Original Author  : Morin Binyamin
// Code Owner       : Morin Binyamin
// Created          : 9/2024
//-----------------------------------------------------------------------------
// Description : count from 0-7
//-----------------------------------------------------------------------------
module uart_tx_dcount 
import uart_tx_pkg::*;
(
    input logic  clk,
    input logic  resetN,
    input logic  en_cnt,
    input logic  clr,
    output logic eoc_dcount
);

logic [2:0] counter;

always_ff @(posedge clk or negedge resetN) begin
    if(!resetN || clr) begin
        counter <= 'b0;
    end
    else if(en_cnt) begin
        counter <= counter + 1;
    end

end

assign eoc_dcount = (counter == 3'h7) ? 1'b1 : 1'b0;


endmodule