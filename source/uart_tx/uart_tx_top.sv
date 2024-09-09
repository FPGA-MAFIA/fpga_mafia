//-----------------------------------------------------------------------------
// Title            : uart_tx top
// Project          : design of a uart transmiter
//-----------------------------------------------------------------------------
// File             : uart_tx_pkg.sv
// Original Author  : Morin Binyamin
// Code Owner       : Morin Binyamin
// Created          : 9/2024
//-----------------------------------------------------------------------------
// Description : top module of UART_TX
//-----------------------------------------------------------------------------

module uart_tx_top
import uart_tx_pkg::*;
#(parameter MAX_TIMER_VALUE = N_TIMER)
(
    input logic       clk,
    input logic       resetN,
    input logic [7:0] din, 
    input logic       write_din,
    output logic      tx,
    output logic      tx_ready

);

t_uart_tx_ctrl_in  uart_tx_ctrl_in;
t_uart_tx_ctrl_out uart_tx_ctrl_out;

logic PL;
assign PL = (write_din & uart_tx_ctrl_out.ena_load);  // TODO - refactor and remove logic from top hierarchy 
 

//=======================================
//             controller
//=======================================
uart_tx_ctrl uart_tx_ctrl
(
    .clk(clk),
    .resetN(resetN),
    .write_din(write_din),
    .uart_tx_ctrl_in(uart_tx_ctrl_in),
    .uart_tx_ctrl_out(uart_tx_ctrl_out)
);

//=======================================
//             dcount counter
//=======================================
uart_tx_dcount uart_tx_dcount 
(
    .clk(clk),
    .resetN(resetN),
    .en_cnt(uart_tx_ctrl_out.ena_dcount),
    .clr(uart_tx_ctrl_out.clr_dcount),
    .eoc_dcount(uart_tx_ctrl_in.eoc_dcount)
);

//=======================================
//          output flip-flop
//=======================================
logic dint;

uart_tx_output_ff uart_tx_output_ff
(
    .clk(clk),
    .resetN(resetN), 
    .set(uart_tx_ctrl_out.set_tx),
    .enable(uart_tx_ctrl_out.ena_tx),
    .data_in(dint), 
    .clear(uart_tx_ctrl_out.clr_tx),
    .data_out(tx) 

);

uart_tx_shift_register uart_tx_shift_register
(
    .clk(clk),
    .resetN(resetN),
    .data_in(din), 
    .pre_load(PL),
    .shift_en(uart_tx_ctrl_out.ena_shift),
    .dint(dint)
);

//=======================================
//          Tcount Timer
//=======================================
uart_tx_timer
#(.MAX_VALUE(MAX_TIMER_VALUE))
uart_tx_timer
(
    .clk(clk),
    .te(uart_tx_ctrl_out.te),  // when te=0 timer clears. when te=1 timer counts
    .resetN(resetN), 
    .t1(uart_tx_ctrl_in.t1)

);

assign tx_ready = uart_tx_ctrl_out.ena_load;

endmodule