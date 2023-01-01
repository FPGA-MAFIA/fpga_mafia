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


module mini_core_tb  ;
//import core_pkg::*;
import mini_core_pkg::*;


logic        Clk;
logic        Rst;
logic [31:0] PcQ100H;
logic [31:0] Instruction;
logic [31:0] DMemAddress;
logic [31:0] DMemData   ;
logic [3:0]  DMemByteEn ;
logic        DMemWrEn   ;
logic        DMemRdEn   ;
logic [31:0] DMemRdRspData;
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

string test_name;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    //======================================
    //load the program to the TB
    //======================================
    $readmemh({"../../target/mini_core/gcc_gen_files/",test_name,"/inst_mem.sv"} , IMem);
    force mini_top.mini_mem_wrap.i_mem.mem = IMem;
    //$readmemh({"../app/data_mem.sv"}, DMem);
    #1us $finish;
end // test_seq


// DUT instance mini_core 

mini_top mini_top (
.Clock               (Clk),
.Rst                 (Rst),
// //============================================
// //      fabric interface
// //============================================
.F2C_ReqValidQ503H     ('0),// input  logic        F2C_ReqValidQ503H     ,
.F2C_ReqOpcodeQ503H    ('0),// input  t_opcode     F2C_ReqOpcodeQ503H    ,
.F2C_ReqAddressQ503H   ('0),// input  logic [31:0] F2C_ReqAddressQ503H   ,
.F2C_ReqDataQ503H      ('0),// input  logic [31:0] F2C_ReqDataQ503H      ,
.F2C_RspValidQ504H     (),  // output logic        F2C_RspValidQ504H     , 
.F2C_RspDataQ504H      ()   // output logic [31:0] F2C_RspDataQ504H 
);      

`include "mini_core_trk.sv"

endmodule //mini_core_tb

