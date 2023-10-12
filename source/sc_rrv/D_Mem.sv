//-----------------------------------------------------------------------------
// Title            : D_Mem cycle core design
// Project          : single cycle core
//-----------------------------------------------------------------------------
// File             : D_Mem
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


module D_Mem
import sc_core_pkg::*;
(
    input  logic Clk, 
    input  logic [$clog2(D_MEM_SIZE)-1:0] DMemAddress, 
    input  logic [31:0]                   DMemData   ,  
    input  logic [3:0]                    DMemByteEn ,  
    input  logic                          DMemWrEn   ,  
    input  logic                          DMemRdEn   ,
    output logic [31:0]                   DMemRspData
);


    //logic [7:0] DMem [D_MEM_SIZE-1:D_MEM_OFFSET];
    logic [7:0] DMem [D_MEM_SIZE+D_MEM_OFFSET-1:D_MEM_OFFSET]; 

    always_ff @(posedge Clk) begin
        if(DMemWrEn) begin
            if (DMemByteEn == 4'b0001)
                 DMem[DMemAddress] <= DMemData[7:0];
            else if (DMemByteEn == 4'b0011) begin
                DMem[DMemAddress]   <= DMemData[7:0];
                DMem[DMemAddress+1] <= DMemData[15:8];
            end
            else if (DMemByteEn == 4'b1111) begin
                DMem[DMemAddress]   <= DMemData[7:0];
                DMem[DMemAddress+1] <= DMemData[15:8];
                DMem[DMemAddress+2] <= DMemData[23:16];
                DMem[DMemAddress+3] <= DMemData[31:24];
            end
         end   
    end
    
    assign DMemRspData = (DMemRdEn) ? {DMem[DMemAddress+3], DMem[DMemAddress+2], DMem[DMemAddress+1], DMem[DMemAddress]} : 0;  
    
endmodule
