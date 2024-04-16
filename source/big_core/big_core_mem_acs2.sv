//-----------------------------------------------------------------------------
// Title            : 
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : 
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Adviser          : Amichai Ben-David
// Created          : 10/2023
//-----------------------------------------------------------------------------

`include "macros.vh"

module big_core_mem_acs2
import big_core_pkg::*;
( input  logic           Clock,       //input 
  input  logic           Rst,         //input  
  // ctrl
  input  logic           ReadyQ105H,  //input
  //data path input
  input  logic [31:0]    PcPlus4Q104H,//input
  input  logic [31:0]    AluOutQ104H, //input
  // data path output
  output logic [31:0]    PcPlus4Q105H,//input
  output logic [31:0]    AluOutQ105H //input
);

`MAFIA_EN_DFF(PcPlus4Q105H, PcPlus4Q104H, Clock, ReadyQ105H)
`MAFIA_EN_DFF(AluOutQ105H,  AluOutQ104H , Clock, ReadyQ105H)

endmodule

