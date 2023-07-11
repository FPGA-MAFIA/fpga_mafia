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
import common_pkg::*;
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
logic  [7:0] IMem     [I_MEM_SIZE_MINI + I_MEM_OFFSET_MINI - 1 : I_MEM_OFFSET_MINI];
logic  [7:0] DMem     [D_MEM_SIZE_MINI + D_MEM_OFFSET_MINI - 1 : D_MEM_OFFSET_MINI];
logic  [7:0] NextDMem [D_MEM_SIZE_MINI + D_MEM_OFFSET_MINI - 1 : D_MEM_OFFSET_MINI];



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


`MAFIA_DFF(IMem, IMem    , Clk)
`MAFIA_DFF(DMem, NextDMem, Clk)

string test_name;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    //======================================
    //load the program to the TB
    //======================================
    $readmemh({"../../../target/mini_core/tests/",test_name,"/gcc_files/inst_mem.sv"} , IMem);
    force mini_core_top.mini_mem_wrap.i_mem.mem = IMem; //backdoor to actual memory
    force rv32i_ref.imem              = IMem; //backdoor to reference model memory
    //$readmemh({"../app/data_mem.sv"}, DMem);
    #1000 $finish;
end // test_seq


// DUT instance mini_core 
t_tile_id local_tile_id;
assign  local_tile_id = 8'h2_2;
mini_core_top mini_core_top (
.Clock               (Clk),
.Rst                 (Rst),
.local_tile_id       (local_tile_id),
//============================================
//      fabric interface
//============================================
 .InFabricValidQ503H    ('0),// input  logic        F2C_ReqValidQ503H     ,
 .InFabricQ503H         ('0),// input  t_opcode     F2C_ReqOpcodeQ503H    ,
 .mini_core_ready       (),  // output  logic  mini_core_ready       ,
 //
 .OutFabricQ505H        (),  // output t_rdata      F2C_RspDataQ504H      ,
 .OutFabricValidQ505H   (),  // output logic        F2C_RspValidQ504H
 .fab_ready             (5'b11111)   // input  t_fab_ready  fab_ready 
);      

`include "mini_core_trk.sv"

rv32i_ref
# (
    .I_MEM_LSB (I_MEM_OFFSET_MINI),
    .I_MEM_MSB (I_MEM_MSB_MINI),
    .D_MEM_LSB (D_MEM_OFFSET_MINI),
    .D_MEM_MSB (D_MEM_MSB_MINI)
)  rv32i_ref (
.clk                 (Clk),
.rst                 (Rst)
);

endmodule //mini_core_tb

