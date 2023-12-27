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

module core_rrv_ctrl
import common_pkg::*;
(
    input   logic        Clock,
    input   logic        Rst,
    // input instruction 
    input   logic [31:0] PreInstructionQ101H,
    input   logic [31:0] PcQ101H,
    // input feedback from data path
    input   logic        BranchCondMetQ102H,
    input   logic        DMemReady,
    // ready signals for "back-pressure" - use as the enable for the pipe stage sample
    output  logic        ReadyQ100H,
    output  logic        ReadyQ101H,
    output  logic        ReadyQ102H,
    output  logic        ReadyQ103H,
    output  logic        ReadyQ104H,
    output  logic        ReadyQ105H,
    // output ctrl signals
    output var t_ctrl_if      CtrlIf,
    output var t_ctrl_rf      CtrlRf,
    output var t_ctrl_exe     CtrlExe,
    output var t_csr_inst_rrv CtrlCsr,
    output var t_ctrl_mem1    CtrlMem1,
    output var t_ctrl_wb      CtrlWb,
    // output data path signals
    output logic [31:0] ImmediateQ101H,
    output var t_csr_hw_updt CsrHwUpdt             
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

t_immediate         SelImmTypeQ101H;
 logic [4:0]  PreRegSrc1Q101H;
 logic [4:0]  PreRegSrc2Q101H;
 logic        LoadHzrd1DetectQ101H;
 logic        LoadHzrd2DetectQ101H;
 logic [31:0] InstructionQ101H;
 logic        flushQ102H;
 logic        flushQ103H;
 t_opcode     OpcodeQ101H;
 logic [2:0]  Funct3Q101H;
 logic [6:0]  Funct7Q101H;
logic PreValidInstQ101H, ValidInstQ101H;
logic PreValidInstQ102H, ValidInstQ102H;
logic PreValidInstQ103H, ValidInstQ103H;
logic PreValidInstQ104H, ValidInstQ104H;
logic PreValidInstQ105H, ValidInstQ105H;

t_mini_ctrl CtrlQ101H, CtrlQ102H, CtrlQ103H, CtrlQ104H, CtrlQ105H;
t_csr_inst_rrv CsrInstQ101H, CsrInstQ102H;  
logic CoreFreeze;
assign CoreFreeze = !DMemReady;
// Load and Ctrl hazard detection
assign PreRegSrc1Q101H           = PreInstructionQ101H[19:15];
assign PreRegSrc2Q101H           = PreInstructionQ101H[24:20];
assign LoadHzrd1DetectQ101H      = Rst ? 1'b0 : 
                                 ((PreRegSrc1Q101H == CtrlQ102H.RegDst) && (CtrlQ102H.Opcode == LOAD)) ? 1'b1:
                                 ((PreRegSrc2Q101H == CtrlQ102H.RegDst) && (CtrlQ102H.Opcode == LOAD)) ? 1'b1:
                                                                                                         1'b0;                                                                                                        
assign LoadHzrd2DetectQ101H      = Rst ? 1'b0 : 
                                 ((PreRegSrc1Q101H == CtrlQ103H.RegDst) && (CtrlQ103H.Opcode == LOAD)) ? 1'b1:
                                 ((PreRegSrc2Q101H == CtrlQ103H.RegDst) && (CtrlQ103H.Opcode == LOAD)) ? 1'b1:
                                                                                                         1'b0;                                                                                                        
//incase of a jump/branch we select the ALU out in pipe stage 102, which means we need to flush the pipe for 2 cycles:
logic IndirectBranchQ102H;
assign IndirectBranchQ102H = (CtrlQ102H.SelNextPcAluOutB && BranchCondMetQ102H) || (CtrlQ102H.SelNextPcAluOutJ);
assign flushQ102H = IndirectBranchQ102H;
`MAFIA_EN_DFF(flushQ103H , flushQ102H   , Clock , ReadyQ103H)

assign InstructionQ101H = flushQ102H           ? NOP :
                          flushQ103H           ? NOP :
                          LoadHzrd1DetectQ101H ? NOP :
                          LoadHzrd2DetectQ101H ? NOP : 
                                                PreInstructionQ101H;
assign PreValidInstQ101H = flushQ102H           ? 1'b0 : 
                           flushQ103H           ? 1'b0 :
                           LoadHzrd1DetectQ101H ? 1'b0 :  
                           LoadHzrd2DetectQ101H ? 1'b0 : 
                                                  1'b1 ;

// End Load and Ctrl hazard detection
assign OpcodeQ101H                = t_opcode'(InstructionQ101H[6:0]);
assign Funct3Q101H                = InstructionQ101H[14:12];
assign Funct7Q101H                = InstructionQ101H[31:25];
assign CtrlQ101H.Pc               = PcQ101H;
assign CtrlQ101H.Instruction      = InstructionQ101H;
assign CtrlQ101H.Opcode           = OpcodeQ101H;
assign CtrlQ101H.SelNextPcAluOutJ = (OpcodeQ101H == JAL) || (OpcodeQ101H == JALR);
assign CtrlQ101H.SelNextPcAluOutB = (OpcodeQ101H == BRANCH);
assign CtrlQ101H.SelRegWrPc       = (OpcodeQ101H == JAL) || (OpcodeQ101H == JALR);
assign CtrlQ101H.SelAluPc         = (OpcodeQ101H == JAL) || (OpcodeQ101H == BRANCH) || (OpcodeQ101H == AUIPC);
assign CtrlQ101H.SelAluImm        =!(OpcodeQ101H == R_OP); // Only in case of RegReg Operation the Imm Selector is deasserted - defualt is asserted
assign CtrlQ101H.SelDMemWb        = (OpcodeQ101H == LOAD);
assign CtrlQ101H.e_SelWrBack      = (OpcodeQ101H == JAL) || (OpcodeQ101H == JALR) ? WB_PC4  :
                                    (OpcodeQ101H == LOAD)                         ? WB_DMEM :
                                                                                    WB_ALU  ;
assign CtrlQ101H.Lui              = (OpcodeQ101H == LUI);
assign CtrlQ101H.RegWrEn          = (OpcodeQ101H == LUI ) || (OpcodeQ101H == AUIPC) || (OpcodeQ101H == JAL)  || (OpcodeQ101H == JALR) ||
                                    (OpcodeQ101H == LOAD) || (OpcodeQ101H == I_OP)  || (OpcodeQ101H == R_OP) || (OpcodeQ101H == FENCE)|| CsrInstQ101H.csr_rden;
assign CtrlQ101H.DMemWrEn         = (OpcodeQ101H == STORE);
assign CtrlQ101H.DMemRdEn         = (OpcodeQ101H == LOAD);
assign CtrlQ101H.SignExt          = (OpcodeQ101H == LOAD) && (!Funct3Q101H[2]); // Sign extend the LOAD from memory read.
assign CtrlQ101H.DMemByteEn       = ((OpcodeQ101H == LOAD) || (OpcodeQ101H == STORE)) && (Funct3Q101H[1:0] == 2'b00) ? 4'b0001 : // LB || SB
                                    ((OpcodeQ101H == LOAD) || (OpcodeQ101H == STORE)) && (Funct3Q101H[1:0] == 2'b01) ? 4'b0011 : // LH || SH
                                    ((OpcodeQ101H == LOAD) || (OpcodeQ101H == STORE)) && (Funct3Q101H[1:0] == 2'b10) ? 4'b1111 : '0; // LW || SW - TODO - check the default value
assign CtrlQ101H.BranchOp         = t_branch_type'(Funct3Q101H);
assign CtrlQ101H.RegDst           = InstructionQ101H[11:7];
assign CtrlQ101H.RegSrc1          = InstructionQ101H[19:15];
assign CtrlQ101H.RegSrc2          = InstructionQ101H[24:20];

// CSR Control Signals
assign CsrInstQ101H.csr_wren     = (OpcodeQ101H == SYSCAL) && !(((Funct3Q101H[1:0] == 2'b11) || (Funct3Q101H[1:0] == 2'b10)) && (CtrlQ101H.RegSrc1 =='0 ));  
assign CsrInstQ101H.csr_rden     = (OpcodeQ101H == SYSCAL) && !((Funct3Q101H[1:0]==2'b01 ) && (CtrlQ101H.RegDst =='0 ));
assign CsrInstQ101H.csr_op       = InstructionQ101H[13:12];
assign CsrInstQ101H.csr_rs1      = CtrlQ101H.RegSrc1;
assign CsrInstQ101H.csr_addr     = InstructionQ101H[31:20];
assign CsrInstQ101H.csr_data_imm = {27'h0, CtrlQ101H.RegSrc1}; 
assign CsrInstQ101H.csr_imm_bit  = InstructionQ101H[14];  

logic ebreak_was_calledQ101H; 
assign ebreak_was_calledQ101H = (InstructionQ101H == 32'b000000000001_00000_000_00000_1110011);

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

//FIXME - there are various reasons for back-pressure. Need to code it here
assign ReadyQ105H = (!CoreFreeze); // FIXME - this is back pressure from mem_wrap incase of non-local memory load 
assign ReadyQ104H = (!CoreFreeze);
assign ReadyQ103H = (!CoreFreeze);
assign ReadyQ102H = (!CoreFreeze);//
assign ReadyQ101H = ((!CoreFreeze) && !(LoadHzrd1DetectQ101H || LoadHzrd2DetectQ101H)) || flushQ102H; //
//assign ReadyQ101H = flushQ102H ? 1'b1 : (!CoreFreeze) && !(LoadHzrd1DetectQ101H || LoadHzrd2DetectQ101H);
assign ReadyQ100H = (!CoreFreeze) && ReadyQ101H;//
// Sample the Ctrl bits through the pipe
`MAFIA_EN_RST_DFF(CtrlQ102H, CtrlQ101H, Clock, ReadyQ102H, Rst )
`MAFIA_EN_RST_DFF(CsrInstQ102H, CsrInstQ101H, Clock, ReadyQ102H, Rst )
`MAFIA_EN_DFF    (CtrlQ103H, CtrlQ102H, Clock, ReadyQ103H )
`MAFIA_EN_DFF    (CtrlQ104H, CtrlQ103H, Clock, ReadyQ104H )
`MAFIA_EN_DFF    (CtrlQ105H, CtrlQ104H, Clock, ReadyQ105H )


assign ValidInstQ101H = ReadyQ101H && PreValidInstQ101H;
`MAFIA_EN_RST_DFF(PreValidInstQ102H, ValidInstQ101H, Clock, ReadyQ102H, Rst )
assign ValidInstQ102H = ReadyQ102H && PreValidInstQ102H;
`MAFIA_EN_DFF    (PreValidInstQ103H, ValidInstQ102H, Clock, ReadyQ103H)
assign ValidInstQ103H = ReadyQ103H && PreValidInstQ103H;
`MAFIA_EN_DFF    (PreValidInstQ104H, ValidInstQ103H, Clock, ReadyQ104H)
assign ValidInstQ104H = ReadyQ104H && PreValidInstQ104H;
`MAFIA_EN_DFF    (PreValidInstQ105H, ValidInstQ104H, Clock, ReadyQ105H)
assign ValidInstQ105H = ReadyQ105H && PreValidInstQ105H;

// update CSR_INSTRET
assign CsrHwUpdt.ValidInstQ105H = ValidInstQ105H;  

// Instruction Fetch Control Signals
assign CtrlIf.SelNextPcAluOutQ102H =  IndirectBranchQ102H;

//Register File Control Signals
assign CtrlRf.RegSrc1Q101H  = CtrlQ101H.RegSrc1;
assign CtrlRf.RegSrc2Q101H  = CtrlQ101H.RegSrc2;
assign CtrlRf.RegDstQ105H   = CtrlQ105H.RegDst;
assign CtrlRf.RegWrEnQ105H  = ValidInstQ105H ? CtrlQ105H.RegWrEn : 1'b0;

//Execute Control Signals
assign CtrlExe.RegSrc1Q102H  = CtrlQ102H.RegSrc1;
assign CtrlExe.RegSrc2Q102H  = CtrlQ102H.RegSrc2;
assign CtrlExe.AluOpQ102H    = CtrlQ102H.AluOp;
assign CtrlExe.LuiQ102H      = CtrlQ102H.Lui;
assign CtrlExe.BranchOpQ102H = CtrlQ102H.BranchOp;
assign CtrlExe.RegDstQ103H   = CtrlQ103H.RegDst;
assign CtrlExe.RegWrEnQ103H  = CtrlQ103H.RegWrEn;
assign CtrlExe.RegWrEnQ104H  = CtrlQ104H.RegWrEn;
assign CtrlExe.RegDstQ104H   = CtrlQ104H.RegDst;
assign CtrlExe.RegWrEnQ105H  = CtrlQ105H.RegWrEn;
assign CtrlExe.RegDstQ105H   = CtrlQ105H.RegDst;
assign CtrlExe.SelAluPcQ102H = CtrlQ102H.SelAluPc;
assign CtrlExe.SelAluImmQ102H= CtrlQ102H.SelAluImm;

// Execute Control Signals for Csr
assign CtrlCsr = CsrInstQ102H;

// Memory access1 Control Signals
assign CtrlMem1.DMemWrEnQ103H   = CtrlQ103H.DMemWrEn;  
assign CtrlMem1.DMemRdEnQ103H   = CtrlQ103H.DMemRdEn;  
assign CtrlMem1.DMemByteEnQ103H = CtrlQ103H.DMemByteEn;

// Write Back Control Signals
assign CtrlWb.ByteEnQ105H      = CtrlQ105H.DMemByteEn;
assign CtrlWb.SignExtQ105H     = CtrlQ105H.SignExt;
assign CtrlWb.e_SelWrBackQ105H = CtrlQ105H.e_SelWrBack;

endmodule

