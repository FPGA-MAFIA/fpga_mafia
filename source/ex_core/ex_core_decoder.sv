`include "macros.vh"

module ex_core_decoder
import ex_core_pkg::*;
(
    input logic clk,
    input logic [31:0] instruction,
    output t_opcode opcode,
    output t_ctrl_alu CtrlAlu,
    output t_ctrl_rf CtrlRf,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic [31:0] imm
);

    // Extract fields from the instruction
    assign opcode = t_opcode'(instruction[6:0]); // Explicit cast to t_opcode
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];


    //check if need to create the immediate value according to the instruction type
    logic UseImmQ101H;
    assign UseImmQ101H = (opcode == I_OP);

    // Immediate value extraction (assuming RISC-V encoding for simplicity)
    always_comb begin
        case (opcode)
            7'b0010011: imm = {{20{instruction[31]}}, instruction[31:20]};  // I-type (ADDI, ANDI, ORI, etc.)
            7'b0000011: imm = {{20{instruction[31]}}, instruction[31:20]};  // I-type (LW)
            7'b0100011: imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};  // S-type (SW)
            7'b1100011: imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};  // B-type (BEQ, BNE)
            default:    imm = 32'b0;
        endcase
    end

always_comb begin
    unique casez ({funct3, funct7, opcode})
    // ---- R type ----
    {3'b000, 7'b0000000, R_OP} : CtrlAlu.AluOp = ADD;  // ADD
    {3'b000, 7'b0100000, R_OP} : CtrlAlu.AluOp = SUB;  // SUB
    {3'b001, 7'b0000000, R_OP} : CtrlAlu.AluOp = SLL;  // SLL
    {3'b010, 7'b0000000, R_OP} : CtrlAlu.AluOp = SLT;  // SLT
    {3'b011, 7'b0000000, R_OP} : CtrlAlu.AluOp = SLTU; // SLTU
    {3'b100, 7'b0000000, R_OP} : CtrlAlu.AluOp = XOR;  // XOR
    {3'b101, 7'b0000000, R_OP} : CtrlAlu.AluOp = SRL;  // SRL
    {3'b101, 7'b0100000, R_OP} : CtrlAlu.AluOp = SRA;  // SRA
    {3'b110, 7'b0000000, R_OP} : CtrlAlu.AluOp = OR;   // OR
    {3'b111, 7'b0000000, R_OP} : CtrlAlu.AluOp = AND;  // AND
    // ---- I type ----
    {3'b000, 7'b???????, I_OP} : CtrlAlu.AluOp = ADD;  // ADDI
    {3'b010, 7'b???????, I_OP} : CtrlAlu.AluOp = SLT;  // SLTI
    {3'b011, 7'b???????, I_OP} : CtrlAlu.AluOp = SLTU; // SLTUI
    {3'b100, 7'b???????, I_OP} : CtrlAlu.AluOp = XOR;  // XORI
    {3'b110, 7'b???????, I_OP} : CtrlAlu.AluOp = OR;   // ORI
    {3'b111, 7'b???????, I_OP} : CtrlAlu.AluOp = AND;  // ANDI
    {3'b001, 7'b0000000, I_OP} : CtrlAlu.AluOp = SLL;  // SLLI
    {3'b101, 7'b0000000, I_OP} : CtrlAlu.AluOp = SRL;  // SRLI
    {3'b101, 7'b0100000, I_OP} : CtrlAlu.AluOp = SRA;  // SRAI
    // ---- Other ----
    default                    : CtrlAlu.AluOp = ADD;  // LUI || AUIPC || JAL || JALR || BRANCH || LOAD || STORE
    endcase
end

    // Decode the instruction for RF control signals
    assign CtrlRf.RegDst  = instruction[11:7];
    assign CtrlRf.RegWrEn = (opcode==I_OP || opcode==R_OP || opcode==LUI || opcode==AUIPC || opcode==JALR) ? 1 : 0;
    assign CtrlRf.RegSrc1 = instruction[19:15];
    assign CtrlRf.RegSrc2 = instruction[24:20];

endmodule
