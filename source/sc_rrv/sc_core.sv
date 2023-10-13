//-----------------------------------------------------------------------------
// Title            : single cycle core design
// Project          : single cycle core
//-----------------------------------------------------------------------------
// File             : sc_core
// Original Author  : Roman Gilgor
// Code Owner       : 
// Created          : 10/2023
//-----------------------------------------------------------------------------
// Description :
// This is the top level of the single cycle core design.
// The core is a 32 bit RISC-V core.
// compatible with the RV32I base instruction set.
// Fetch, Decode, Execute, Memory, WriteBack all in one cycle.
// The PC (program counter) is the synchronous element in the core 
//-----------------------------------------------------------------------------

`include "macros.sv"

module sc_core
import sc_core_pkg::*; (
    input logic  Clk,
    input logic  Rst,
    output logic SimulationDone,
   //Interface with Instruction memory
   output logic [$clog2(I_MEM_SIZE)-1:0] Pc, 
   input logic  [31:0]                   Instruction,
   //Interface with Data Memory
    output logic [31:0]                   DMemAddress, 
    output logic [31:0]                   DMemData   ,  
    output logic [3:0]                    DMemByteEn ,  
    output logic                          DMemWrEn   ,  
    output logic                          DMemRdEn   ,
    input  logic [31:0]                   DMemRspData
);


//signal declarations
//Data-Path signals
logic [$clog2(I_MEM_SIZE)-1:0] NextPc;
logic [31:0]                   PcPlus4;
logic [31:0]                   AluOut;
logic                          BranchCondMet;
logic [31:0]                   Immediate;
logic [31:0]                   RegWrData; 
logic [31:1][31:0]             Register;    // x0 is not included
logic [31:0]                   RegRdData1; 
logic [31:0]                   RegRdData2;
logic [31:0]                   AluIn1; 
logic [31:0]                   AluIn2; 
logic [4:0]                    Shamt;
logic [31:0]                   WrBackData;


    
//Ctrl Unit signals
logic         SelNextPcAluOut; 
logic [2:0]   Funct3;
logic [6:0]   Funct7;
logic         SelRegWrPc;  
logic         SelAluImm;
logic         SelAluPc;
logic         SelDMemWb;
logic         CtrlRegWrEn;
logic         CtrlDMemWrEn;
logic         CtrlSignExt;
logic [3:0]   CtrlDMemByteEn;
logic [4:0]   RegSrc1;
logic [4:0]   RegSrc2;
logic [4:0]   RegDst;
t_branch_type CtrlBranchOp;
t_opcode      Opcode;
t_alu_op      CtrlAluOp; 
t_immediate   SelImmType;

    
//===========================================================================
// Instruction fetch
// 1. Send the PC (Program Counter) to the I_MEM.
// 2. Set the Next Pc -> Pc+4 or Calculated Address.
//===========================================================================
assign PcPlus4  = Pc + 16'd4;
assign NextPc = SelNextPcAluOut ? AluOut : PcPlus4; 
`MAFIA_RST_DFF(Pc, NextPc, Clk, Rst);


//===========================================================================
// Decode
// 1. Get the instruction from I_MEM and use the "decoder" to set the Ctrl Bits.
// 2. Construct the Immediate types.
// 3. Use the RS1 & RS2 (RegSrc) to read the Register file data.
//===========================================================================
assign Opcode = t_opcode'(Instruction[6:0]);
assign Funct3 = Instruction[14:12];
assign Funct7 = Instruction[31:25];

assign SelNextPcAluOut = (Opcode == JAL) || (Opcode == JALR) || ((Opcode == BRANCH) & (BranchCondMet));
assign SelRegWrPc      = (Opcode == JAL) || (Opcode == JALR);
assign SelAluImm       = !(Opcode == R_OP);
assign SelAluPc        = (Opcode == JAL) || (Opcode == BRANCH) || (Opcode == AUIPC);
assign SelDMemWb       = (Opcode == LOAD);
assign CtrlRegWrEn     = (Opcode == LUI ) || (Opcode == AUIPC) || (Opcode == JAL)  || (Opcode == JALR) ||
                         (Opcode == LOAD) || (Opcode == I_OP)  || (Opcode == R_OP) || (Opcode == FENCE);
assign CtrlDMemWrEn    = (Opcode == STORE);
assign CtrlSignExt     = (Opcode == LOAD) & (!Funct3[2]);                     
assign CtrlDMemByteEn  = ((Opcode == LOAD) || (Opcode == STORE)) && (Funct3[1:0] == 2'b00) ? 4'b0001 :// LB || SB
                         ((Opcode == LOAD) || (Opcode == STORE)) && (Funct3[1:0] == 2'b01) ? 4'b0011 :// LH || SH
                         ((Opcode == LOAD) || (Opcode == STORE)) && (Funct3[1:0] == 2'b10) ? 4'b1111 :// LW || SW
                                                                                            4'b0000 ;                      
assign CtrlBranchOp    = t_branch_type'(Funct3);  
assign SimulationDone  = (Opcode == SYSCAL);
                    


always_comb begin
    unique casez ({Funct3, Funct7, Opcode})
    //-----LUI type-------
    {3'b???, 7'b???????, LUI } : CtrlAluOp = IN_2;//LUI
    //-----R type-------
    {3'b000, 7'b0000000, R_OP} : CtrlAluOp = ADD; //ADD
    {3'b000, 7'b0100000, R_OP} : CtrlAluOp = SUB; //SUB
    {3'b001, 7'b0000000, R_OP} : CtrlAluOp = SLL; //SLL
    {3'b010, 7'b0000000, R_OP} : CtrlAluOp = SLT; //SLT
    {3'b011, 7'b0000000, R_OP} : CtrlAluOp = SLTU;//SLTU
    {3'b100, 7'b0000000, R_OP} : CtrlAluOp = XOR; //XOR
    {3'b101, 7'b0000000, R_OP} : CtrlAluOp = SRL; //SRL
    {3'b101, 7'b0100000, R_OP} : CtrlAluOp = SRA; //SRA
    {3'b110, 7'b0000000, R_OP} : CtrlAluOp = OR;  //OR
    {3'b111, 7'b0000000, R_OP} : CtrlAluOp = AND; //AND
    //-----I type-------
    {3'b000, 7'b???????, I_OP} : CtrlAluOp = ADD; //ADDI
    {3'b010, 7'b???????, I_OP} : CtrlAluOp = SLT; //SLTI
    {3'b011, 7'b???????, I_OP} : CtrlAluOp = SLTU;//SLTUI
    {3'b100, 7'b???????, I_OP} : CtrlAluOp = XOR; //XORI
    {3'b110, 7'b???????, I_OP} : CtrlAluOp = OR;  //ORI
    {3'b111, 7'b???????, I_OP} : CtrlAluOp = AND; //ANDI
    {3'b001, 7'b0000000, I_OP} : CtrlAluOp = SLL; //SLLI
    {3'b101, 7'b0000000, I_OP} : CtrlAluOp = SRL; //SRLI
    {3'b101, 7'b0100000, I_OP} : CtrlAluOp = SRA; //SRAI
    //-----Other-------
    default                    : CtrlAluOp = ADD; //AUIPC || JAL || JALR || BRANCH || LOAD || STORE
    endcase
end

//  Immediate Generator
always_comb begin
    unique casez (Opcode)    //mux
    JALR, I_OP, LOAD : SelImmType = I_TYPE;
    LUI, AUIPC       : SelImmType = U_TYPE;
    JAL              : SelImmType = J_TYPE;
    BRANCH           : SelImmType = B_TYPE;
    STORE            : SelImmType = S_TYPE;
    default          : SelImmType = I_TYPE;
  endcase
  unique casez (SelImmType)    //mux
    U_TYPE : Immediate = {     Instruction[31:12], 12'b0 } ;                                                            //U_Immediate;
    I_TYPE : Immediate = { {20{Instruction[31]}} , Instruction[31:20] };                                                //I_Immediate;
    S_TYPE : Immediate = { {20{Instruction[31]}} , Instruction[31:25] , Instruction[11:7]  };                           //S_Immediate;
    B_TYPE : Immediate = { {20{Instruction[31]}} , Instruction[7]     , Instruction[30:25] , Instruction[11:8]  , 1'b0};//B_Immediate;
    J_TYPE : Immediate = { {12{Instruction[31]}} , Instruction[19:12] , Instruction[20]    , Instruction[30:21] , 1'b0};//J_Immediate;
    default: Immediate = {     Instruction[31:12], 12'b0 };                                                             //U_Immediate;
  endcase
end                      
 
//===================
//  Register File
//===================
assign RegDst  = Instruction[11:7];
assign RegSrc1 = Instruction[19:15];
assign RegSrc2 = Instruction[24:20];
// --- Select what Write to register file --------
assign RegWrData = SelRegWrPc ? PcPlus4 : WrBackData; 
//---- The Register File  ------
`MAFIA_EN_DFF(Register[RegDst] , RegWrData , Clk , (CtrlRegWrEn && (RegDst!=5'b0)))
// --- read Register File --------
assign RegRdData1 = (RegSrc1==5'b0) ? 32'b0 : Register[RegSrc1];
assign RegRdData2 = (RegSrc2==5'b0) ? 32'b0 : Register[RegSrc2];
    
//===========================================================================
// Execute
// 1. Compute Data to write back to register.
// 2. Compute Address for load/store
// 3. Compute Branch/Jump address target. (set PC)
// 4. Check branch condition
//===========================================================================
assign AluIn1 = SelAluPc    ? Pc        : RegRdData1;
assign AluIn2 = SelAluImm   ? Immediate : RegRdData2;    

always_comb begin : alu_logic
    Shamt = AluIn2[4:0]; 
    //According to ALU OP we select the correct operation
    unique casez (CtrlAluOp)
        ADD      :   AluOut = AluIn1 + AluIn2                  ;
        SUB      :   AluOut = AluIn1 + (~AluIn2) + 1'b1        ;
        //shift
        SLL     : AluOut = AluIn1 << Shamt                     ;//SLL
        SRL     : AluOut = AluIn1 >> Shamt                     ;//SRL
        SRA     : AluOut = $signed(AluIn1) >>> Shamt           ;//SRA
        //bit wise operations
        XOR     : AluOut = AluIn1 ^ AluIn2                     ;//XOR
        OR      : AluOut = AluIn1 | AluIn2                     ;//OR
        AND     : AluOut = AluIn1 & AluIn2                     ;//AND
        IN_2    : AluOut = AluIn2                              ;//LUI
        SLT     : AluOut = $signed(AluIn1) < $signed(AluIn2)   ;//SLT
        SLTU    : AluOut = AluIn1 < AluIn2                     ;//SLTU
        default : AluOut = AluIn1 + AluIn2                     ;
  endcase
end   

always_comb begin : branch_comp
  //for branch condition.
   unique casez (CtrlBranchOp)
    BEQ     : BranchCondMet =  (RegRdData1==RegRdData2)                   ;// BEQ
    BNE     : BranchCondMet = ~(RegRdData1==RegRdData2)                   ;// BNE
    BLT     : BranchCondMet =  ($signed(RegRdData1)<$signed(RegRdData2))  ;// BLT
    BGE     : BranchCondMet = ~($signed(RegRdData1)<$signed(RegRdData2))  ;// BGE
    BLTU    : BranchCondMet =  (RegRdData1<RegRdData2)                    ;// BLTU
    BGEU    : BranchCondMet = ~(RegRdData1<RegRdData2)                    ;// BGEU
    default : BranchCondMet = 1'b0                                        ;
  endcase
end           

//===========================================================================
// Memory Access
// Access D_MEM for Write (STORE) and Reads (LOAD). - use Byte Enable and Sign-Extend indications.
//===========================================================================
// Both RD & WR
assign DMemAddress  = AluOut;
assign DMemByteEn   = CtrlDMemByteEn;
//WR
assign DMemData     = RegRdData2;
assign DMemWrEn     = CtrlDMemWrEn;
//RD
assign DMemRdEn     = SelDMemWb;

//===========================================================================
// Write-Back
//===========================================================================
// -----------------
// 1. Select which data should be written back to the register file AluOut or DMemRdData.
// Sign extend taking care of
logic [31:0] DMemRspDataBeSx;
assign DMemRspDataBeSx[7:0]   =  CtrlDMemByteEn[0] ? DMemRspData[7:0]     : 8'b0;
assign DMemRspDataBeSx[15:8]  =  CtrlDMemByteEn[1] ? DMemRspData[15:8]    :
                                 CtrlSignExt       ? {8{WrBackData[7]}} : 8'b0;
assign DMemRspDataBeSx[23:16] =  CtrlDMemByteEn[2] ? DMemRspData[23:16]:
                                 CtrlSignExt       ? {8{WrBackData[15]}}: 8'b0;
assign DMemRspDataBeSx[31:24] =  CtrlDMemByteEn[3] ? DMemRspData[31:24]:
                                 CtrlSignExt       ? {8{WrBackData[23]}}: 8'b0;
//
assign WrBackData = SelDMemWb ? DMemRspDataBeSx : AluOut;

endmodule
