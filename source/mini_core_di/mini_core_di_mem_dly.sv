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

module mini_core_di_mem_dly
import mini_core_pkg::*;
( input  logic           Clock,       //input 
  input  logic           Rst,         //input  
  // ctrl
  input  logic           ReadyQ204H,  //input
  // delay
  input  logic [31:0]    AluOutQ203H, //input
  output logic [31:0]    AluOutQ204H //output
);

`MAFIA_EN_DFF(AluOutQ204H,  AluOutQ203H , Clock, ReadyQ204H)

endmodule