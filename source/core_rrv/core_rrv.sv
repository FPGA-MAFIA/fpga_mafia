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
// Will be implemented in a 6 stage pipeline micro-architecture.
// ---- 6 Pipeline Stages -----
// 1) Q100H Instruction Fetch
// 2) Q101H Instruction Decode 
// 3) Q102H Execute 
// 4) Q103H Memory Access1
// 5) Q104H Memory Access2
// 6) Q105H Write back data from Memory/ALU to Register file
// ---- extentions ----
// Support RV32IE
// Support CSR 
// Support Interrupts


`include "macros.sv"

module core_rrv 
import common_pkg::*;
#(parameter RF_NUM_MSB) 
(
    input  logic        Clock,
    input  logic        Rst,
    input  logic        RstPc,
    // Instruction Memory
    output logic       ReadyQ101H,
    output logic [31:0] PcQ100H,             // To I_MEM
    input  logic [31:0] PreInstructionQ101H, // From I_MEM
    // Data Memory
    input  logic          DMemReady,    // From D_MEM
    output t_core2mem_req Core2DmemReqQ103H,
    input  logic [31:0]   DMemRdRspQ105H     // From D_MEM  
);

// ---- Data-Path signals ----
logic [31:0]  PcQ101H, PcQ102H;
logic [31:0]  PcPlus4Q103H, PcPlus4Q104H, PcPlus4Q105H;
logic [31:0]  ImmediateQ101H, ImmediateQ102H;
logic [31:0]  AluOutQ102H, AluOutQ103H, AluOutQ104H, AluOutQ105H;
logic [31:0]  PreRegRdData1Q102H, RegRdData1Q102H;
logic [31:0]  PreRegRdData2Q102H, RegRdData2Q102H;
logic [31:0]  RegWrDataQ104H; 
logic [31:0]  RegWrDataQ105H; 
logic [31:0]  DMemWrDataQ103H;
logic [31:0]  CsrReadDataQ102H;      // data red from CSR
logic [31:0]  CsrWriteDataQ102H;     // data writen to csr

// Control bits
logic         BranchCondMetQ102H;
logic         ReadyQ100H;
logic         ReadyQ102H;
logic         ReadyQ103H;
logic         ReadyQ104H;
logic         ReadyQ105H;
t_csr_hw_updt       CsrHwUpdt;
t_mini_ctrl   Ctrl;
t_ctrl_if     CtrlIf;
t_ctrl_rf     CtrlRf;
t_ctrl_exe    CtrlExe;
t_ctrl_mem1    CtrlMem1;
t_ctrl_wb     CtrlWb;
t_csr_inst_rrv CtrlCsr;

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
core_rrv_if core_rrv_if (
  .Clock        (Clock       ), // input  logic        Clock,
  .Rst          (Rst         ), // input  logic        Rst,
  .RstPc        (RstPc       ), // input  logic        RstPc,
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
core_rrv_ctrl core_rrv_ctrl (
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
  .ReadyQ105H           (ReadyQ105H), //  output 
  // output ctrl signals
  .CtrlIf               (CtrlIf             ), //output
  .CtrlRf               (CtrlRf             ), //output
  .CtrlExe              (CtrlExe            ), //output
  .CtrlCsr              (CtrlCsr            ), //output
  .CtrlMem1             (CtrlMem1           ), //output
  .CtrlWb               (CtrlWb             ), //output
  // output data path signals
  .ImmediateQ101H       (ImmediateQ101H     ), //output
  .CsrHwUpdt            (CsrHwUpdt          ) //output
);

core_rrv_rf 
#( .RF_NUM_MSB(RF_NUM_MSB) )    
core_rrv_rf (
  .Clock             (Clock),             // input
  .Rst               (Rst),               // input 
  .Ctrl              (CtrlRf),            // input
  .ReadyQ102H        (ReadyQ102H),        // input
  // input data path
  .ImmediateQ101H    (ImmediateQ101H),    // input
  .PcQ101H           (PcQ101H),           // input  
  .RegWrDataQ105H    (RegWrDataQ105H),    // input 
  // output data path 
  .PcQ102H           (PcQ102H),           // output   
  .ImmediateQ102H    (ImmediateQ102H),    // output
  .RegRdData1Q102H   (RegRdData1Q102H),   // output
  .RegRdData2Q102H   (RegRdData2Q102H)    // output
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
core_rrv_exe core_rrv_exe (
  .Clock               (Clock              ),  //  input 
  .Rst                 (Rst                ),  //  input 
  // Input Control Signals
  .Ctrl                (CtrlExe            ),  //  input 
  .CtrlCsr             (CtrlCsr            ),  //  input
  .ReadyQ103H          (ReadyQ103H         ),  //  input
  // Output Control Signals
  .BranchCondMetQ102H  (BranchCondMetQ102H ),  //  output
  // Input Data path
  //Q102H
  .PreRegRdData1Q102H  (RegRdData1Q102H    ),  //  input 
  .PreRegRdData2Q102H  (RegRdData2Q102H    ),  //  input  
  .PcQ102H             (PcQ102H            ),  //  input 
  .ImmediateQ102H      (ImmediateQ102H     ),  //  input
  .CsrReadDataQ102H    (CsrReadDataQ102H   ), 
  //Q104H
  .AluOutQ104H         (AluOutQ104H     ),     //  input 
  //Q105H
  .RegWrDataQ105H      (RegWrDataQ105H     ),  //  input 
  // output data path
  .AluOutQ102H         (AluOutQ102H        ),  //  output
  .CsrWriteDataQ102H   (CsrWriteDataQ102H),    // output
  .AluOutQ103H         (AluOutQ103H        ),  //  output
  .PcPlus4Q103H        (PcPlus4Q103H       ),  //  output
  .DMemWrDataQ103H     (DMemWrDataQ103H    )   //  output
);

core_rrv_csr core_rrv_csr (
 .Clk             (Clock),  
 .Rst             (Rst),  
 .PcQ102H         (PcQ102H),
 // Inputs from the core
 .CsrInstQ102H     (CtrlCsr),
 .CsrWriteDataQ102H(CsrWriteDataQ102H), 
 .CsrHwUpdt        (CsrHwUpdt),// FIXME: support hardware update for CSR (example: mstatus, mcause, ...)
 .MePc             (),
 .interrupt_counter_expired (),
 // Outputs to the core
 .CsrReadDataQ102H(CsrReadDataQ102H)
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
// Memory Access1
// -----------------
// 1. Access D_MEM for Wrote (STORE) and Reads (LOAD)
// 2. In case of Reads (LOAD) send request to memory and wait for response in the next stage
//////////////////////////////////////////////////////////////////////////////////////////////////
core_rrv_mem_acs1 core_rrv_mem_access1 (
  .Clock              (Clock),          //input 
  .Rst                (Rst),            //input  
  // Input Control Signals
  .Ctrl               (CtrlMem1),       //input
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

/////////////////////////////////////////////////////////////////////////////////////////////////////
// TODO - fix that stage to 5
//   ____  __     __   _____   _        ______          ____    __    ___    _  _     _    _ 
//  / ____| \ \   / /  / ____| | |      |  ____|        / __ \  /_ |  / _ \  | || |   | |  | |
// | |       \ \_/ /  | |      | |      | |__          | |  | |  | | | | | | | || |_  | |__| |
// | |        \   /   | |      | |      |  __|         | |  | |  | | | | | | |__   _| |  __  |
// | |____     | |    | |____  | |____  | |____        | |__| |  | | | |_| |    | |   | |  | |
//  \_____|    |_|     \_____| |______| |______|        \___\_\  |_|  \___/     |_|   |_|  |_|
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
// Memory Access 2 
// -----------------
// 1. Respond to D_MEM for Reads (LOAD) 
// 2. Pass data "as is" to the next stage in case of R, J, U and I (not include LOAD) instructions
/////////////////////////////////////////////////////////////////////////////////////////////////////
core_rrv_mem_acs2 core_rrv_mem_access2 (
  .Clock              (Clock),          //input 
  .Rst                (Rst),            //input  
  // Input Control Signals
  .ReadyQ105H         (ReadyQ105H),     //input
  // Input Data path
  .PcPlus4Q104H       (PcPlus4Q104H),   //input
  .AluOutQ104H        (AluOutQ104H),    //input
  // data path output 
  .PcPlus4Q105H       (PcPlus4Q105H),   //input
  .AluOutQ105H        (AluOutQ105H)     //input
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
core_rrv_wb core_rrv_wb
( 
 .Clock     (Clock ), // input  logic           Clock,       //input 
 .Rst       (Rst   ), // input  logic           Rst,         //input  
 // Ctrl
 .Ctrl      (CtrlWb),  // input var  t_ctrl_wb       Ctrl  //input
 // Data path input
 .DMemRdDataQ105H (DMemRdRspQ105H ), // input  logic [31:0]    DMemRdDataQ105H, //input
 .AluOutQ105H     (AluOutQ105H     ), // input  logic [31:0]    AluOutQ105H,     //input
 .PcPlus4Q105H    (PcPlus4Q105H    ), // input  logic [31:0]    PcPlus4Q105H,    //input
 // data path output
 .RegWrDataQ105H  (RegWrDataQ105H  )  // output logic [31:0]    RegWrDataQ105H  //output

);


endmodule // Module mafia_asap_5pl
