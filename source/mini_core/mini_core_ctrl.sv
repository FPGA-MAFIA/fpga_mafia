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

module mini_core_ctrl
import common_pkg::*;
(
    input   logic        Clock,
    input   logic        Rst,
    // input instruction 
    input   logic [31:0] PreInstructionQ101H,
    // input feedback from data path
    input   logic        BranchCondMetQ102H,
    input   logic        DMemReady,
    input   logic        DMemRdRspValid,
    // output ctrl signals
    output  t_ctrl_if    CtrlIf,
    output  t_ctrl_rf    CtrlRf,
    output  t_ctrl_exe   CtrlExe,
    output  t_ctrl_mem   CtrlMem,
    output  t_ctrl_wb    CtrlWb,
    // output data path signals
    output  logic [31:0] ImmediateQ101H 
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
// 2. Get the instruction from I_MEM and use the decoder to set the Ctrl Bits.
// 3. Use the rs1 & rs2 (RegSrc) to read the Register file data.
// 4. construct the Immediate types.
// ----------------- 
//////////////////////////////////////////////////////////////////////////////////////////////////


assign CoreFreeze = 1'b0;
`MAFIA_EN_DFF(PreviousInstructionQ102H , PreInstructionQ101H   , Clock , !(CoreFreeze)
// Load and Ctrl hazard detection
assign PreRegSrc1Q101H           = PreInstructionQ101H[19:15];
assign PreRegSrc2Q101H           = PreInstructionQ101H[24:20];
assign LoadHzrdDetectQ101H       = Rst ? 1'b0 : 
                                 ((PreRegSrc1Q101H == RegDstQ102H) && (OpcodeQ102H == LOAD)) ? 1'b1:
                                 ((PreRegSrc2Q101H == RegDstQ102H) && (OpcodeQ102H == LOAD)) ? 1'b1:
                                                                                               1'b0;
assign PcEnQ101H                = !LoadHzrdDetectQ101H;
assign InstructionQ101H         = flushQ102H          ? NOP :
                                  flushQ103H          ? NOP :
                                  LoadHzrdDetectQ101H ? NOP : 
                                  LoadHzrdDetectQ102H ? PreviousInstructionQ102H :
                                                        PreInstructionQ101H;

// End Load and Ctrl hazard detection
t_mini_ctrl CtrlQ101H, CtrlQ102H, CtrlQ103H, CtrlQ104H;
assign OpcodeQ101H                = t_opcode'(InstructionQ101H[6:0]);
assign Funct3Q101H                = InstructionQ101H[14:12];
assign Funct7Q101H                = InstructionQ101H[31:25];
assign CtrlQ101H.SelNextPcAluOutJ = (OpcodeQ101H == JAL) || (OpcodeQ101H == JALR);
assign CtrlQ101H.SelNextPcAluOutB = (OpcodeQ101H == BRANCH);
assign CtrlQ101H.SelRegWrPc       = (OpcodeQ101H == JAL) || (OpcodeQ101H == JALR);
assign CtrlQ101H.SelAluPc         = (OpcodeQ101H == JAL) || (OpcodeQ101H == BRANCH) || (OpcodeQ101H == AUIPC);
assign CtrlQ101H.SelAluImm        =!(OpcodeQ101H == R_OP); // Only in case of RegReg Operation the Imm Selector is deasserted - defualt is asserted
assign CtrlQ101H.SelDMemWb        = (OpcodeQ101H == LOAD);
assign CtrlQ101H.Lui              = (OpcodeQ101H == LUI);
assign CtrlQ101H.RegWrEn          = (OpcodeQ101H == LUI ) || (OpcodeQ101H == AUIPC) || (OpcodeQ101H == JAL)  || (OpcodeQ101H == JALR) ||
                                    (OpcodeQ101H == LOAD) || (OpcodeQ101H == I_OP)  || (OpcodeQ101H == R_OP) || (OpcodeQ101H == FENCE);
assign CtrlQ101H.DMemWrEn         = (OpcodeQ101H == STORE);
assign CtrlQ101H.DMemRdEn         = (OpcodeQ101H == LOAD);
assign CtrlQ101H.SignExt          = (OpcodeQ101H == LOAD) && (!Funct3Q101H[2]); // Sign extend the LOAD from memory read.
assign CtrlQ101H.DMemByteEn       = ((OpcodeQ101H == LOAD) || (OpcodeQ101H == STORE)) && (Funct3Q101H[1:0] == 2'b00) ? 4'b0001 : // LB || SB
                                    ((OpcodeQ101H == LOAD) || (OpcodeQ101H == STORE)) && (Funct3Q101H[1:0] == 2'b01) ? 4'b0011 : // LH || SH
                                    ((OpcodeQ101H == LOAD) || (OpcodeQ101H == STORE)) && (Funct3Q101H[1:0] == 2'b10) ? 4'b1111 : // LW || SW
assign CtrlQ101H.BranchOp         = t_branch_type'(Funct3Q101H);
assign CtrlQ101H.RegDst           = InstructionQ101H[11:7]
assign CtrlQ101H.RegSrc1          = InstructionQ101H[19:15];
assign CtrlQ101H.RegSrc2          = InstructionQ101H[24:20];

logic ebreak_was_calledQ101H; 
assign ebreak_was_called      = (InstructionQ101H == 32'b000000000001_00000_000_00000_1110011);

always_comb begin
    unique casez ({Funct3Q101H, Funct7Q101H, OpcodeQ101H})
    // ---- R type ----
    {3'b000, 7'b0000000, R_OP} : CtrlQ101H.AluOp = ADD;  // ADD
    {3'b000, 7'b0100000, R_OP} : CtrlQ101H.AluOp = SUB;  // SUB
    {3'b001, 7'b0000000, R_OP} : CtrlQ101H.AluOp = SLL;  // SLL
    {3'b010, 7'b0000000, R_OP} : CtrlQ101H.AluOp = SLT;  // SLT
    {3'b011, 7'b0000000, R_OP} : CtrlQ101H.AluOp = SLTU; // SLTU
    {3'b100, 7'b0000000, R_OP} : CtrlQ101H.AluOp = XOR;  // XOR
    {3'b101, 7'b0000000, R_OP} : CtrlQ101H.AluOp = SRL;  // SRL
    {3'b101, 7'b0100000, R_OP} : CtrlQ101H.AluOp = SRA;  // SRA
    {3'b110, 7'b0000000, R_OP} : CtrlQ101H.AluOp = OR;   // OR
    {3'b111, 7'b0000000, R_OP} : CtrlQ101H.AluOp = AND;  // AND
    // ---- I type ----
    {3'b000, 7'b???????, I_OP} : CtrlQ101H.AluOp = ADD;  // ADDI
    {3'b010, 7'b???????, I_OP} : CtrlQ101H.AluOp = SLT;  // SLTI
    {3'b011, 7'b???????, I_OP} : CtrlQ101H.AluOp = SLTU; // SLTUI
    {3'b100, 7'b???????, I_OP} : CtrlQ101H.AluOp = XOR;  // XORI
    {3'b110, 7'b???????, I_OP} : CtrlQ101H.AluOp = OR;   // ORI
    {3'b111, 7'b???????, I_OP} : CtrlQ101H.AluOp = AND;  // ANDI
    {3'b001, 7'b0000000, I_OP} : CtrlQ101H.AluOp = SLL;  // SLLI
    {3'b101, 7'b0000000, I_OP} : CtrlQ101H.AluOp = SRL;  // SRLI
    {3'b101, 7'b0100000, I_OP} : CtrlQ101H.AluOp = SRA;  // SRAI
    // ---- Other ----
    default                    : CtrlQ101H.AluOp = ADD;  // LUI || AUIPC || JAL || JALR || BRANCH || LOAD || STORE
    endcase
end
// Immediate Generator
always_comb begin
  unique casez (OpcodeQ101H) // Mux
    JALR, I_OP, LOAD : SelImmTypeQ101H = I_TYPE;
    LUI, AUIPC       : SelImmTypeQ101H = U_TYPE;
    JAL              : SelImmTypeQ101H = J_TYPE;
    BRANCH           : SelImmTypeQ101H = B_TYPE;
    STORE            : SelImmTypeQ101H = S_TYPE;
    default          : SelImmTypeQ101H = I_TYPE;
  endcase
  unique casez (SelImmTypeQ101H) // Mux
    U_TYPE : ImmediateQ101H = {     InstructionQ101H[31:12], 12'b0 } ;                                                                            // U_Immediate
    I_TYPE : ImmediateQ101H = { {20{InstructionQ101H[31]}} , InstructionQ101H[31:20] };                                                           // I_Immediate
    S_TYPE : ImmediateQ101H = { {20{InstructionQ101H[31]}} , InstructionQ101H[31:25] , InstructionQ101H[11:7]  };                                 // S_Immediate
    B_TYPE : ImmediateQ101H = { {20{InstructionQ101H[31]}} , InstructionQ101H[7]     , InstructionQ101H[30:25] , InstructionQ101H[11:8]  , 1'b0}; // B_Immediate
    J_TYPE : ImmediateQ101H = { {12{InstructionQ101H[31]}} , InstructionQ101H[19:12] , InstructionQ101H[20]    , InstructionQ101H[30:21] , 1'b0}; // J_Immediate
    default: ImmediateQ101H = {     InstructionQ101H[31:12], 12'b0 };                                                                             // U_Immediate
  endcase
end


// Sample the Ctrl bits though the pipe
`MAFIA_DFF(CtrlQ102H, CtrlQ101H, Clock)
`MAFIA_DFF(CtrlQ103H, CtrlQ102H, Clock)
`MAFIA_DFF(CtrlQ104H, CtrlQ103H, Clock)

// Instruction Fetch Control Signals
assign CtrlIf   =

//Register File Control Signals
assign CtrlRf.RegSrc1Q101H  = CtrlQ101H.RegSrc1;
assign CtrlRf.RegSrc2Q101H  = CtrlQ101H.RegSrc2;
assign CtrlRf.RegDstQ104H   = CtrlQ104H.RegDst;
assign CtrlRf.RegWrEnQ104H  = CtrlQ104H.RegWrEn;

//Execute Control Signals
assign CtrlExe.RegSrc1Q102H  = CtrlQ102H.RegSrc1;
assign CtrlExe.RegSrc2Q102H  = CtrlQ102H.RegSrc2;
assign CtrlExe.AluOpQ102H    = CtrlQ102H.AluOp;
assign CtrlExe.LuiQ102H      = CtrlQ102H.Lui;
assign CtrlExe.BranchOpQ102H = CtrlQ102H.BranchOp;
assign CtrlExe.RegDstQ103H   = CtrlQ103H.RegDst;
assign CtrlExe.RegDstQ104H   = CtrlQ104H.RegDst;

// Memory access Control Signals
assign CtrlMem  =

// Write Back Control Signals
assign CtrlWb   =

endmodule


