//-----------------------------------------------------------------------------
// Title            : riscv as-fast-as-possible 
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : mafia_asap_5pl 
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Adviser          : Amichai Ben-David
// Created          : 10/2021
//-----------------------------------------------------------------------------
// Description :
// This module will comtain a complite RISCV Core supportint the RV32I
// Will be implemented in a single cycle microarchitecture.
// The I_MEM & D_MEM will support async memory read. (This will allow the single-cycle arch)
// ---- 5 Pipeline Stages -----
// 1) Q100H Instruction Fetch
// 2) Q101H Instruction Decode 
// 3) Q102H Execute 
// 4) Q103H Memory Access
// 5) Q104H Write back data from Memory/ALU to Registerfile

`include "macros.sv"

module mini_core 
import common_pkg::*;
(
    input  logic        Clock,
    input  logic        Rst,
    // Instruction Memory
    output logic [31:0] PcQ100H,             // To I_MEM
    input  logic [31:0] PreInstructionQ101H, // From I_MEM
    // Data Memory
    output logic [31:0] DMemWrDataQ103H,     // To D_MEM
    output logic [31:0] DMemAddressQ103H,    // To D_MEM
    output logic [3:0]  DMemByteEnQ103H,     // To D_MEM
    output logic        DMemWrEnQ103H,       // To D_MEM
    output logic        DMemRdEnQ103H,       // To D_MEM
    input  logic [31:0] DMemRdRspQ104H       // From D_MEM
);

// ---- Data-Path signals ----
// Program counter
logic [31:0]        PcQ101H, PcQ102H;
logic [31:0]        PcPlus4Q100H, PcPlus4Q101H, PcPlus4Q102H, PcPlus4Q103H, PcPlus4Q104H;
logic [31:0]        NextPcQ102H;
logic [31:0]        InstructionQ101H;

logic [31:1][31:0]  Register; 
logic [31:0]        ImmediateQ101H, ImmediateQ102H;
logic [4:0]         ShamtQ102H;
logic [31:0]        AluIn1Q102H;
logic [31:0]        AluIn2Q102H;
logic [31:0]        AluOutQ102H, AluOutQ103H, AluOutQ104H;
logic [31:0]        RegRdData1Q101H, PreRegRdData1Q102H, RegRdData1Q102H, RegRdData1Q103H;
logic [31:0]        RegRdData2Q101H, PreRegRdData2Q102H, RegRdData2Q102H, RegRdData2Q103H;
logic [31:0]        RegWrDataQ104H; 
logic [31:0]        WrBackDataQ104H;
logic [31:0]        PostSxDMemRdDataQ104H;

// Control bits
logic               SelNextPcAluOutJQ101H, SelNextPcAluOutJQ102H;
logic               SelNextPcAluOutBQ101H, SelNextPcAluOutBQ102H;
logic               SelNextPcAluOutQ102H;
logic               SelRegWrPcQ101H, SelRegWrPcQ102H, SelRegWrPcQ103H, SelRegWrPcQ104H;
logic               BranchCondMetQ102H;
logic               SelDMemWbQ101H, SelDMemWbQ102H, SelDMemWbQ103H, SelDMemWbQ104H;
logic [2:0]         Funct3Q101H;
logic [6:0]         Funct7Q101H;
logic [4:0]         PreRegSrc1Q101H, RegSrc1Q101H, RegSrc1Q102H; 
logic [4:0]         PreRegSrc2Q101H, RegSrc2Q101H, RegSrc2Q102H;
logic [4:0]         RegDstQ101H, RegDstQ102H, RegDstQ103H, RegDstQ104H;
logic [3:0]         CtrlDMemByteEnQ101H, CtrlDMemByteEnQ102H, CtrlDMemByteEnQ103H;
logic               CtrlDMemWrEnQ101H, CtrlDMemWrEnQ102H, CtrlDMemWrEnQ103H;
logic               CtrlDMemRdEnQ101H, CtrlDMemRdEnQ102H, CtrlDMemRdEnQ103H;
logic               CtrlSignExtQ101H, CtrlSignExtQ102H, CtrlSignExtQ103H, CtrlSignExtQ104H;
logic               CtrlLuiQ101H, CtrlLuiQ102H;
logic               CtrlRegWrEnQ101H, CtrlRegWrEnQ102H, CtrlRegWrEnQ103H, CtrlRegWrEnQ104H;
logic               SelAluPcQ101H, SelAluPcQ102H;
logic               SelAluImmQ101H, SelAluImmQ102H;
logic [1:0]         ByteOffsetQ104H;
logic [31:0]        RdDataAfterShiftQ104H;
logic [3:0]         ByteEnQ104H, ByteenaRestoreQ104H;
// Hazard unit detection ctrl
logic               PcEnQ101H;
logic [31:0]        PreviousInstructionQ102H;
logic               LoadHzrdDetectQ101H, LoadHzrdDetectQ102H;
// End hazard unit detection ctrl

// For fetch and decode stages flush
logic               flushQ102H, flushQ103H;

t_immediate         SelImmTypeQ101H;
t_alu_op            CtrlAluOpQ101H, CtrlAluOpQ102H;
t_branch_type       CtrlBranchOpQ101H, CtrlBranchOpQ102H;
t_opcode            OpcodeQ101H, OpcodeQ102H;

//////////////////////////////////////////////////////////////////////////////////////////////////
//   _____  __     __   _____   _        ______          ____    __    ___     ___    _    _ 
//  / ____| \ \   / /  / ____| | |      |  ____|        / __ \  /_ |  / _ \   / _ \  | |  | |
// | |       \ \_/ /  | |      | |      | |__          | |  | |  | | | | | | | | | | | |__| |
// | |        \   /   | |      | |      |  __|         | |  | |  | | | | | | | | | | |  __  |
// | |____     | |    | |____  | |____  | |____        | |__| |  | | | |_| | | |_| | | |  | |
//  \_____|    |_|     \_____| |______| |______|        \___\_\  |_|  \___/   \___/  |_|  |_|
//
//////////////////////////////////////////////////////////////////////////////////////////////////
// Instruction fetch
// -----------------
// 1. Send the PC (program counter) to the I_MEM
// 2. Calc/Set the NextPc
// -----------------
//////////////////////////////////////////////////////////////////////////////////////////////////
mini_core_if mini_core_if (
  .Clock        (Clock       ), // input  logic        Clock,
  .Rst          (Rst         ), // input  logic        Rst,
  .ReadyQ100H   (ReadyQ100H  ), // input  logic        ReadyQ100H,
  .ReadyQ101H   (ReadyQ101H  ), // input  logic        ReadyQ101H,
  .Ctrl         (Ctrl        ), // input  t_ctrl_if    Ctrl,
  .AluOutQ102H  (AluOutQ102H ), // input  logic [31:0] AluOutQ102H,
  .PcQ100H      (PcQ100H     ), // output logic [31:0] PcQ100H,
  .PcQ101H      (PcQ101H     ) // output logic [31:0] PcQ101H
);

//////////////////////////////////////////////////////////////////////////////////////////////////
//   _____  __     __   _____   _        ______          ____    __    ___    __   _    _ 
//  / ____| \ \   / /  / ____| | |      |  ____|        / __ \  /_ |  / _ \  /_ | | |  | |
// | |       \ \_/ /  | |      | |      | |__          | |  | |  | | | | | |  | | | |__| |
// | |        \   /   | |      | |      |  __|         | |  | |  | | | | | |  | | |  __  |
// | |____     | |    | |____  | |____  | |____        | |__| |  | | | |_| |  | | | |  | |
//  \_____|    |_|     \_____| |______| |______|        \___\_\  |_|  \___/   |_| |_|  |_|
//
//////////////////////////////////////////////////////////////////////////////////////////////////
// Decode
// -----------------
// 1. Load hazard detection.
// 2. Get the instruciton from I_MEM and use the decoder to set the Ctrl Bits.
// 3. Use the rs1 & rs2 (RegSrc) to read the Register file data.
// 4. construct the Immediate types.
// ----------------- 
//////////////////////////////////////////////////////////////////////////////////////////////////
mini_core_ctrl mini_core_ctrl (
  .Rst                  (Rst                ), //input
  .Clock                (Clock              ), //input
  // input instruction 
  .PreInstructionQ101H  (PreInstructionQ101H), //input
  // input feedback from data path
  .BranchCondMetQ102H   (BranchCondMetQ102H ), //input
  .DMemReady            (DMemReady          ), //input
  .DMemRdRspValid       (DMemRdRspValid     ), //input
  // ready signals for "back-pressure" - use as the enable for the pipe stage sample
  .ReadyQ100H           (ReadyQ100H), //  output 
  .ReadyQ101H           (ReadyQ101H), //  output 
  .ReadyQ102H           (ReadyQ102H), //  output 
  .ReadyQ103H           (ReadyQ103H), //  output 
  .ReadyQ104H           (ReadyQ104H), //  output 
  // output ctrl signals
  .CtrlIf               (CtrlIf             ), //output
  .CtrlRf               (CtrlRf             ), //output
  .CtrlExe              (CtrlExe            ), //output
  .CtrlMem              (CtrlMem            ), //output
  .CtrlWb               (CtrlWb             ), //output
  // output data path signals
  .ImmediateQ101H       (ImmediateQ101H     ) //output
);

mini_core_rf mini_core_rf (
  .Clock            (Clock),          // input
  .Rst              (Rst),            // input 
  .Ctrl             (CtrlRf),         // input
  .ReadyQ102H       (ReadyQ102H),     // input
  // input data path
  .ImmediateQ101H   (ImmediateQ101H), // input
  .PcQ101H          (PcQ101H),        // input  
  .RegWrDataQ104H   (RegWrDataQ104H), // input 
  // output data path
  .PcQ102H          (PcQ102H),        // output   
  .ImmediateQ102H   (ImmediateQ102H), // output
  .RegRdData1Q102H  (RegRdData1Q102H),// output
  .RegRdData2Q102H  (RegRdData2Q102H) // output
);

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
//      b) Calculate address for load/store
//      c) Calculate branch/jump target.
// 2. Check branch condition.
//////////////////////////////////////////////////////////////////////////////////////////////////
mini_core_exe mini_core_exe (
  .Clock               (Clock              ), //  input 
  .Rst                 (Rst                ), //  input 
  // Input Control Signals
  .Ctrl                (CtrlExe            ), //  input 
  // Output Control Signals
  .BranchCondMetQ102H  (BranchCondMetQ102H ), //  output
  // Input Data path
  //Q102H
  .PreRegRdData1Q102H  (PreRegRdData1Q102H ), //  input 
  .PreRegRdData2Q102H  (PreRegRdData2Q102H ), //  input 
  .PcQ102H             (PcQ102H            ), //  input 
  .ImmediateQ102H      (ImmediateQ102H     ), //  input 
  //Q104H
  .RegWrDataQ104H      (RegWrDataQ104H     ), //  input 
  // output data path
  .AluOutQ103H         (AluOutQ103H        ), //  output
  .PcPlus4Q103H        (PcPlus4Q103H       ), //  output
  .DMemWrDataQ103H     (DMemWrDataQ103H    )  //  output
);

//////////////////////////////////////////////////////////////////////////////////////////////////
//   _____  __     __   _____   _        ______          ____    __    ___    ____    _    _ 
//  / ____| \ \   / /  / ____| | |      |  ____|        / __ \  /_ |  / _ \  |___ \  | |  | |
// | |       \ \_/ /  | |      | |      | |__          | |  | |  | | | | | |   __) | | |__| |
// | |        \   /   | |      | |      |  __|         | |  | |  | | | | | |  |__ <  |  __  |
// | |____     | |    | |____  | |____  | |____        | |__| |  | | | |_| |  ___) | | |  | |
//  \_____|    |_|     \_____| |______| |______|        \___\_\  |_|  \___/  |____/  |_|  |_|
//
//////////////////////////////////////////////////////////////////////////////////////////////////
// Memory Access
// -----------------
// 1. Access D_MEM for Wrote (STORE) and Reads (LOAD)
//////////////////////////////////////////////////////////////////////////////////////////////////

mini_core_mem_acs mini_core_mem_access (
  .Clock       (Clock),       //input 
  .Rst         (Rst),         //input  
  // Input Control Signals
  .Ctrl        (CtrlMem),     //input
  .ReadyQ104H  (ReadyQ104H),  //input
  // Input Data path
  .PcPlus4Q103H(PcPlus4Q103H),//input
  .AluOutQ103H (AluOutQ103H), //input
  .RegRdData2Q103H(RegRdData2Q103H), //input
  // data path output
  .Core2DmemReqQ103H (Core2DmemReqQ103H), //output
  .PcPlus4Q104H(PcPlus4Q104H),//input
  .AluOutQ104H(AluOutQ104H) //input
);
// Q103H to Q104H Flip Flops
`MAFIA_DFF(AluOutQ104H      , AluOutQ103H         , Clock)
`MAFIA_DFF(SelDMemWbQ104H   , SelDMemWbQ103H      , Clock)
`MAFIA_DFF(PcPlus4Q104H     , PcPlus4Q103H        , Clock)
`MAFIA_DFF(SelRegWrPcQ104H  , SelRegWrPcQ103H     , Clock)
`MAFIA_DFF(RegDstQ104H      , RegDstQ103H         , Clock)
`MAFIA_DFF(CtrlRegWrEnQ104H , CtrlRegWrEnQ103H    , Clock)
`MAFIA_DFF(CtrlSignExtQ104H , CtrlSignExtQ103H    , Clock)
`MAFIA_DFF(ByteEnQ104H      , CtrlDMemByteEnQ103H , Clock)

//////////////////////////////////////////////////////////////////////////////////////////////////
//    ____  __     __   _____   _        ______          ____    __    ___    _  _     _    _ 
//  / ____| \ \   / /  / ____| | |      |  ____|        / __ \  /_ |  / _ \  | || |   | |  | |
// | |       \ \_/ /  | |      | |      | |__          | |  | |  | | | | | | | || |_  | |__| |
// | |        \   /   | |      | |      |  __|         | |  | |  | | | | | | |__   _| |  __  |
// | |____     | |    | |____  | |____  | |____        | |__| |  | | | |_| |    | |   | |  | |
//  \_____|    |_|     \_____| |______| |______|        \___\_\  |_|  \___/     |_|   |_|  |_|
//
//////////////////////////////////////////////////////////////////////////////////////////////////
// Write-Back
// -----------------
// 1. Select which data should be written back to the register file AluOut or DMemRdData.
//////////////////////////////////////////////////////////////////////////////////////////////////


endmodule // Module mafia_asap_5pl
