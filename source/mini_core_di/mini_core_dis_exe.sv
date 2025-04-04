`include "macros.vh"

module mini_core_dis_exe
import mini_core_pkg::*;
(
    input  logic        Clock,
    input  logic        Rst,
    //===================
    // Input Control Signals
    //===================
    input  var t_ctrl_exe   Ctrl,
    input  logic        ReadyQ203H,
    //===================
    // Input Data path
    //===================
    //Q202H
    input logic [31:0]  PreRegRdData1Q202H,
    input logic [31:0]  PreRegRdData2Q202H,
    input logic [31:0]  PcQ202H,
    input logic [31:0]  ImmediateQ202H,
    //Q204H
    input logic [31:0]  RegWrDataQ104H, // used for forwarding
    input logic [31:0]  RegWrDataQ204H, // used for forwarding
    //===================
    // output data path
    //===================
    output logic [31:0] AluOutQ202H,
    output logic [31:0] AluOutQ203H
    // output logic [31:0] DMemWrDataQ203H // no memeory acces for issue 2
);

logic        Hazard1Data1Q202H, Hazard2Data1Q202H, Hazard1Data2Q202H, Hazard2Data2Q202H;
logic        Hazard3Data1Q202H, Hazard4Data1Q202H, Hazard1Data3Q202H, Hazard4Data2Q202H;
logic [31:0] AluIn1Q202H, AluIn2Q202H;
logic [4:0]  ShamtQ202H;
logic [31:0] RegRdData1Q202H, RegRdData2Q202H;
//////////////////////////////////////////////////////////////////////////////////////////////////
//    _____  __     __   _____   _        ______          ____    __    ___    ___    _    _ 
//   / ____| \ \   / /  / ____| | |      |  ____|        / __ \  /_ |  / _ \  |__ \  | |  | |
//  | |       \ \_/ /  | |      | |      | |__          | |  | |  | | | | | |    ) | | |__| |
//  | |        \   /   | |      | |      |  __|         | |  | |  | | | | | |   / /  |  __  |
//  | |____     | |    | |____  | |____  | |____        | |__| |  | | | |_| |  / /_  | |  | |
//   \_____|    |_|     \_____| |______| |______|        \___\_\  |_|  \___/  |____| |_|  |_|
//                                                                                           
//////////////////////////////////////////////////////////////////////////////////////////////////
// Execute
// -----------------
// 1. Use the Imm/Registers to compute:
//      a) data to write back to register.
//////////////////////////////////////////////////////////////////////////////////////////////////
// Hazard Detection
assign Hazard1Data1Q202H = (Ctrl.RegSrc1Q202H == Ctrl.RegDstQ203H) && (Ctrl.RegWrEnQ203H) && (Ctrl.RegSrc1Q202H != 5'b0); // Q203 dst -> Q202 src 1
assign Hazard2Data1Q202H = (Ctrl.RegSrc1Q202H == Ctrl.RegDstQ204H) && (Ctrl.RegWrEnQ204H) && (Ctrl.RegSrc1Q202H != 5'b0); // Q204 dst -> Q202 src 1
assign Hazard1Data2Q202H = (Ctrl.RegSrc2Q202H == Ctrl.RegDstQ203H) && (Ctrl.RegWrEnQ203H) && (Ctrl.RegSrc2Q202H != 5'b0); // Q203 dst -> Q202 src 2
assign Hazard2Data2Q202H = (Ctrl.RegSrc2Q202H == Ctrl.RegDstQ204H) && (Ctrl.RegWrEnQ204H) && (Ctrl.RegSrc2Q202H != 5'b0); // Q204 dst -> Q202 src 2
// FIXME - Abd: need to add Hazard detection for multi issue use
assign Hazard3Data1Q202H = (Ctrl.RegSrc1Q202H == Ctrl.RegDstQ103H) && (Ctrl.RegWrEnQ103H) && (Ctrl.RegSrc1Q202H != 5'b0); // Q103 dst -> Q202 src 1
assign Hazard4Data1Q202H = (Ctrl.RegSrc1Q202H == Ctrl.RegDstQ104H) && (Ctrl.RegWrEnQ104H) && (Ctrl.RegSrc1Q202H != 5'b0); // Q104 dst -> Q202 src 1
assign Hazard3Data2Q202H = (Ctrl.RegSrc2Q202H == Ctrl.RegDstQ103H) && (Ctrl.RegWrEnQ103H) && (Ctrl.RegSrc2Q202H != 5'b0); // Q103 dst -> Q202 src 2
assign Hazard4Data2Q202H = (Ctrl.RegSrc2Q202H == Ctrl.RegDstQ104H) && (Ctrl.RegWrEnQ104H) && (Ctrl.RegSrc2Q202H != 5'b0); // Q104 dst -> Q202 src 2

// Forwarding unite
assign RegRdData1Q202H = Hazard1Data1Q202H ? AluOutQ203H       : // Rd 202 After Wr 203
                         Hazard2Data1Q202H ? RegWrDataQ204H    : // Rd 202 After Wr 204
                         Hazard3Data1Q202H ? AluOutQ103H       : // Rd 202 After Wr 103
                         Hazard4Data1Q202H ? RegWrDataQ104H    : // Rd 202 After Wr 104
                                             PreRegRdData1Q202H; // Common Case - No Hazard

assign RegRdData2Q202H = Hazard1Data2Q202H ? AluOutQ203H       : // Rd 202 After Wr 203
                         Hazard2Data2Q202H ? RegWrDataQ204H    : // Rd 202 After Wr 204
                         Hazard3Data2Q202H ? AluOutQ103H       : // Rd 202 After Wr 103
                         Hazard4Data2Q202H ? RegWrDataQ104H    : // Rd 202 After Wr 104  
                                             PreRegRdData2Q202H; // Common Case - No Hazard

// End Take care to data hazard
assign AluIn1Q202H = Ctrl.SelAluPcQ202H  ? PcQ202H          : RegRdData1Q202H;
assign AluIn2Q202H = Ctrl.SelAluImmQ202H ? ImmediateQ202H   : RegRdData2Q202H;

always_comb begin : alu_logic
  ShamtQ202H      = AluIn2Q202H[4:0];
  unique casez (Ctrl.AluOpQ202H) 
    // Adder
    ADD     : AluOutQ202H = AluIn1Q202H +   AluIn2Q202H;                            // ADD/LW/SW/AUIOC/JAL/JALR/BRANCH/
    SUB     : AluOutQ202H = AluIn1Q202H + (~AluIn2Q202H) + 1'b1;                    // SUB
    SLT     : AluOutQ202H = {31'b0, ($signed(AluIn1Q202H) < $signed(AluIn2Q202H))}; // SLT
    SLTU    : AluOutQ202H = {31'b0 , AluIn1Q202H < AluIn2Q202H};                    // SLTU
    // Shifter
    SLL     : AluOutQ202H = AluIn1Q202H << ShamtQ202H;                              // SLL
    SRL     : AluOutQ202H = AluIn1Q202H >> ShamtQ202H;                              // SRL
    SRA     : AluOutQ202H = $signed(AluIn1Q202H) >>> ShamtQ202H;                    // SRA
    // Bit wise operations
    XOR     : AluOutQ202H = AluIn1Q202H ^ AluIn2Q202H;                              // XOR
    OR      : AluOutQ202H = AluIn1Q202H | AluIn2Q202H;                              // OR
    AND     : AluOutQ202H = AluIn1Q202H & AluIn2Q202H;                              // AND
    default : AluOutQ202H = AluIn1Q202H + AluIn2Q202H;
  endcase
  if (Ctrl.LuiQ202H) AluOutQ202H = AluIn2Q202H;                                     // LUI
end

// Q202H to Q203H Flip Flops
`MAFIA_EN_DFF(DMemWrDataQ203H     , RegRdData2Q202H     , Clock, ReadyQ203H)
`MAFIA_EN_DFF(AluOutQ203H         , AluOutQ202H         , Clock, ReadyQ203H)

endmodule