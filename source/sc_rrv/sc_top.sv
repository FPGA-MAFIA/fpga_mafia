//-----------------------------------------------------------------------------
// Title            : single cycle top design
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


module sc_top
import sc_core_pkg::*;(
   input logic    Clk,
   input logic    Rst,
   output logic   SimulationDone
);
    
   // Interface with Instruction memory 
   logic [$clog2(I_MEM_SIZE)-1:0] Pc;
   logic [31:0]                   Instruction;
   
   //Interface with Data Memory
    logic [31:0]  DMemAddress; 
    logic [31:0]  DMemData;  
    logic [3:0]   DMemByteEn;  
    logic         DMemWrEn;  
    logic         DMemRdEn;  
    logic [31:0]  DMemRspData;
    
    sc_core sc_core(
        .Clk(Clk),
        .Rst(Rst),
        .SimulationDone(SimulationDone),
        //I_Mem interface 
        .Pc(Pc),
        .Instruction(Instruction),
        //D_Mem interface 
        .DMemAddress(DMemAddress),
        .DMemData(DMemData),
        .DMemByteEn(DMemByteEn),
        .DMemWrEn(DMemWrEn),
        .DMemRdEn(DMemRdEn),
        .DMemRspData(DMemRspData)
    );

    i_mem i_mem(
    .Pc(Pc),
    .Instruction(Instruction) 
    );

  
    d_mem d_Mem(
    .Clk(Clk), 
    .DMemAddress(DMemAddress), 
    .DMemData(DMemData),  
    .DMemByteEn(DMemByteEn),  
    .DMemWrEn(DMemWrEn),  
    .DMemRdEn(DMemRdEn),
    .DMemRspData(DMemRspData)
    );
    
endmodule