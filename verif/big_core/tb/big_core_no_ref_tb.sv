//-----------------------------------------------------------------------------
// Title            : core tb
// Project          : big_core. 6 stage pipeline
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


`include "macros.vh"

module big_core_no_ref_tb  ;
import big_core_pkg::*;
import rv32i_ref_pkg::*;
//FIXME - dont know why need to include the common_pkg.. its already included in the the rv32i_ref_pkg
`include "common_pkg.vh"
  
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

integer random;
integer i;
string test_name;
logic [31:0] PcQ101H;
logic [31:0] PcQ102H;
logic [31:0] PcQ103H, PcQ104H, PcQ105H;
assign PcQ101H = big_core_top.big_core.big_core_ctrl.CtrlQ101H.Pc;
assign PcQ102H = big_core_top.big_core.big_core_ctrl.CtrlQ102H.Pc;
assign PcQ103H = big_core_top.big_core.big_core_ctrl.CtrlQ103H.Pc;
assign PcQ104H = big_core_top.big_core.big_core_ctrl.CtrlQ104H.Pc;
assign PcQ105H = big_core_top.big_core.big_core_ctrl.CtrlQ105H.Pc;

logic ps2_clk;
logic ps2_data;

`include "big_core_pmon_tasks.vh"
`include "big_core_trk.vh"
`include "big_core_ps2_tasks.vh"
`include "big_core_hw_seq.vh"

// VGA interface outputs
t_vga_out   vga_out;
logic inDisplayArea;

// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #2 Clk = 1'b0;
        #2 Clk = 1'b1;
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
    file = $fopen({"../../../target/big_core/tests/",test_name,"/gcc_files/inst_mem.sv"}, "r");
    if (!file) begin
        $error("the file: ../../../target/big_core/tests/%s/gcc_files/inst_mem.sv does not exist", test_name);
        $display("ERROR: inst_mem.sv file does not exist");
        $finish;
    end
    $readmemh({"../../../target/big_core/tests/",test_name,"/gcc_files/inst_mem.sv"} , IMem);
    force big_core_top.big_core_mem_wrap.i_mem.mem = IMem; //backdoor to actual memory
    //load the data to the DUT & reference model 
    file = $fopen({"../../../target/big_core/tests/",test_name,"/gcc_files/data_mem.sv"}, "r");
    if (file) begin
        $fclose(file);
        $readmemh({"../../../target/big_core/tests/",test_name,"/gcc_files/data_mem.sv"} , DMem);
        force big_core_top.big_core_mem_wrap.d_mem.mem = DMem; //backdoor to actual memory
        #10
        release big_core_top.big_core_mem_wrap.d_mem.mem;
    end
    
    //================================
    // run until ebreak is found
    //===============================
    begin wait(big_core_top.big_core.big_core_ctrl.ebreak_was_calledQ101H == 1'b1);
       track_performance();
       print_vga_screen();
       $display("ebreak was called");
       $finish();
    end
   
end // test_seq

parameter V_TIMEOUT = 100000;
parameter RF_NUM_MSB = 31; // NOTE!!!: auto inserted from script ovrd_params.py
initial begin: detect_timeout
    //=======================================
    // timeout
    //=======================================
    #V_TIMEOUT 
    $error("ERROR: test ended with timeout");
    $display("ERROR: No data integrity running - try to increase the timeout value");
    $finish;
end

logic        InFabricValidQ503H  ; 
logic        OutFabricValidQ505H ;
t_tile_trans InFabricQ503H ; 
t_tile_trans OutFabricQ505H ;
assign InFabricValidQ503H = 1'b0;
assign InFabricQ503H.address               = '0;
assign InFabricQ503H.opcode                = RD_RSP;
assign InFabricQ503H.data                  = '0;
assign InFabricQ503H.requestor_id          = '0;
assign InFabricQ503H.next_tile_fifo_arb_id = NULL_CARDINAL;

t_tile_id local_tile_id;
assign  local_tile_id = 8'h2_2;
logic RstPc;
assign RstPc = 1'b0;
big_core_top
#( .RF_NUM_MSB(RF_NUM_MSB) )    
big_core_top (
.Clock               (Clk),
.Rst                 (Rst),
.RstPc               (RstPc),
.local_tile_id       (local_tile_id),
//============================================
//      fabric interface
//============================================
 .InFabricValidQ503H    (InFabricValidQ503H),// input  logic        F2C_ReqValidQ503H     ,
 .InFabricQ503H         (InFabricQ503H),// input  t_opcode     F2C_ReqOpcodeQ503H    ,
 .big_core_ready       (),  // output  logic  big_core_ready       ,
 //
 .OutFabricQ505H        (OutFabricQ505H),  // output t_rdata      F2C_RspDataQ504H      ,
 .OutFabricValidQ505H   (OutFabricValidQ505H),  // output logic        F2C_RspValidQ504H
 .fab_ready             (5'b11111),   // input  t_fab_ready  fab_ready 
//============================================
//      keyboard interface
//============================================
.kbd_clk     ( ps2_clk ) ,// input logic             kbd_clk, // Clock from keyboard
.data_in_kc  ( ps2_data ) ,// input logic             data_in_kc, // Data from keyboard
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
    fd1 = $fopen({"../../../target/big_core/tests/",test_name,"/screen.log"},"w");
    if (fd1) $display("File was open successfully : %0d", fd1);
    else $display("File was not open successfully : %0d", fd1);
    for (int i = 0 ; i < SIZE_VGA_MEM; i = i+320) begin // Lines
        for (int j = 0 ; j < 4; j = j+1) begin // Bytes
            for (int k = 0 ; k < 320; k = k+4) begin // Words
                for (int l = 0 ; l < 8; l = l+1) begin // Bits  
                    draw = (big_core_top.big_core_mem_wrap.big_core_vga_ctrl.vga_mem.VGAMem[k+j+i][l] == 1'b1) ? "x" : " ";
                    $fwrite(fd1,"%s",draw);
                end        
            end 
            $fwrite(fd1,"\n");
        end
    end
endtask

task delay(input int cycles);
  for(int i =0; i< cycles; i++) begin
    @(posedge Clk);
  end
endtask

endmodule //big_core_tb

