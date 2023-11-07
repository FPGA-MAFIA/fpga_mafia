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

module mini_core 
import common_pkg::*;
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
    input  logic [31:0]   DMemRdRspQ105H     // From D_MEM  
);

// ---- Data-Path signals ----
// Program counter
logic [31:0]        PcQ101H, PcQ102H;
logic [31:0]        PcPlus4Q100H, PcPlus4Q101H, PcPlus4Q102H, PcPlus4Q103H, PcPlus4Q104H, PcPlus4Q105H;
logic [31:0]        NextPcQ102H;
logic [31:0]        InstructionQ101H;

logic [31:1][31:0]  Register; 
logic [31:0]        ImmediateQ101H, ImmediateQ102H;
logic [4:0]         ShamtQ102H;
logic [31:0]        AluIn1Q102H;
logic [31:0]        AluIn2Q102H;
logic [31:0]        AluOutQ102H, AluOutQ103H, AluOutQ104H, AluOutQ105H;
logic [31:0]        RegRdData1Q101H, PreRegRdData1Q102H, RegRdData1Q102H, RegRdData1Q103H;
logic [31:0]        RegRdData2Q101H, PreRegRdData2Q102H, RegRdData2Q102H, RegRdData2Q103H;
logic [31:0]        RegWrDataQ104H, RegWrDataQ105H; 
logic [31:0]        PostSxDMemRdDataQ105H;
logic [31:0]        RegRdCsrData1Q101H;    // data to write to CSR
logic [31:0]        CsrReadDataQ102H;      // data red from CSR


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
logic ReadyQ100H;
t_mini_ctrl Ctrl;
logic DMemRdRspValid;
logic ReadyQ102H;
logic ReadyQ103H;
logic ReadyQ104H;
logic ReadyQ105H;
t_ctrl_if   CtrlIf;
t_ctrl_rf   CtrlRf;
t_ctrl_exe  CtrlExe;
t_csr_inst  CtrlCsr;
t_ctrl_mem1 CtrlMem1;
t_ctrl_wb   CtrlWb;


logic [31:0] DMemWrDataQ103H;

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
  .ReadyQ105H           (ReadyQ105H), //  output 
  // output ctrl signals
  .CtrlIf               (CtrlIf             ), //output
  .CtrlRf               (CtrlRf             ), //output
  .CtrlExe              (CtrlExe            ), //output
  .CtrlCsr              (CtrlCsr            ), //output
  .CtrlMem1             (CtrlMem1           ), //output
  .CtrlWb               (CtrlWb             ), //output
  // input data path signals
  .RegRdCsrData1Q101H   (RegRdCsrData1Q101H ), //input
  // output data path signals
  .ImmediateQ101H       (ImmediateQ101H     ) //output
);

mini_core_rf 
#( .RF_NUM_MSB(RF_NUM_MSB) )    
mini_core_rf (
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
  .RegRdCsrData1Q101H(RegRdCsrData1Q101H),// output
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
mini_core_exe mini_core_exe (
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
  .AluOutQ103H         (AluOutQ103H        ),  //  output
  .PcPlus4Q103H        (PcPlus4Q103H       ),  //  output
  .DMemWrDataQ103H     (DMemWrDataQ103H    )   //  output
);

mini_core_csr mini_core_csr (
 .Clk             (Clock),  
 .Rst             (Rst),  
 .PcQ102H         (PcQ102H),
 // Inputs from the core
 .CsrInstQ102H    (CtrlCsr), 
 .CsrHwUpdt       ('0),// FIXME: support hardware update for CSR (example: mstatus, mcause, ...)
 .MePc            (),
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
mini_core_mem_acs1 mini_core_mem_access1 (
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
//    ____  __     __   _____   _        ______          ____    __    ___    _  _     _    _ 
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
mini_core_mem_acs2 mini_core_mem_access2 (
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
mini_core_wb mini_core_wb
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
