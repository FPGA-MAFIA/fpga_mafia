
//------------------------------------------------------------------------------
// Title            : illegal_instructions
// Project          : fpga_mafia
//------------------------------------------------------------------------------
// File             : illegal_instructions.sv
// Original Author  : 
// Code Owner       : Amichai Ben-David
// Adviser          : Amichai Ben-David
// Created          : 12/2023
// Description      : List of possible illigal instructions scenarios in RV32I/E
//------------------------------------------------------------------------------
t_illegal_instruction illegal_instructionsQ101H;

t_opcode            PreOpcodeQ101H;
t_core_rrv_ctrl     PreCtrlQ101H;
t_funct3_store_type PreStoreTypeQ101H;
t_funct3_load_type  PreLoadTypeQ101H;
t_branch_type       PreBranchTypeQ101H;
t_funct3_Rtype      PreRtypeQ101H;
logic [2:0]         JalrFunct3Q101H;
logic [6:0]         PreFunct7Q101H;  
logic               PreIllegalInstructionQ101H;


assign PreOpcodeQ101H     = t_opcode'(PreInstructionQ101H[6:0]);
assign PreStoreTypeQ101H  = t_funct3_store_type'(PreInstructionQ101H[14:12]);
assign PreLoadTypeQ101H   = t_funct3_load_type'(PreInstructionQ101H[14:12]); 
assign PreBranchTypeQ101H = t_branch_type'(PreInstructionQ101H[14:12]);
assign PreRtypeQ101H      = t_funct3_Rtype'(PreInstructionQ101H[14:12]); 
assign JalrFunct3Q101H    = PreInstructionQ101H[14:12];        
assign PreFunct7Q101H     = PreInstructionQ101H[31:25];


// Covers R_type instructions where bits [31:25] must always be zero in Base ISA //TODO - some extentions may have differente options 
assign illegal_instructionsQ101H.RopFunct7NotMatchZero = (PreOpcodeQ101H == R_OP) && 
                                                                                (  PreRtypeQ101H  == SLL_ 
                                                                                || PreRtypeQ101H  == SLT_  
                                                                                || PreRtypeQ101H  == SLTU_   
                                                                                || PreRtypeQ101H  == XOR_  
                                                                                || PreRtypeQ101H  == OR_   
                                                                                || PreRtypeQ101H  == AND_) && (PreFunct7Q101H != '0);       
                                                                                                                 
// Covers R_type instructions where bits [31:25] must always be 7'b0100000 = 0x20 or zero in Base ISA //TODO - some extentions may have differente options 
assign illegal_instructionsQ101H.RopFunct7NotMatch20OrZero = (PreOpcodeQ101H == R_OP) && (PreRtypeQ101H == ADD_ || PreRtypeQ101H  == SRL_) && !(PreFunct7Q101H == 8'h20 || PreFunct7Q101H == '0);

// Covers I_type instructions where bits [31:25] must always be 7'b0100000 = 0x20 or zero in Base ISA //TODO - some extentions may have differente options 
assign illegal_instructionsQ101H.IopFunct7NotMatch20OrZero = (PreOpcodeQ101H == I_OP) && (PreRtypeQ101H == SLL_ || PreRtypeQ101H  == SRL_) && !(PreFunct7Q101H == 8'h20 || PreFunct7Q101H == '0);

// Covers Store type with illegal [14:12] bits
assign illegal_instructionsQ101H.StoreFunct3NotMatch  = (PreOpcodeQ101H == STORE) && (!(PreStoreTypeQ101H == SB_ || PreStoreTypeQ101H == SH_ || PreStoreTypeQ101H == SW_));

// Covers Load type with illegal [14:12] bits
assign illegal_instructionsQ101H.LoadFunct3NotMatch   = (PreOpcodeQ101H == LOAD)  && (!(PreLoadTypeQ101H == LB_ || PreLoadTypeQ101H == LH_ 
                                                   || PreLoadTypeQ101H == LW_ || PreLoadTypeQ101H == LBU_ || PreLoadTypeQ101H == LBH_)); 

// Covers Branch type with illegal [14:12] bits
assign illegal_instructionsQ101H.BranchFunct3NotMatch = (PreOpcodeQ101H == BRANCH)  && !(PreBranchTypeQ101H == BEQ || PreBranchTypeQ101H == BNE || PreBranchTypeQ101H == BLT 
                                                    || PreBranchTypeQ101H == BLTU || PreBranchTypeQ101H == BGE || PreBranchTypeQ101H == BLT || PreBranchTypeQ101H == BGEU); 

// Covers LALR type with illegal [14:12] bits
assign illegal_instructionsQ101H.JalrFunct3NotMatch    = (PreOpcodeQ101H == JALR && JalrFunct3Q101H != 3'b000);  

// Cover undefined [6:0] bits in Base ISA
assign illegal_instructionsQ101H.OpCodeNotMatchBaseISA = !(PreOpcodeQ101H == R_OP || PreOpcodeQ101H == I_OP || PreOpcodeQ101H == STORE || PreOpcodeQ101H == LOAD || PreOpcodeQ101H
                                                    || PreOpcodeQ101H == JALR  || PreOpcodeQ101H == LUI ||PreOpcodeQ101H == AUIPC || PreOpcodeQ101H == JAL 
                                                    || PreOpcodeQ101H == FENCE || PreOpcodeQ101H == SYSCAL);


assign illegal_instructionsQ101H.RegOutOfRangeRV32E = 0; // TODO - must be asserterd if RF num greater that 15 and we work at RV32E configuration

assign PreIllegalInstructionQ101H = (illegal_instructionsQ101H.RopFunct7NotMatchZero || illegal_instructionsQ101H.RopFunct7NotMatch20OrZero || illegal_instructionsQ101H.IopFunct7NotMatch20OrZero
                                  || illegal_instructionsQ101H.StoreFunct3NotMatch   || illegal_instructionsQ101H.LoadFunct3NotMatch        || illegal_instructionsQ101H.BranchFunct3NotMatch 
                                  || illegal_instructionsQ101H.JalrFunct3NotMatch    || illegal_instructionsQ101H. OpCodeNotMatchBaseISA);