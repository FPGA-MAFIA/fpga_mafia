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

module mini_core_dis_wb
import mini_core_di_pkg::*;
( input  logic           Clock,       //input 
  input  logic           Rst,         //input  
  // Ctrl
  input var  t_ctrl_wb       Ctrl, //input
  // Data path input
  input  logic [31:0]    AluOutQ204H,     //input
  // data path output
  output logic [31:0]    RegWrDataQ204H  //output

);

// ---- Select what write to the register file ----
assign RegWrDataQ204H = (Ctrl.e_SelWrBackQ204H == WB_ALU)  ? AluOutQ204H : 32'b0;
endmodule