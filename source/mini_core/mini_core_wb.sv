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
);


// Sign extend taking care of
assign PostSxDMemRdDataQ104H[7:0]   =  ByteenaRestoreQ104H[0] ? RdDataAfterShiftQ104H[7:0]     : 8'b0;
assign PostSxDMemRdDataQ104H[15:8]  =  ByteenaRestoreQ104H[1] ? RdDataAfterShiftQ104H[15:8]    :
                                       CtrlSignExtQ104H       ? {8{PostSxDMemRdDataQ104H[7]}}  : 8'b0;
assign PostSxDMemRdDataQ104H[23:16] =  ByteenaRestoreQ104H[2] ? RdDataAfterShiftQ104H[23:16]   :
                                       CtrlSignExtQ104H       ? {8{PostSxDMemRdDataQ104H[15]}} : 8'b0;
assign PostSxDMemRdDataQ104H[31:24] =  ByteenaRestoreQ104H[3] ? RdDataAfterShiftQ104H[31:24]   :
                                       CtrlSignExtQ104H       ? {8{PostSxDMemRdDataQ104H[23]}} : 8'b0;

// ---- Select what write to the register file ----
assign WrBackDataQ104H = SelDMemWbQ104H  ? PostSxDMemRdDataQ104H : AluOutQ104H;
assign RegWrDataQ104H  = SelRegWrPcQ104H ? PcPlus4Q104H          : WrBackDataQ104H;
endmodule