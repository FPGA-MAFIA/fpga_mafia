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

module mini_core_smt_mem_acs
import mini_core_smt_pkg::*;
( input  logic           Clock,       //input 
  input  logic           Rst,         //input  
  // ctrl
  input var  t_ctrl_mem      Ctrl,        //input
  input  logic           ReadyQ104H,  //input
  //data path input
  input  logic [31:0]    PcPlus4Q103H,//input
  input  logic [31:0]    AluOutQ103H, //input
  input  logic [31:0]    DMemWrDataQ103H, //input
  input logic            ThreadIDQ103H,
  // data path output
  output t_core2mem_req  Core2DmemReqQ103H, //output
  output logic [31:0]    PcPlus4Q104H,//input
  output logic [31:0]    AluOutQ104H //input
);

// Address offset based on thread
logic [31:0] AlignedAddr;
assign AlignedAddr = (ThreadIDQ103H == 1'b0) ? AluOutQ103H : (AluOutQ103H + 32'h8000);

// Outputs to memory
assign Core2DmemReqQ103H.WrData  = DMemWrDataQ103H;
assign Core2DmemReqQ103H.Address = AluOutQ103H;
assign Core2DmemReqQ103H.WrEn    = Ctrl.DMemWrEnQ103H;
assign Core2DmemReqQ103H.RdEn    = Ctrl.DMemRdEnQ103H;
assign Core2DmemReqQ103H.ByteEn  = Ctrl.DMemByteEnQ103H;

`MAFIA_EN_DFF(PcPlus4Q104H, PcPlus4Q103H, Clock, ReadyQ104H)
`MAFIA_EN_DFF(AluOutQ104H,  AluOutQ103H , Clock, ReadyQ104H)

endmodule
