

`include "macros.vh"

module mini_core_di 
import mini_core_di_pkg::*;
#(parameter RF_NUM_MSB) 
(
    input  logic        Clock,
    input  logic        Rst,
    // Instruction Memory
    output logic        ReadyQ101H,
    output logic        ReadyQ201H,
    output logic [31:0] PcQ100H,             // To I_MEM
    output logic [31:0] PcQ200H,             // To I_MEM
    input  logic [31:0] PreInstructionQ101H, // From I_MEM
    input  logic [31:0] PreInstructionQ201H, // From I_MEM
    // Data Memory
    input  logic          DMemReady,    // From D_MEM
    output t_core2mem_req Core2DmemReqQ103H,
    input  logic [31:0]   DMemRdRspQ104H     // From D_MEM
);

// ---- Data-Path signals ----
// ---- issue 1 ----
logic [31:0]  PcQ101H, PcQ102H;
logic [31:0]  PostPcQ101H;
logic [31:0]  PcPlus4Q103H, PcPlus4Q104H;
logic [31:0]  PcPlus8Q103H, PcPlus8Q104H;
logic [31:0]  ImmediateQ101H, ImmediateQ102H;
logic [31:0]  AluOutQ102H, AluOutQ103H, AluOutQ104H;
logic [31:0]  PreRegRdData1Q102H, RegRdData1Q102H;
logic [31:0]  PreRegRdData2Q102H, RegRdData2Q102H;
logic [31:0]  RegWrDataQ104H; 
logic [31:0]  DMemWrDataQ103H;
// ---- issue 2 ----
logic [31:0]  PcQ201H, PcQ202H;
logic [31:0]  PostPcQ201H;
logic [31:0]  PcPlus4Q203H, PcPlus4Q204H;
logic [31:0]  ImmediateQ201H, ImmediateQ202H;
logic [31:0]  AluOutQ202H, AluOutQ203H, AluOutQ204H;
logic [31:0]  PreRegRdData1Q202H, RegRdData1Q202H;
logic [31:0]  PreRegRdData2Q202H, RegRdData2Q202H;
logic [31:0]  RegWrDataQ204H; 

// ---- Real issued signals ----
logic [31:0] PreInstructionQ101H_issued; // From idu to ctrl
logic [31:0] PreInstructionQ201H_issued; // From idu to ctrl

// Control bits
logic         BranchCondMetQ102H;
logic         Issue2ValidNQ201H;
logic         ReadyQ100H;
logic         ReadyQ102H;
logic         ReadyQ103H;
logic         ReadyQ104H;
logic         ReadyQ200H;
logic         ReadyQ202H;
logic         ReadyQ203H;
logic         ReadyQ204H;

//t_mini_ctrl   Ctrl;
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
// 1. Send the PC (program counter) to the I_MEM.
// 2. Calc/Set the NextPc.
// -----------------
//////////////////////////////////////////////////////////////////////////////////////////////////

mini_core_di_if mini_core_di_if (
  .Clock        (Clock       ), // input  logic        Clock,
  .Rst          (Rst         ), // input  logic        Rst,
  .ReadyQ100H   (ReadyQ100H  ), // input  logic        ReadyQ100H,
  .ReadyQ200H   (ReadyQ200H  ), // input  logic        ReadyQ200H,
  .Ctrl         (CtrlIf      ), // input  t_ctrl_if    Ctrl,
  .AluOutQ102H  (AluOutQ102H ), // input  logic [31:0] AluOutQ102H,
  .PcQ100H      (PcQ100H     ), // output logic [31:0] PcQ100H,
  .PcQ200H      (PcQ200H     ), // output logic [31:0] PcQ200H,
  .PcQ101H      (PcQ101H     ), // output logic [31:0] PcQ101H,
  .PcQ201H      (PcQ201H     )  // output logic [31:0] PcQ202H,
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
// 5. Issue instructions to each issue.
// ----------------- 
//////////////////////////////////////////////////////////////////////////////////////////////////

mini_core_di_idu mini_core_di_idu (
  .Clock        (Clock       ), // input  logic        Clock,
  .Rst          (Rst         ), // input  logic        Rst,

  .Ctrl         (CtrlIf      ), // input  t_ctrl_if    Ctrl,

  .PcQ101H      (PcQ101H     ), // input logic [31:0] PcQ101H,
  .PcQ201H      (PcQ101H     ), // input logic [31:0] PcQ201H,

  .ReadyQ101H   (ReadyQ101H  ), // input  logic        ReadyQ101H,
  .PreInstructionQ101H (PreInstructionQ101H), // input  logic
  .ReadyQ201H   (ReadyQ201H  ), // input  logic        ReadyQ201H,
  .PreInstructionQ201H (PreInstructionQ201H), // input  logic

  .PostPcQ101H      (PostPcQ101H     ), // output logic [31:0] PostPcQ101H
  .PreInstructionQ101H_issued (PreInstructionQ101H_issued), // output logic
  .PostPcQ201H      (PostPcQ201H     ), // output logic [31:0]     PostPcQ201H
  .PreInstructionQ201H_issued (PreInstructionQ201H_issued), // output logic

  .issue2ValidN(Issue2ValidNQ201H) // output logic for Ctrl
);

mini_core_di_ctrl mini_core_di_ctrl (
  .Rst                  (Rst    ), //input
  .Clock                (Clock  ), //input
  // input instruction 
  .PreInstructionQ101H  (PreInstructionQ101H_issued), //input
  .PcQ101H              (PostPcQ101H), // output logic [31:0] PcQ101H
  .PreInstructionQ201H  (PreInstructionQ201H_issued), //input
  .PcQ201H              (PostPcQ201H), // output logic [31:0] PcQ101H
  .Issue2ValidNQ201H    (Issue2ValidNQ201H),
  // input feedback from data path
  .BranchCondMetQ102H   (BranchCondMetQ102H), //input
  .DMemReady            (DMemReady), //input
  // ready signals for "back-pressure" - use as the enable for the pipe stage sample
  .ReadyQ100H           (ReadyQ100H), //  output 
  .ReadyQ101H           (ReadyQ101H), //  output 
  .ReadyQ102H           (ReadyQ102H), //  output 
  .ReadyQ103H           (ReadyQ103H), //  output 
  .ReadyQ104H           (ReadyQ104H), //  output 
  .ReadyQ200H           (ReadyQ200H), //  output 
  .ReadyQ201H           (ReadyQ201H), //  output 
  .ReadyQ202H           (ReadyQ202H), //  output 
  .ReadyQ203H           (ReadyQ203H), //  output 
  .ReadyQ204H           (ReadyQ204H), //  output 
  // output ctrl signals
  .CtrlIf               (CtrlIf             ), //output
  .CtrlRf               (CtrlRf             ), //output
  .CtrlExe              (CtrlExe            ), //output
  .CtrlMem              (CtrlMem            ), //output
  .CtrlWb               (CtrlWb             ), //output
  // output data path signals
  .ImmediateQ101H       (ImmediateQ101H     ), //output
  .ImmediateQ201H       (ImmediateQ201H     )  //output
);

mini_core_di_rf 
#( .RF_NUM_MSB(RF_NUM_MSB) )    
mini_core_di_rf (
  .Clock            (Clock),          // input
  .Rst              (Rst),            // input 
  .Ctrl             (CtrlRf),         // input
  .ReadyQ102H       (ReadyQ102H),     // input
  .ReadyQ202H       (ReadyQ202H),     // input
  // input data path
  .ImmediateQ101H   (ImmediateQ101H), // input
  .PcQ101H          (PostPcQ101H),        // input  
  .RegWrDataQ104H   (RegWrDataQ104H), // input 
  .ImmediateQ201H   (ImmediateQ201H), // input
  .PcQ201H          (PostPcQ201H),        // input  
  .RegWrDataQ204H   (RegWrDataQ204H), // input 
  // output data path
  .PcQ102H          (PostPcQ102H),        // output   
  .ImmediateQ102H   (ImmediateQ102H), // output
  .RegRdData1Q102H  (RegRdData1Q102H),// output
  .RegRdData2Q102H  (RegRdData2Q102H), // output
  .PcQ202H          (PostPcQ202H),        // output   
  .ImmediateQ202H   (ImmediateQ202H), // output
  .RegRdData1Q202H  (RegRdData1Q202H),// output
  .RegRdData2Q202H  (RegRdData2Q202H) // output
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
mini_core_dip_exe mini_core_dip_exe (
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
  //Q203
  .AluOutQ203H         (AluOutQ203H     ), //  input   
  //Q104H
  .RegWrDataQ104H      (RegWrDataQ104H     ), //  input 
  .RegWrDataQ204H      (RegWrDataQ204H     ), //  input 
  // output data path
  .AluOutQ102H         (AluOutQ102H        ), //  output
  .AluOutQ103H         (AluOutQ103H        ), //  output
  .PcPlus4Q103H        (PcPlus4Q103H       ), //  output
  .PcPlus8Q103H        (PcPlus8Q103H       ), //  output
  .DMemWrDataQ103H     (DMemWrDataQ103H    )  //  output
);

mini_core_dis_exe mini_core_dis_exe (
  .Clock               (Clock              ), //  input 
  .Rst                 (Rst                ), //  input 
  // Input Control Signals
  .Ctrl                (CtrlExe            ), //  input 
  .ReadyQ203H          (ReadyQ203H         ), //  input
  // Input Data path
  //Q202H
  .PreRegRdData1Q202H  (RegRdData1Q202H ), //  input 
  .PreRegRdData2Q202H  (RegRdData2Q202H ), //  input 
  .PcQ202H             (PcQ202H            ), //  input 
  .ImmediateQ202H      (ImmediateQ202H     ), //  input 
  //Q103
  .AluOutQ103H         (AluOutQ103H     ), //  input 
  //Q204H
  .RegWrDataQ104H      (RegWrDataQ104H     ), //  input 
  .RegWrDataQ204H      (RegWrDataQ204H     ), //  input 

  // output data path
  .AluOutQ202H         (AluOutQ202H        ), //  output
  .AluOutQ203H         (AluOutQ203H        )  //  output
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
mini_core_di_mem_acs mini_core_di_mem_access (
  .Clock              (Clock),          //input 
  .Rst                (Rst),            //input  
  // Input Control Signals
  .Ctrl               (CtrlMem),        //input
  .ReadyQ104H         (ReadyQ104H),     //input
  // Input Data path
  .PcPlus4Q103H       (PcPlus4Q103H),   //input
  .PcPlus8Q103H       (PcPlus8Q103H),   //input
  .AluOutQ103H        (AluOutQ103H),    //input
  .DMemWrDataQ103H    (DMemWrDataQ103H),//input
  // data path output
  .Core2DmemReqQ103H  (Core2DmemReqQ103H),//output
  .PcPlus4Q104H       (PcPlus4Q104H),   //input
  .PcPlus8Q104H       (PcPlus8Q104H),   //input
  .AluOutQ104H        (AluOutQ104H)     //input
);

mini_core_di_mem_dly mini_core_di_mem_delay (
  .Clock              (Clock),          //input 
  .Rst                (Rst),            //input  
  // Input Control Signals
  .ReadyQ204H         (ReadyQ204H),     //input
  // Delay Signals input
  .AluOutQ203H        (AluOutQ203H),    //input
  // Delay Signals output
  .AluOutQ204H        (AluOutQ204H)     //output
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
mini_core_dip_wb mini_core_dip_wb
( 
 .Clock     (Clock ), // input  logic           Clock,       //input 
 .Rst       (Rst   ), // input  logic           Rst,         //input  
 // Ctrl
 .Ctrl      (CtrlWb),  // input var  t_ctrl_wb       Ctrl  //input
 // Data path input
 .DMemRdDataQ104H (DMemRdRspQ104H ), // input  logic [31:0]    DMemRdDataQ104H, //input
 .AluOutQ104H     (AluOutQ104H     ), // input  logic [31:0]    AluOutQ104H,     //input
 .PcPlus4Q104H    (PcPlus4Q104H    ), // input  logic [31:0]    PcPlus4Q104H,    //input
 .PcPlus8Q104H    (PcPlus8Q104H    ), // input  logic [31:0]    PcPlus8Q104H,    //input
 // data path output
 .RegWrDataQ104H  (RegWrDataQ104H  )  // output logic [31:0]    RegWrDataQ104H  //output
);

mini_core_dis_wb mini_core_dis_wb
( 
 .Clock     (Clock ), // input  logic           Clock,       //input 
 .Rst       (Rst   ), // input  logic           Rst,         //input  
 // Ctrl
 .Ctrl      (CtrlWb),  // input var  t_ctrl_wb       Ctrl  //input
 // Data path input
 .AluOutQ204H     (AluOutQ204H     ), // input  logic [31:0]    AluOutQ204H,     //input
 // data path output
 .RegWrDataQ204H  (RegWrDataQ204H  )  // output logic [31:0]    RegWrDataQ204H  //output

);


endmodule // Module mafia_asap_5pl
