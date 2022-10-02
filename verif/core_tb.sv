//-----------------------------------------------------------------------------
// Title            : core tb
// Project          : simple_core
//-----------------------------------------------------------------------------
// File             : core_tb.sv
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Created          : 10/2022
//-----------------------------------------------------------------------------
// Description :
// simple test bench
// (1) generate the clock & rst. 
// (2) load backdoor the I_MEM & D_MEM.
// (3) End the test when the ebrake command is executed
//-----------------------------------------------------------------------------


`include "macros.sv"

module core_tb () ;
import core_pkg::*;

logic        Clk;
logic        Rst;
logic [31:0] Pc;
logic [31:0] Instruction;
logic [31:0] DMemAddress;
logic [31:0] DMemData   ;
logic [3:0]  DMemByteEn ;
logic        DMemWrEn   ;
logic        DMemRdEn   ;
logic [31:0] DMemRspData;
logic  [7:0] IMem     [I_MEM_SIZE + I_MEM_OFFSET - 1 : I_MEM_OFFSET];
logic  [7:0] DMem     [D_MEM_SIZE + D_MEM_OFFSET - 1 : D_MEM_OFFSET];
logic  [7:0] NextDMem [D_MEM_SIZE + D_MEM_OFFSET - 1 : D_MEM_OFFSET];



// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 Clk = 1'b0;
        #5 Clk = 1'b1;
    end //forever
end//initial clock_gen

// ========================
// reset generation
// ========================
initial begin: reset_gen
    Rst = 1'b1;
#40 Rst = 1'b0;
end: reset_gen


`RVC_DFF(IMem, IMem    , Clk)
`RVC_DFF(DMem, NextDMem, Clk)

initial begin: test_seq
    //======================================
    //load the program to the TB
    //======================================
    $readmemh({"../app/inst_mem.sv"}, IMem);
    //$readmemh({"../app/data_mem.sv"}, DMem);
    #10000 $finish;
end // test_seq


integer trk_alu;
initial begin: trk_gen
    $timeformat(-9, 1, " ", 6);
    trk_alu = $fopen({"../target/trk_alu.log"},"w");
    $fwrite(trk_alu,"---------------------------------------------------------\n");
    $fwrite(trk_alu,"Time\t|\tPC \t | AluIn1\t| AluIn2\t| AluOut\t|\n");
    $fwrite(trk_alu,"---------------------------------------------------------\n");  

end
//tracker on ALU operations
always @(posedge Clk) begin : alu_print
    $fwrite(trk_alu,"%t\t| %8h |%8h \t|%8h \t|%8h \t| \n", $realtime,Pc, core.AluIn1 , core.AluIn2, core.AluOut);
end

// DUT instance core 
core core (
    .Clk        ( Clk )          ,//input logic Clk,
    .Rst        ( Rst )          ,//input logic Rst,
    // interafce with instruciton memory
    .Pc         ( Pc )           ,//output logic [31:0] Pc,
    .Instruction( Instruction )  ,//output logic [31:0] Instruction,
    //interface with Data Memory
    .DMemAddress( DMemAddress )  ,//output logic [31:0] DMemAddress,
    .DMemData   ( DMemData    )  ,//output logic [31:0] DMemData   ,
    .DMemByteEn ( DMemByteEn  )  ,//output logic [3:0]  DMemByteEn ,
    .DMemWrEn   ( DMemWrEn    )  ,//output logic        DMemWrEn   ,
    .DMemRdEn   ( DMemRdEn    )  ,//output logic        DMemRdEn   ,
    .DMemRspData( DMemRspData )   //input  logic [31:0] DMemRspData
);




assign Instruction = {IMem[Pc + 3] ,
                      IMem[Pc + 2] ,
                      IMem[Pc + 1] ,
                      IMem[Pc + 0]};


//==============================
// Behavrual Memory
//------------------------------
// Write access
//------------------------------
always_comb begin
    NextDMem = DMem;
    if(DMemWrEn) begin
        if(DMemByteEn[0]) NextDMem[DMemAddress+0] = DMemData[7:0]  ;
        if(DMemByteEn[1]) NextDMem[DMemAddress+1] = DMemData[15:8] ;
        if(DMemByteEn[2]) NextDMem[DMemAddress+2] = DMemData[23:16];
        if(DMemByteEn[3]) NextDMem[DMemAddress+3] = DMemData[31:24];
    end
end
//------------------------------
// Read access
//------------------------------
assign DMemRspData = {DMem[DMemAddress+3] ,
                      DMem[DMemAddress+2] ,
                      DMem[DMemAddress+1] ,
                      DMem[DMemAddress+0]};


endmodule //core_tb

