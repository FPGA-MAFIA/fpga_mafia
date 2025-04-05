//-----------------------------------------------------------------------------
// Title            : 
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : 
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Adviser          : Amichai Ben-David
// Created          : 7/2023
//-----------------------------------------------------------------------------

`include "macros.vh"

module mini_core_di_rf 
import mini_core_di_pkg::*;
#(parameter RF_NUM_MSB) 
(
    input logic Clock,
    input logic Rst,
    // input control path
    input var t_ctrl_rf Ctrl,
    // input data path
    input  logic        ReadyQ102H,
    input  logic [31:0] PcQ101H,
    input  logic [31:0] ImmediateQ101H,
    input  logic [31:0] RegWrDataQ104H,
    input  logic        ReadyQ202H,
    input  logic [31:0] PcQ201H,
    input  logic [31:0] ImmediateQ201H,
    input  logic [31:0] RegWrDataQ204H,
    // output data path
    output logic [31:0] PcQ102H,
    output logic [31:0] ImmediateQ102H,
    output logic [31:0] RegRdData1Q102H,
    output logic [31:0] RegRdData2Q102H,
    output logic [31:0] PcQ202H,
    output logic [31:0] ImmediateQ202H,
    output logic [31:0] RegRdData1Q202H,
    output logic [31:0] RegRdData2Q202H
);



// Register Array
logic [RF_NUM_MSB:1][31:0]  Register;
// Q1
logic                       MatchRd1AftrWrQ101H;
logic                       MatchRd2AftrWrQ101H;
logic [31:0]                RegRdData1Q101H;
logic [31:0]                RegRdData2Q101H;
// Q2
logic                       MatchRd1AftrWrQ201H;
logic                       MatchRd2AftrWrQ201H;
logic [31:0]                RegRdData1Q201H;
logic [31:0]                RegRdData2Q201H;
//===================
//  Register File
//===================
//---- The Register File ---- 
`MAFIA_EN_DFF(Register[Ctrl.RegDstQ104H] , RegWrDataQ104H , Clock , (Ctrl.RegWrEnQ104H && (Ctrl.RegDstQ104H!=5'b0)))
`MAFIA_EN_DFF(Register[Ctrl.RegDstQ204H] , RegWrDataQ204H , Clock , (Ctrl.RegWrEnQ204H && (Ctrl.RegDstQ204H!=5'b0))) // FIXME - Abd: IDU should not issue 2 parallel commands that write to same Register
// ---- Read Register File ---- For Q1
assign MatchRd1AftrWrQ101H = (Ctrl.RegSrc1Q101H == Ctrl.RegDstQ104H) && (Ctrl.RegWrEnQ104H);
assign RegRdData1Q101H = (Ctrl.RegSrc1Q101H == 5'b0) ? 32'b0                      : // Reading from Register[0] should result in '0
                         MatchRd1AftrWrQ101H         ? RegWrDataQ104H             : // forwards WrDataQ104H -> RdDataQ101H
                                                       Register[Ctrl.RegSrc1Q101H]; // Common Case - reading from Register file

assign MatchRd2AftrWrQ101H = (Ctrl.RegSrc2Q101H == Ctrl.RegDstQ104H) && (Ctrl.RegWrEnQ104H);
assign RegRdData2Q101H = (Ctrl.RegSrc2Q101H == 5'b0) ? 32'b0                      : // Reading from Register[0] should result in '0 
                         MatchRd2AftrWrQ101H         ? RegWrDataQ104H             : // forwards WrDataQ104H -> RdDataQ101H
                                                       Register[Ctrl.RegSrc2Q101H]; // Common Case - reading from Register file
// ---- Read Register File ---- For Q2
assign MatchRd1AftrWrQ201H = (Ctrl.RegSrc1Q201H == Ctrl.RegDstQ204H) && (Ctrl.RegWrEnQ204H);
assign RegRdData1Q201H = (Ctrl.RegSrc1Q201H == 5'b0) ? 32'b0                      : // Reading from Register[0] should result in '0
                         MatchRd1AftrWrQ201H         ? RegWrDataQ204H             : // forwards WrDataQ204H -> RdDataQ201H
                                                       Register[Ctrl.RegSrc1Q201H]; // Common Case - reading from Register file

assign MatchRd2AftrWrQ201H = (Ctrl.RegSrc2Q201H == Ctrl.RegDstQ204H) && (Ctrl.RegWrEnQ204H);
assign RegRdData2Q201H = (Ctrl.RegSrc2Q201H == 5'b0) ? 32'b0                      : // Reading from Register[0] should result in '0 
                         MatchRd2AftrWrQ201H         ? RegWrDataQ204H             : // forwards WrDataQ204H -> RdDataQ201H
                                                       Register[Ctrl.RegSrc2Q201H]; // Common Case - reading from Register file
// Note both issues can read from same register at the same time

// Q1
`MAFIA_EN_DFF(ImmediateQ102H,  ImmediateQ101H,  Clock, ReadyQ102H)
`MAFIA_EN_DFF(PcQ102H,         PcQ101H,         Clock, ReadyQ102H)
`MAFIA_EN_DFF(RegRdData1Q102H, RegRdData1Q101H, Clock, ReadyQ102H)
`MAFIA_EN_DFF(RegRdData2Q102H, RegRdData2Q101H, Clock, ReadyQ102H)
// Q2
`MAFIA_EN_DFF(ImmediateQ202H,  ImmediateQ201H,  Clock, ReadyQ202H)
`MAFIA_EN_DFF(PcQ202H,         PcQ201H,         Clock, ReadyQ202H)
`MAFIA_EN_DFF(RegRdData1Q202H, RegRdData1Q201H, Clock, ReadyQ202H)
`MAFIA_EN_DFF(RegRdData2Q202H, RegRdData2Q201H, Clock, ReadyQ202H)

endmodule