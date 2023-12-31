//-----------------------------------------------------------------------------
// Title            : core tb
// Project          : core_rrv. 6 stage pipeline
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
// (4) Calculate IPC = CSR_CYCLE/CSR_INSTRET 
//-----------------------------------------------------------------------------


`include "macros.sv"

module core_rrv_tb  ;
import core_rrv_pkg::*;
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
logic  [7:0] IMem     [I_MEM_SIZE + I_MEM_OFFSET- 1 : I_MEM_OFFSET];
logic  [7:0] DMem     [D_MEM_SIZE + D_MEM_OFFSET - 1 : D_MEM_OFFSET];

`include "core_rrv_pmon_tasks.vh"

// VGA interface outputs
t_vga_out   vga_out;
logic inDisplayArea;

string test_name;

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
#100 Rst = 1'b0;
end: reset_gen


`MAFIA_DFF(IMem, IMem, Clk)
`MAFIA_DFF(DMem, DMem, Clk)

integer file;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    //======================================
    //load the program to the DUT & reference model
    //======================================
    // Make sure inst_mem.sv exists
    file = $fopen({"../../../target/core_rrv/tests/",test_name,"/gcc_files/inst_mem.sv"}, "r");
    if (!file) begin
        $error("the file: ../../../target/core_rrv/tests/%s/gcc_files/inst_mem.sv does not exist", test_name);
        $display("ERROR: inst_mem.sv file does not exist");
        $finish;
    end
    $readmemh({"../../../target/core_rrv/tests/",test_name,"/gcc_files/inst_mem.sv"} , IMem);
    force core_rrv_top.core_rrv_mem_wrap.i_mem.mem = IMem; //backdoor to actual memory
    //load the data to the DUT & reference model 
    file = $fopen({"../../../target/core_rrv/tests/",test_name,"/gcc_files/data_mem.sv"}, "r");
    if (file) begin
        $fclose(file);
        $readmemh({"../../../target/core_rrv/tests/",test_name,"/gcc_files/data_mem.sv"} , DMem);
        force core_rrv_top.core_rrv_mem_wrap.d_mem.mem = DMem; //backdoor to actual memory
        #10
        release core_rrv_top.core_rrv_mem_wrap.d_mem.mem;
    end
    
    //================================
    // run until ebreak is found
    //===============================
    begin wait(core_rrv_top.core_rrv.core_rrv_ctrl.ebreak_was_calledQ101H == 1'b1);
       track_performance();
       print_vga_screen();
       $display("ebreak was called");
       $finish();
    end
   
end // test_seq

parameter V_TIMEOUT = 100000;
parameter RF_NUM_MSB = 31; // For RV32E override this to 15
initial begin: detect_timeout
    //=======================================
    // timeout
    //=======================================
    #V_TIMEOUT 
    $error("test ended with timeout");
    $display("ERROR: No data integrity running - try to increase the timeout value");
    $finish;
end

core_rrv_top
#( .RF_NUM_MSB(RF_NUM_MSB) )    
core_rrv_top (
.Clock               (Clk),
.Rst                 (Rst),
.local_tile_id       (local_tile_id),
//============================================
//      fabric interface
//============================================
 .InFabricValidQ503H    (InFabricValidQ503H),// input  logic        F2C_ReqValidQ503H     ,
 .InFabricQ503H         (InFabricQ503H),// input  t_opcode     F2C_ReqOpcodeQ503H    ,
 .core_rrv_ready       (),  // output  logic  core_rrv_ready       ,
 //
 .OutFabricQ505H        (OutFabricQ505H),  // output t_rdata      F2C_RspDataQ504H      ,
 .OutFabricValidQ505H   (OutFabricValidQ505H),  // output logic        F2C_RspValidQ504H
 .fab_ready             (5'b11111),   // input  t_fab_ready  fab_ready 
//============================================
//      vga interface
//============================================
 .vga_out               (vga_out),
 .inDisplayArea         (inDisplayArea),
 //============================================
//      fpga interface
//============================================             
.fpga_in                (),  // CR_MEM
.fpga_out               ()      // CR_MEM
);      

task print_vga_screen ;
// VGA memory snapshot - simulate a screen
    integer fd1;
    string draw;
    fd1 = $fopen({"../../../target/core_rrv/tests/",test_name,"/screen.log"},"w");
    if (fd1) $display("File was open successfully : %0d", fd1);
    else $display("File was not open successfully : %0d", fd1);
    for (int i = 0 ; i < SIZE_VGA_MEM; i = i+320) begin // Lines
        for (int j = 0 ; j < 4; j = j+1) begin // Bytes
            for (int k = 0 ; k < 320; k = k+4) begin // Words
                for (int l = 0 ; l < 8; l = l+1) begin // Bits  
                    draw = (core_rrv_top.core_rrv_mem_wrap.core_rrv_vga_ctrl.vga_mem.VGAMem[k+j+i][l] == 1'b1) ? "x" : " ";
                    $fwrite(fd1,"%s",draw);
                end        
            end 
            $fwrite(fd1,"\n");
        end
    end
endtask

endmodule //core_rrv_tb

