//-----------------------------------------------------------------------------
// Title            : big_core tb
// Project          : 7 stages core
//-----------------------------------------------------------------------------
// File             : big_core_tb.sv
// Original Author  : Daniel Kaufman
// Code Owner       : 
// Created          : 11/2022
//-----------------------------------------------------------------------------
// Description :
// simple test bench
// (1) generate the clock & rst. 
// (2) load backdoor the I_MEM & D_MEM.
// (3) End the test when the ebrake command is executed
//-----------------------------------------------------------------------------
`define NO_WARNING_ON_FILE_NOT_FOUND

`include "macros.sv"

module sc_core_tb ;
import sc_core_pkg::*;

logic        Clk;
logic        Rst;
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

// FPGA interface inputs              
logic        Button_0;
logic        Button_1;
logic [9:0]  Switch;

// FPGA interface outputs
logic [7:0]  SEG7_0;
logic [7:0]  SEG7_1;
logic [7:0]  SEG7_2;
logic [7:0]  SEG7_3;
logic [7:0]  SEG7_4;
logic [7:0]  SEG7_5;
logic [9:0]  LED;

//=========================================
//     VGA - Core interface
//=========================================
// VGA output
logic [3:0]  RED;
logic [3:0]  GREEN;
logic [3:0]  BLUE;
logic        h_sync;
logic        v_sync;
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


`RVC_DFF(IMem, NextIMem, Clk)
`RVC_DFF(DMem, NextDMem, Clk)

string test_name;
integer file;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    //======================================
    //load the program to the TB
    //======================================
    $readmemh({"../../target/sc_core/tests/",test_name,"/gcc_files/inst_mem.sv"} , IMem);
    $readmemh({"../../target/sc_core/tests/",test_name,"/gcc_files/inst_mem.sv"} , NextIMem);

    file = $fopen({"../../target/sc_core/tests/",test_name,"/gcc_files/data_mem.sv"}, "r");
    if (file) begin
        $fclose(file);
        $readmemh({"../../target/sc_core/tests/",test_name,"/gcc_files/data_mem.sv"} , DMem);
        $readmemh({"../../target/sc_core/tests/",test_name,"/gcc_files/data_mem.sv"} , NextDMem);
    end
    #100000
    $display("===================\n test %s ended timeout \n=====================", test_name);
    $finish;

end // test_seq


`include "sc_core_trk.vh"

parameter EBREAK = 32'h00100073;

// EBREAK detection
always @(posedge Clk) begin : ebrake_status
    if (EBREAK == sc_core.Instruction) begin // ebrake instruction opcode
        $display("===================\n test %s ended with EBREAK \n=====================", test_name);
        $finish;
        //end_tb("The test ended");
    end
end


endmodule //big_core_tb

