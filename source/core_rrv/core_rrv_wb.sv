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

module core_rrv_wb
import core_rrv_pkg::*;
( input  logic           Clock,       //input 
  input  logic           Rst,         //input  
  // Ctrl
  input var  t_ctrl_wb       Ctrl, //input
  // Data path input
  input  logic [31:0]    DMemRdDataQ105H, //input
  input  logic [31:0]    AluOutQ105H,     //input
  input  logic [31:0]    PcPlus4Q105H,    //input
  // data path output
  output logic [31:0]    RegWrDataQ105H  //output
);


logic [31:0] PostSxDMemRdDataQ105H;
// Sign extend taking care of
assign PostSxDMemRdDataQ105H[7:0]   =  Ctrl.ByteEnQ105H[0] ? DMemRdDataQ105H[7:0]             : 8'b0;
assign PostSxDMemRdDataQ105H[15:8]  =  Ctrl.ByteEnQ105H[1] ? DMemRdDataQ105H[15:8]            :
                                       Ctrl.SignExtQ105H   ? {8{PostSxDMemRdDataQ105H[7]}}    : 8'b0;
assign PostSxDMemRdDataQ105H[23:16] =  Ctrl.ByteEnQ105H[2] ? DMemRdDataQ105H[23:16]           :
                                       Ctrl.SignExtQ105H   ? {8{PostSxDMemRdDataQ105H[15]}}   : 8'b0;
assign PostSxDMemRdDataQ105H[31:24] =  Ctrl.ByteEnQ105H[3] ? DMemRdDataQ105H[31:24]           :
                                       Ctrl.SignExtQ105H   ? {8{PostSxDMemRdDataQ105H[23]}}   : 8'b0;

// ---- Select what write to the register file ----
assign RegWrDataQ105H = (Ctrl.e_SelWrBackQ105H == WB_DMEM) ? PostSxDMemRdDataQ105H : // TODO - Conseder using unique case instead of priority mux, to improve timing by reduce number of logical steps for the mux out.
                        (Ctrl.e_SelWrBackQ105H == WB_ALU)  ? AluOutQ105H           :
                        (Ctrl.e_SelWrBackQ105H == WB_PC4)  ? PcPlus4Q105H          : 
                                                           32'b0;
endmodule

