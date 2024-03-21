`include "macros.vh"

module mini_core_rrv_top
import mini_core_rrv_pkg::*;
(
    input logic Clock,
    input logic Rst
   
);

// Imem interface
logic [31:0] PreInstructionQ101H;
logic [31:0] PcQ100H;
// Dmem interface
var t_core2mem_req Core2DmemReqQ101H;
logic [31:0] DMemWrDataQ101H;     // To D_MEM
logic [31:0] DMemAddressQ101H;    // To D_MEM
logic [3:0]  DMemByteEnQ101H;     // To D_MEM
logic        DMemWrEnQ101H;       // To D_MEM
logic        DMemRdEnQ101H;       // To D_MEM
logic [31:0] DMemRdRspQ102H;      // from D_MEM

assign DMemWrDataQ101H = Core2DmemReqQ101H.WrData;
assign DMemAddressQ101H = Core2DmemReqQ101H.Address;
assign DMemByteEnQ101H = Core2DmemReqQ101H.ByteEn;
assign DMemWrEnQ101H = Core2DmemReqQ101H.WrEn;
assign DMemRdEnQ101H = Core2DmemReqQ101H.RdEn;

mini_core_rrv mini_core_rrv 
(
    .Clock(Clock),
    .Rst(Rst),
    // I_MEM interface
    .PreInstructionQ101H(PreInstructionQ101H), // from I_MEM
    .PcQ100H(PcQ100H),
    // D_MEM interface
    .Core2DmemReqQ101H(Core2DmemReqQ101H),
    .DMemRdRspQ102H(DMemRdRspQ102H)

);

mini_core_rrv_mem_wrap mini_core_rrv_mem_wrap
(
    .Clock(Clock),
    .Rst(Rst),
    // i_mem
    .PcQ100H(PcQ100H),
    .PreInstructionQ101H(PreInstructionQ101H),
    // d_mem
    .DMemWrDataQ101H(DMemWrDataQ101H),
    .DMemAddressQ101H(DMemAddressQ101H),
    .DMemByteEnQ101H(DMemByteEnQ101H),
    .DMemWrEnQ101H(DMemWrEnQ101H),
    .DMemRdEnQ101H(DMemRdEnQ101H),
    .DMemRdRspQ102H(DMemRdRspQ102H)
);

endmodule