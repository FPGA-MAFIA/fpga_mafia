`include "macros.vh"

module mini_core_rrv_ctrl 
import mini_core_rrv_pkg::*;
(
    input logic           Clock,
    input logic           Rst, 
    input logic [31:0]    PreInstructionQ101H,
    input logic           BranchCondMetQ101H,
    output var t_ctrl_if  CtrlIf,
    output var t_ctrl_rf  CtrlRf,
    output var t_ctrl_alu CtrlAlu,
    output var t_ctrl_mem CtrlDmem, 
    output var t_ctrl_wb  CtrlWb,
    output logic [31:0]   ImmediateQ101H

);

var t_opcode OpcodeQ101H;
var t_immediate  SelImmTypeQ101H;
var t_mini_core_rrv_ctrl CtrlQ101H, CtrlQ102H;
logic        [6:0] Funct7Q101H;
logic        [2:0] Funct3Q101H;
logic ValidInstQ101H;
logic [31:0] InstructionQ101H;



assign OpcodeQ101H       = t_opcode'(InstructionQ101H[6:0]);
assign Funct7Q101H       = InstructionQ101H[31:25];
assign Funct3Q101H       = InstructionQ101H[14:12];
assign CtrlQ101H.RegSrc1 = InstructionQ101H[19:15];
assign CtrlQ101H.RegSrc2 = InstructionQ101H[24:20];
assign CtrlQ101H.RegDst  = InstructionQ101H[11:7];

assign CtrlQ101H.e_SelWrBack      = (OpcodeQ101H == JAL) || (OpcodeQ101H == JALR) ? WB_PC4  :
                                    (OpcodeQ101H == LOAD)                         ? WB_DMEM :
                                                                                    WB_ALU  ;
assign CtrlQ101H.RegWrEn = (OpcodeQ101H == R_OP) || (OpcodeQ101H == I_OP) || (OpcodeQ101H == JALR) || (OpcodeQ101H == JAL) ||
                           (OpcodeQ101H == LOAD) || (OpcodeQ101H == AUIPC)|| (OpcodeQ101H == LUI); 

assign CtrlQ101H.ImmInstr = !(OpcodeQ101H == R_OP);

assign CtrlQ101H.DMemWrEn         = (OpcodeQ101H == STORE);
assign CtrlQ101H.DMemRdEn         = (OpcodeQ101H == LOAD);
assign CtrlQ101H.SignExt          = (OpcodeQ101H == LOAD) && (!Funct3Q101H[2]); // Sign extend the LOAD from memory read.
assign CtrlQ101H.DMemByteEn       = ((OpcodeQ101H == LOAD) || (OpcodeQ101H == STORE)) && (Funct3Q101H[1:0] == 2'b00) ? 4'b0001 : // LB || SB
                                    ((OpcodeQ101H == LOAD) || (OpcodeQ101H == STORE)) && (Funct3Q101H[1:0] == 2'b01) ? 4'b0011 : // LH || SH
                                    ((OpcodeQ101H == LOAD) || (OpcodeQ101H == STORE)) && (Funct3Q101H[1:0] == 2'b10) ? 4'b1111 : '0; // LW || SW - TODO - check the default value
assign CtrlQ101H.SelNextPcAluOutB = (OpcodeQ101H == BRANCH); // indicates BRANCH and may cause flashQ101H
assign CtrlQ101H.SelNextPcAluOutJ = (OpcodeQ101H == JAL) || (OpcodeQ101H == JALR); // when occures enable flashQ101H
assign CtrlQ101H.SelAluPc         = (OpcodeQ101H == JAL) || (OpcodeQ101H == BRANCH) || (OpcodeQ101H == AUIPC);  // effect on mux in alu stage to write pcQ101H + imm
assign CtrlQ101H.Lui              = (OpcodeQ101H == LUI);  


// flash unit
logic flashQ101H;
assign flashQ101H = (CtrlQ101H.SelNextPcAluOutB & BranchCondMetQ101H) || CtrlQ101H.SelNextPcAluOutJ;
assign InstructionQ101H = flashQ101H ? NOP : PreInstructionQ101H;

always_comb begin: alu_op
    case({Funct3Q101H, Funct7Q101H, OpcodeQ101H})
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
        default : CtrlQ101H.AluOp = ADD;
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

// Instruction fetch control 
assign CtrlIf.SelNextPcAluOutQ101H = BranchCondMetQ101H;

// Register file control
assign CtrlRf.RegSrc1Q101H = CtrlQ101H.RegSrc1;
assign CtrlRf.RegSrc2Q101H = CtrlQ101H.RegSrc2;
assign CtrlRf.RegDstQ102H  = CtrlQ102H.RegDst;
assign CtrlRf.RegWrEnQ102H = CtrlQ102H.RegWrEn;

// Alu control 
assign CtrlAlu.AluOpQ101H     = CtrlQ101H.AluOp;
assign CtrlAlu.ImmInstrQ101H  = CtrlQ101H.ImmInstr;
assign CtrlAlu.RegSrc1Q101H   = CtrlQ101H.RegSrc1;
assign CtrlAlu.RegSrc2Q101H   = CtrlQ101H.RegSrc2;
assign CtrlAlu.RegDstQ102H    = CtrlQ102H.RegDst;
assign CtrlAlu.RegWrEnQ102H   = CtrlQ102H.RegWrEn;
assign CtrlAlu.SelAluPcQ101H  = CtrlQ101H.SelAluPc;
assign CtrlAlu.LuiQ101H       = CtrlQ101H.Lui;

// Dmem control
assign CtrlDmem.DMemByteEnQ101H = CtrlQ101H.DMemByteEn;
assign CtrlDmem.DMemWrEnQ101H   = CtrlQ101H.DMemWrEn ;
assign CtrlDmem.DMemRdEnQ101H   = CtrlQ101H.DMemRdEn ;

// Write back control
assign CtrlWb.e_SelWrBackQ102H = CtrlQ102H.e_SelWrBack;
assign CtrlWb.ByteEnQ102H      = CtrlQ102H.DMemByteEn;
`MAFIA_DFF_RST(CtrlQ102H, CtrlQ101H, Clock, Rst)










endmodule