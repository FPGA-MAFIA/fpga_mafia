//=====================================
// RF part of stage Q101H
//=====================================

`include "macros.vh"

module mini_core_rrv_rf
import mini_core_rrv_pkg::*;
#(parameter RF_NUM_MSB)
(
    input  logic         Clock, 
    input  logic         Rst,
    input  var t_ctrl_rf Ctrl,
    input  logic [31:0]  PcQ101H,
    input  logic [31:0]  RegWrDataQ102H,
    output logic [31:0]  RegRdData1Q101H,
    output logic [31:0]  RegRdData2Q101H
);

    logic [31:0] Register [RF_NUM_MSB:1]; // define register file

    `MAFIA_EN_DFF(Register[Ctrl.RegDstQ102H], RegWrDataQ102H, Clock, (Ctrl.RegWrEnQ102H & Ctrl.RegDstQ102H != 5'h0))  //RegDstQ102H must be set only in Q102H stage

    assign RegRdData1Q101H = (Ctrl.RegSrc1Q101H == 32'h0) ? 32'h0 : Register[Ctrl.RegSrc1Q101H];
    assign RegRdData2Q101H = (Ctrl.RegSrc2Q101H == 32'h0) ? 32'h0 : Register[Ctrl.RegSrc2Q101H];



endmodule