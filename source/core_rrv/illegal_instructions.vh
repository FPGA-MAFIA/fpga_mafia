//-----------------------------------------------------------------------------
// Title            : illegal_instructions
// Project          : fpga_mafia
//-----------------------------------------------------------------------------
// File             : illegal_instructions.sv
// Original Author  : 
// Code Owner       : Amichai Ben-David
// Adviser          : Amichai Ben-David
// Created          : 12/2023
// Description      : List of possible illigal instructions scenarios in RV32I
//-----------------------------------------------------------------------------

logic PreIllegalInstructionEn;

logic OpcodeNotMatchRV32I;
logic Funct3OrFunct7NotMatch;
t_opcode     PreOpcodeQ101H;

assign PreOpcodeQ101H                = t_opcode'(PreInstructionQ101H[6:0]);
always_comb begin
    Funct3OrFunct7NotMatch = 0;
    case (PreOpcodeQ101H)
        //funct7 do not match the instruction  
        R_OP: if (((CtrlQ101H.AluOp == ADD || CtrlQ101H.AluOp == SLL || CtrlQ101H.AluOp == SLT || CtrlQ101H.AluOp == SLTU || CtrlQ101H.AluOp == XOR || CtrlQ101H.AluOp == SRL || CtrlQ101H.AluOp == OR  || CtrlQ101H.AluOp == AND) && Funct7Q101H != 7'b0000000)
                 || ((CtrlQ101H.AluOp == SUB || CtrlQ101H.AluOp == SRA) && Funct7Q101H != 7'b0100000)) Funct3OrFunct7NotMatch = 1;
        //funct7 do not match for slli, srli, srai  
        I_OP: if ((Funct3Q101H == 3'b001 && Funct7Q101H != 7'b0000000) || (Funct3Q101H == 3'b101 && !(Funct7Q101H == 7'b0000000 || Funct7Q101H == 7'b0100000))) Funct3OrFunct7NotMatch = 1; 
        //undefined funct3 for store instructions         
        STORE: if (!(Funct3Q101H == 3'b000 || Funct3Q101H == 3'b001 || Funct3Q101H == 3'b010)) Funct3OrFunct7NotMatch = 1; 
        //undefined funct3 for load instructions 
        LOAD: if (Funct3Q101H == 3'b011 || Funct3Q101H == 3'b110 || Funct3Q101H == 3'b111) Funct3OrFunct7NotMatch = 1;
        //undefined funct3 for Branch instructions
        BRANCH: if (Funct3Q101H == 3'b010 || Funct3Q101H == 3'b011) Funct3OrFunct7NotMatch = 1;
        //undefined funct3 for JALR instructions
        JALR: if (Funct3Q101H != 3'b000)  Funct3OrFunct7NotMatch = 1; 
    endcase
end

always_comb begin
    OpcodeNotMatchRV32I = 0;
    if (!(OpcodeQ101H == R_OP || OpcodeQ101H == I_OP || OpcodeQ101H == STORE || OpcodeQ101H == LOAD || OpcodeQ101H == BRANCH || OpcodeQ101H == JALR
       || OpcodeQ101H == LUI || OpcodeQ101H == AUIPC || OpcodeQ101H == JAL || OpcodeQ101H == FENCE || OpcodeQ101H == SYSCAL))  OpcodeNotMatchRV32I = 1; 
end

assign  PreIllegalInstructionEn = Funct3OrFunct7NotMatch || OpcodeNotMatchRV32I;


