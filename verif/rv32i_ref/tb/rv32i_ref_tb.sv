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

module rv32i_ref_tb;
import common_pkg::*;
logic        Clk;
logic        Rst;
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
    $readmemh({"../../../target/rv32i_ref/tests/",test_name,"/gcc_files/inst_mem.sv"} , IMem);
    $readmemh({"../../../target/rv32i_ref/tests/",test_name,"/gcc_files/data_mem.sv"} , DMem);
    force rv32i_ref.imem = IMem; //backdoor to reference model memory
    force rv32i_ref.dmem = DMem; //backdoor to reference model memory
    #10;
    release rv32i_ref.imem;
    release rv32i_ref.dmem;
    //======================================
    // EOT - end of test
    //======================================
    #2000000;
    $error("ERROR: TIMEOUT");
    eot("ERROR: TIMEOUT");
end // test_seq

initial begin: check_eot
    forever begin
        #10 
        if(rv32i_ref.ebreak_was_called)   eot("ebreak_was_called");
        if(rv32i_ref.ecall_was_called)    eot("ecall_was_called");
        if(rv32i_ref.illegal_instruction) eot("ERROR: illegal_instruction");
    end
end

rv32i_ref
# (
    .I_MEM_LSB (I_MEM_OFFSET_MINI),
    .I_MEM_MSB (I_MEM_MSB_MINI),
    .D_MEM_LSB (D_MEM_OFFSET_MINI),
    .D_MEM_MSB (D_MEM_MSB_MINI)
)  rv32i_ref (
.clk  (Clk),
.rst  (Rst),
.run  (1'b1)
);

`include "rv32i_ref_tasks.vh"

import rv32i_ref_pkg::*;
t_debug_info debug_info;

assign debug_info = rv32i_ref.debug_info;
endmodule 

