

`include "macros.vh"

module ref_core
import common_pkg::*;
import big_core_pkg::*;
(
    input logic Clk,
    input logic Rst
);

logic [31:0] Instruction;
logic [31:0] DMemAddress;
logic [31:0] DMemData   ;
logic [3:0]  DMemByteEn ;
logic        DMemWrEn   ;
logic        DMemRdEn   ;
logic [31:0] DMemRspData;
logic  [7:0] IMem     [I_MEM_MSB : 0];
logic  [7:0] NextIMem [I_MEM_MSB : 0];
logic  [7:0] DMem     [D_MEM_SIZE + D_MEM_OFFSET - 1 : D_MEM_OFFSET];
logic  [7:0] NextDMem [D_MEM_SIZE + D_MEM_OFFSET - 1 : D_MEM_OFFSET];
logic [31:0] Pc;

//=========================================
// Instantiating the sc_core core
//=========================================

 sc_core sc_core (
    .Clk            (Clk),                      
    .Rst            (Rst),                      
    .Pc             (Pc),         // To I_MEM   
    .Instruction    (Instruction),// From I_MEM 
    .DMemData       (DMemData),   // To D_MEM   
    .DMemAddress    (DMemAddress),// To D_MEM   
    .DMemByteEn     (DMemByteEn), // To D_MEM   
    .DMemWrEn       (DMemWrEn),   // To D_MEM   
    .DMemRdEn       (DMemRdEn),   // To D_MEM   
    .DMemRspData    (DMemRspData) // From D_MEM 
);
//======================
//  instruction memory
//======================
assign Instruction[7:0]   = IMem[Pc+0];
assign Instruction[15:8]  = IMem[Pc+1];
assign Instruction[23:16] = IMem[Pc+2];
assign Instruction[31:24] = IMem[Pc+3];
//======================
//  Data memory Write
//======================
always_comb begin
    NextDMem = DMem;
    if(DMemWrEn) begin
        if(DMemByteEn[0]) NextDMem[DMemAddress+0] = DMemData[7:0];  
        if(DMemByteEn[1]) NextDMem[DMemAddress+1] = DMemData[15:8];
        if(DMemByteEn[2]) NextDMem[DMemAddress+2] = DMemData[23:16];
        if(DMemByteEn[3]) NextDMem[DMemAddress+3] = DMemData[31:24];
    end //if DMemWrEn
end //always_comb

//======================
//  Data memory Read
//======================
assign DMemRspData[7:0]   = DMem[DMemAddress+0];
assign DMemRspData[15:8]  = DMem[DMemAddress+1];
assign DMemRspData[23:16] = DMem[DMemAddress+2];
assign DMemRspData[31:24] = DMem[DMemAddress+3];

`MAFIA_DFF(IMem, NextIMem, Clk)
`MAFIA_DFF(DMem, NextDMem, Clk)


endmodule