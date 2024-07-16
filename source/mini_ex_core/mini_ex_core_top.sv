
`include "macros.vh"

module mini_ex_core_top 
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
logic [31:0]  PcPlus4Q101H;
logic [31:0]  ImmediateQ101H, ImmediateQ102H;
logic [31:0]  AluOutQ102H, AluOutQ103H;
logic [31:0]  PreRegRdData1Q102H, RegRdData1Q102H;
logic [31:0]  PreRegRdData2Q102H, RegRdData2Q102H;
//logic [31:0]  RegWrDataQ104H; 
logic [31:0]  DMemWrDataQ103H;

// Control bits
//logic         BranchCondMetQ102H;
t_contoller_out   CntrlOut;
t_op_type         OpType;



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
mini_core_pc mini_core_pc (
  .Clock        (Clock       ), // input  logic        Clock,
  .Rst          (Rst         ), // input  logic        Rst,
  .JmpEnableQ100H   (Ctrl.JmpEnableQ100H  ), // input  logic       ,
  .JmpAddressQ100H (AluOutQ102H), //placeholder
  //
  .PcPlus4Q100H(PcPlus4Q100H),
  .PcCurrQ100H(PcCurrQ100H)
);

`MAFIA_DFF(PcCurrQ101H, PcCurrQ100H, Clock);
`MAFIA_DFF(PcPlus4Q101H, PcPlus4Q100H, Clock);

//This is the instruction memory
mem  #(
  .WORD_WIDTH(32),                
  .ADRS_WIDTH(I_MEM_ADRS_MSB_MINI+1)   
) i_mem  (
    .clock    (Clock),
    //Core interface (instruction fitch)
    .address_a  (PcCurrQ100H[I_MEM_ADRS_MSB_MINI:2]),           
    .data_a     ('0),
    .wren_a     (1'b0),
    .byteena_a  (4'b0),
    .q_a        (InstructionQ101H),
    //fabric interface
    .address_b  ('0),
    .data_b     ('0),              
    .wren_b     ('0),                
    .byteena_b  ('0), 
    .q_b        (open)              
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


mini_ex_core_controller mini_ex_core_control (
    .Clock                (Clock  ), //input
    .Rst                  (Rst    ), //input
    // input instruction 
    .OpType(OpType),
    .CntrlOut(CntrlOut)
);

mini_ex_core_rg  mini_ex_core_register_file (
    .Clock(Clock),
    .Rst(Rst),
    .RgRead(RgRead),
    .RgWrite(RgWrite),
    //
    .ValRegsQ101H(ValRegsQ101H)
);

mini_ex_core_alu u_mini_ex_core_alu (
        .Clock(Clock),
        .Rst(Rst),
        .AluInputs(AluInputs),
        .AluOutQ101H(AluOutQ101H)
);

`MAFIA_DFF(AluOutQ102H, AluOutQ101H, Clock);

mem   
#(.WORD_WIDTH(32),
  .ADRS_WIDTH(D_MEM_ADRS_MSB_MINI+1) 
) d_mem  (
    .clock    (Clock),
    //Core interface (instruction fitch)
    .address_a  (AluOutQ101H[D_MEM_ADRS_MSB_MINI:2]),
    .data_a     (ValRegsQ101H.Reg2Val),
    .wren_a     (CntrlOut.MemWrEnableQ101H),
    .byteena_a  ('0),
    .q_a        (DMemOutQ102H),
    //fabric interface
    .address_b  ('0),
    .data_b     ('0),              
    .wren_b     ('0),                
    .byteena_b  ('0),
    .q_b        (open)              
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



/////////////////////////////////////////////////////////////////////////////////////////////////