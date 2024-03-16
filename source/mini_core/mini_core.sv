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
// This module will contain a complete RISCV Core supporting the RV32I
// Will be implemented in a single cycle micro-architecture.
// The I_MEM & D_MEM will support async memory read. (This will allow the single-cycle arch)
// ---- 5 Pipeline Stages -----
// 1) Q100H Instruction Fetch
// 2) Q101H Instruction Decode 
// 3) Q102H Execute 
// 4) Q103H Memory Access
// 5) Q104H Write back data from Memory/ALU to Register file

`include "macros.vh"

module mini_core 
import mini_core_pkg::*;
#(parameter RF_NUM_MSB) 
(
    input  logic        Clock,
    input  logic        Rst,
    // Instruction Memory
    output logic       ReadyQ101H,
    output logic [31:0] PcQ100H,             // To I_MEM
    input  logic [31:0] PreInstructionQ101H, // From I_MEM
    // Data Memory
    input  logic          DMemReady,    // From D_MEM
    output t_core2mem_req Core2DmemReqQ103H,
    input  logic [31:0]   DMemRdRspQ104H     // From D_MEM
);

// ---- Data-Path signals ----
logic [31:0]  PcQ101H, PcQ102H;
logic [31:0]  PcPlus4Q103H, PcPlus4Q104H;
logic [31:0]  ImmediateQ101H, ImmediateQ102H;
logic [31:0]  AluOutQ102H, AluOutQ103H, AluOutQ104H;
logic [31:0]  PreRegRdData1Q102H, RegRdData1Q102H;
logic [31:0]  PreRegRdData2Q102H, RegRdData2Q102H;
logic [31:0]  RegWrDataQ104H; 
logic [31:0]  DMemWrDataQ103H;

// Control bits
logic         BranchCondMetQ102H;
logic         ReadyQ100H;
logic         ReadyQ102H;
logic         ReadyQ103H;
logic         ReadyQ104H;
t_mini_ctrl   Ctrl;
t_ctrl_if     CtrlIf;
t_ctrl_rf     CtrlRf;
t_ctrl_exe    CtrlExe;
t_ctrl_mem    CtrlMem;
t_ctrl_wb     CtrlWb;


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
  .Ctrl         (CtrlIf        ), // input  t_ctrl_if    Ctrl,
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
  .Rst                  (Rst    ), //input
  .Clock                (Clock  ), //input
  // input instruction 
  .PreInstructionQ101H  (PreInstructionQ101H), //input
  .PcQ101H              (PcQ101H), // output logic [31:0] PcQ101H
  // input feedback from data path
  .BranchCondMetQ102H   (BranchCondMetQ102H), //input
  .DMemReady            (DMemReady), //input
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

mini_core_rf 
#( .RF_NUM_MSB(RF_NUM_MSB) )    
mini_core_rf (
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
  .ReadyQ103H          (ReadyQ103H         ), //  input
  // Output Control Signals
  .BranchCondMetQ102H  (BranchCondMetQ102H ), //  output
  // Input Data path
  //Q102H
  .PreRegRdData1Q102H  (RegRdData1Q102H ), //  input 
  .PreRegRdData2Q102H  (RegRdData2Q102H ), //  input 
  .PcQ102H             (PcQ102H            ), //  input 
  .ImmediateQ102H      (ImmediateQ102H     ), //  input 
  //Q104H
  .RegWrDataQ104H      (RegWrDataQ104H     ), //  input 
  // output data path
  .AluOutQ102H         (AluOutQ102H        ), //  output
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
  .Clock              (Clock),          //input 
  .Rst                (Rst),            //input  
  // Input Control Signals
  .Ctrl               (CtrlMem),        //input
  .ReadyQ104H         (ReadyQ104H),     //input
  // Input Data path
  .PcPlus4Q103H       (PcPlus4Q103H),   //input
  .AluOutQ103H        (AluOutQ103H),    //input
  .DMemWrDataQ103H    (DMemWrDataQ103H),//input
  // data path output
  .Core2DmemReqQ103H  (Core2DmemReqQ103H),//output
  .PcPlus4Q104H       (PcPlus4Q104H),   //input
  .AluOutQ104H        (AluOutQ104H)     //input
);


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
mini_core_wb mini_core_wb
( 
 .Clock     (Clock ), // input  logic           Clock,       //input 
 .Rst       (Rst   ), // input  logic           Rst,         //input  
 // Ctrl
 .Ctrl      (CtrlWb),  // input var  t_ctrl_wb       Ctrl  //input
 // Data path input
 .DMemRdDataQ104H (DMemRdRspQ104H ), // input  logic [31:0]    DMemRdDataQ104H, //input
 .AluOutQ104H     (AluOutQ104H     ), // input  logic [31:0]    AluOutQ104H,     //input
 .PcPlus4Q104H    (PcPlus4Q104H    ), // input  logic [31:0]    PcPlus4Q104H,    //input
 // data path output
 .RegWrDataQ104H  (RegWrDataQ104H  )  // output logic [31:0]    RegWrDataQ104H  //output

);

endmodule // Module mafia_asap_5pl
