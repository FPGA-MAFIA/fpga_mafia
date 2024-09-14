//-----------------------------------------------------------------------------
// Title            : uart_tx de2 top
// Project          : design of a uart transmiter
//-----------------------------------------------------------------------------
// File             : uart_tx_de2_top.sv
// Original Author  : Morin Binyamin
// Code Owner       : Morin Binyamin
// Created          : 9/2024
//-----------------------------------------------------------------------------
// Description : top module to run the uart_tx on de2 fpga board
//-----------------------------------------------------------------------------

module uart_tx_de2_top
import uart_tx_pkg::*;
(
    input logic       clk50Mhz,
    input logic       resetN,
    input logic [7:0] din,
    input logic       write_din,
    output logic      tx,
    output logic      tx_ready
);


logic resetN_debounced;
logic write_din_debounced;

uart_tx_top 
#(.MAX_TIMER_VALUE(N_TIMER))
uart_tx_top
(
    .clk(clk50Mhz),
    .resetN(resetN_debounced),
    .din(din), 
    .write_din(write_din_debounced),
    .tx(tx),
    .tx_ready(tx_ready)

);

parameter CLK_DIVIDER = 499999;

debouncer #(.CLK_DIVIDER(CLK_DIVIDER))
resetN_debouncer 
(
    .clk(clk50Mhz),
    .resetN(resetN),
    .trigger_in(resetN),
    .trigger_out(resetN_debounced)
);

debouncer #(.CLK_DIVIDER(CLK_DIVIDER))
write_din_debouncer 
(
    .clk(clk50Mhz),
    .resetN(resetN),
    .trigger_in(write_din),
    .trigger_out(write_din_debounced)
);



endmodule


