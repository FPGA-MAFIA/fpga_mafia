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
import common_pkg::*;

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
logic inDisplayArea; 

logic EndOfTest;
`MAFIA_DFF(fpga_out, next_fpga_out, Clk)
`include "big_core_tasks.vh"

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
    .Clk            (Clk),
    .Rst            (Rst),
    .RstPc          (1'b0),
    .local_tile_id  ('0),       //input  t_tile_id    local_tile_id,
    // Fabric interface
    .InFabricValidQ503H ('0),//input  logic        ,
    .InFabricQ503H      ('0),//input  t_tile_trans ,
    .OutFabricValidQ505H(),  //output logic        ,
    .OutFabricQ505H     (),  //output t_tile_trans ,
    // FPGA interface
    .Button_0       (Button_0),
    .Button_1       (Button_1),
    .Switch         (Switch  ),
    .fpga_out       (next_fpga_out),
    .inDisplayArea  (inDisplayArea),
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
    Button_0 = 1'b0;
    Button_1 = 1'b0;
    Switch   = 10'b0;
    EndOfTest = 1'b0;
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
    //reference model sc core:
    force ref_core.IMem = IMem;

    file = $fopen({"../../../target/big_core/tests/",test_name,"/gcc_files/data_mem.sv"}, "r");
    if (file) begin
        $fclose(file);
        $readmemh({"../../../target/big_core/tests/",test_name,"/gcc_files/data_mem.sv"} , DMem);
        $readmemh({"../../../target/big_core/tests/",test_name,"/gcc_files/data_mem.sv"} , NextDMem);
        force big_core_top.big_core_mem_wrap.d_mem.DMem = DMem;
        force ref_core.DMem = DMem;
        #10
        release big_core_top.big_core_mem_wrap.d_mem.DMem;
        release ref_core.DMem;
    end
    if(test_name == "alive_sim_FPGA") begin
        `include "alive_sim_FPGA.vh"
    end


    #100000
    EndOfTest = 1'b1;
    print_vga_screen();
    $error(" Timeout \n===================\n test %s ended timeout \n=====================", test_name);
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
        print_vga_screen();
        $finish;
        //end_tb("The test ended");
    end
end

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
                    draw = (big_core_top.big_core_mem_wrap.big_core_vga_ctrl.vga_mem.VGAMem[k+j+i][l] === 1'b1) ? "x" : " ";
                    $fwrite(fd1,"%s",draw);
                end        
            end 
            $fwrite(fd1,"\n");
        end
    end
endtask




ref_core ref_core(
    .Clk (Clk),
    .Rst (Rst)
);

endmodule //big_core_tb

