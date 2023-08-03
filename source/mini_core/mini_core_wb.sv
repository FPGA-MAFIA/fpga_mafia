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

`include "macros.sv"

module mini_core_wb
import common_pkg::*;
( input  logic           Clock,       //input 
  input  logic           Rst,         //input  
  // Ctrl
  input var  t_ctrl_wb       Ctrl, //input
  // Data path input
  input  logic [31:0]    DMemRdDataQ104H, //input
  input  logic [31:0]    AluOutQ104H,     //input
  input  logic [31:0]    PcPlus4Q104H,    //input
  // data path output
  output logic [31:0]    RegWrDataQ104H  //output

);

logic [31:0] PostSxDMemRdDataQ104H;
// Sign extend taking care of
assign PostSxDMemRdDataQ104H[7:0]   =  Ctrl.ByteEnQ104H[0] ? DMemRdDataQ104H[7:0]          : 8'b0;
assign PostSxDMemRdDataQ104H[15:8]  =  Ctrl.ByteEnQ104H[1] ? DMemRdDataQ104H[15:8]         :
                                       Ctrl.SignExtQ104H   ? {8{PostSxDMemRdDataQ104H[7]}} : 8'b0;
assign PostSxDMemRdDataQ104H[23:16] =  Ctrl.ByteEnQ104H[2] ? DMemRdDataQ104H[23:16]        :
                                       Ctrl.SignExtQ104H   ? {8{PostSxDMemRdDataQ104H[15]}}: 8'b0;
assign PostSxDMemRdDataQ104H[31:24] =  Ctrl.ByteEnQ104H[3] ? DMemRdDataQ104H[31:24]        :
                                       Ctrl.SignExtQ104H   ? {8{PostSxDMemRdDataQ104H[23]}}: 8'b0;

// ---- Select what write to the register file ----
assign RegWrDataQ104H = (Ctrl.e_SelWrBackQ104H == WB_DMEM) ? PostSxDMemRdDataQ104H : // TODO - CHCK THIS ENUM
                        (Ctrl.e_SelWrBackQ104H == WB_ALU)  ? AluOutQ104H           :
                        (Ctrl.e_SelWrBackQ104H == WB_PC4)  ? PcPlus4Q104H          : 
                                                           32'b0;
endmodule