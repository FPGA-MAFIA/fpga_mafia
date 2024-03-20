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
    output var t_ctrl_wb  CtrlWb

);


var t_opcode OpcodeQ101H;
var t_mini_core_rrv_ctrl CtrlQ101H, CtrlQ102H;
logic        [6:0] Funct7Q101H;
logic        [2:0] Funct3Q101H;
logic ValidInstQ101H;



assign OpcodeQ101H       = t_opcode'(PreInstructionQ101H[6:0]);
assign Funct7Q101H       = PreInstructionQ101H[31:25];
assign Funct3Q101H       = PreInstructionQ101H[14:12];
assign CtrlQ101H.RegSrc1 = PreInstructionQ101H[19:15];
assign CtrlQ101H.RegSrc2 = PreInstructionQ101H[24:20];
assign CtrlQ101H.RegDst  = PreInstructionQ101H[11:7];

assign CtrlQ101H.RegWrEn = (OpcodeQ101H == R_OP) || (OpcodeQ101H == I_OP); 



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

always_comb begin: imm_generator
    case(OpcodeQ101H)
        I_OP:    CtrlQ101H.ImmediateQ101H = {PreInstructionQ101H[31:12], 12'b0 } ;
        default: CtrlQ101H.ImmediateQ101H = {PreInstructionQ101H[31:12], 12'b0 } ;   
    endcase
    end

// Instruction fetch control 
assign CtrlIf.SelNextPcAluOutQ101H = BranchCondMetQ101H;

// Register file control
assign CtrlRf.RegSrc1Q101H = CtrlQ101H.RegSrc1;
assign CtrlRf.RegSrc2Q101H = CtrlQ101H.RegSrc1;
assign CtrlRf.RegDstQ102H  = CtrlQ102H.RegDst;
assign CtrlRf.RegWrEnQ102H = CtrlQ102H.RegWrEn;

// Alu control
assign CtrlAlu.AluOpQ101H  = CtrlQ101H.AluOp;
assign CtrlAlu.AluIn1Q101H = CtrlQ101H.RegSrc1;
assign CtrlAlu.AluIn2Q101H = (OpcodeQ101H == I_OP) ? CtrlQ101H.ImmediateQ101H : CtrlQ101H.RegSrc2;

// Write back control

`MAFIA_DFF_RST(CtrlQ102H, CtrlQ101H, Clock, Rst)










endmodule