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

`include "macros.sv"

module big_core_tb ;
import big_core_pkg::*;

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
t_fpga_out  fpga_out;
t_fpga_out  next_fpga_out;
t_vga_out   vga_out;

`MAFIA_DFF(fpga_out, next_fpga_out, Clk)

//=========================================
// Instantiating the big_core core
//=========================================
// big_core big_core (
//    .Clk                 (Clk),
//    .Rst                 (Rst),
//    .PcQ100H             (Pc),          // To I_MEM
//    .PreInstructionQ101H (Instruction), // From I_MEM
//    .DMemWrDataQ103H     (DMemData),  // To D_MEM
//    .DMemAddressQ103H    (DMemAddress), // To D_MEM
//    .DMemByteEnQ103H     (DMemByteEn),  // To D_MEM
//    .DMemWrEnQ103H       (DMemWrEn),    // To D_MEM
//    .DMemRdEnQ103H       (DMemRdEn),    // To D_MEM
//    .DMemRdRspQ104H      (DMemRspData)    // From D_MEM
//);
//=========================================
// Instantiating the big_core_top
//=========================================
big_core_top big_core_top(
    .Clk            (Clk     ),
    .Rst            (Rst     ),
    .Button_0       (Button_0),
    .Button_1       (Button_1),
    .Switch         (Switch  ),
    .fpga_out       (next_fpga_out),
    .vga_out        (vga_out  ) 
);

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


`MAFIA_DFF(IMem, NextIMem, Clk)
`MAFIA_DFF(DMem, NextDMem, Clk)

string test_name;
integer file;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    //======================================
    //load the program to the TB
    //======================================
    $readmemh({"../../../target/big_core/tests/",test_name,"/gcc_files/inst_mem.sv"} , IMem);
    $readmemh({"../../../target/big_core/tests/",test_name,"/gcc_files/inst_mem.sv"} , NextIMem);
    force big_core_top.big_core_mem_wrap.i_mem.IMem = IMem;

    file = $fopen({"../../../target/big_core/tests/",test_name,"/gcc_files/data_mem.sv"}, "r");
    if (file) begin
        $fclose(file);
        $readmemh({"../../../target/big_core/tests/",test_name,"/gcc_files/data_mem.sv"} , DMem);
        $readmemh({"../../../target/big_core/tests/",test_name,"/gcc_files/data_mem.sv"} , NextDMem);
        force big_core_top.big_core_mem_wrap.d_mem.DMem = DMem;
        #10
        release big_core_top.big_core_mem_wrap.d_mem.DMem;
    end


    #100000
    $display("===================\n test %s ended timeout \n=====================", test_name);
    $finish;

end // test_seq


logic [31:0] InstructionQ102H;
logic [31:0] InstructionQ103H;
`MAFIA_DFF(InstructionQ102H, big_core_top.big_core.InstructionQ101H, Clk)
`MAFIA_DFF(InstructionQ103H, InstructionQ102H, Clk)
`include "big_core_trk.vh"

parameter EBREAK = 32'h00100073;

// Ebrake detection
always @(posedge Clk) begin : ebrake_status
    if (EBREAK == InstructionQ103H) begin // ebrake instruction opcode
        $display("fpga_out = %p", fpga_out);
        $display("===================\n test %s ended with Ebreake \n=====================", test_name);
        $finish;
        //end_tb("The test ended");
    end
end


endmodule //big_core_tb

