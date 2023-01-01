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
    .SEG7_0         (SEG7_0  ),
    .SEG7_1         (SEG7_1  ),
    .SEG7_2         (SEG7_2  ),
    .SEG7_3         (SEG7_3  ),
    .SEG7_4         (SEG7_4  ),
    .SEG7_5         (SEG7_5  ),
    .LED            (LED     ),
    .RED            (RED     ),
    .GREEN          (GREEN   ),
    .BLUE           (BLUE    ),
    .h_sync         (h_sync  ),
    .v_sync         (v_sync  ) 
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


`RVC_DFF(IMem, NextIMem, Clk)
`RVC_DFF(DMem, NextDMem, Clk)

string test_name;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    //======================================
    //load the program to the TB
    //======================================
    $readmemh({"../../target/big_core/gcc_gen_files/",test_name,"/inst_mem.sv"} , IMem);
    $readmemh({"../../target/big_core/gcc_gen_files/",test_name,"/inst_mem.sv"} , NextIMem);
    force big_core_top.big_core_mem_wrap.i_mem.IMem = IMem;
    //$readmemh({"../../target/big_core/gcc_gen_files/",test_name,"/data_mem_rv32i.sv"} , DMem);
    #10000 $finish;
end // test_seq


integer trk_alu;
initial begin: trk_alu_gen
    $timeformat(-9, 1, " ", 6);
    trk_alu = $fopen({"../../target/big_core/trk_alu.log"},"w");
    $fwrite(trk_alu,"---------------------------------------------------------\n");
    $fwrite(trk_alu,"Time    |    PC    | inst_op | opcode |  AluIn1   |  AluIn2   | AluOut   |  \n");
    $fwrite(trk_alu,"---------------------------------------------------------\n");  

end
//tracker on ALU operations
always @(posedge Clk) begin : alu_print
    $fwrite(trk_alu,"%t  | %8h |  %5s  | %6s | %8h  | %8h  |%8h  | \n", $realtime,big_core_top.big_core.PcQ102H, big_core_top.big_core.OpcodeQ102H.name(), big_core_top.big_core.CtrlAluOpQ102H.name(), big_core_top.big_core.AluIn1Q102H, big_core_top.big_core.AluIn2Q102H, big_core_top.big_core.AluOutQ102H); // # FIXME
end

integer trk_inst;
initial begin: trk_inst_gen
    $timeformat(-9, 1, " ", 6);
    trk_inst = $fopen({"../../target/big_core/trk_inst.log"},"w");
    $fwrite(trk_inst,"---------------------------------------------------------\n");
    $fwrite(trk_inst,"Time\t|\tPC \t | Instraction\t|\n");
    $fwrite(trk_inst,"---------------------------------------------------------\n");  

end
always @(posedge Clk) begin : inst_print
    $fwrite(trk_inst,"%t\t| %8h \t |%32b | \n", $realtime,big_core_top.big_core.PcQ100H, big_core_top.big_core.PreInstructionQ101H);
end
integer trk_fetch;
initial begin: trk_fetch_gen
    $timeformat(-9, 1, " ", 6);
    trk_fetch = $fopen({"../../target/big_core/trk_fetch.log"},"w");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");
    $fwrite(trk_fetch,"Time\t|\tPC \t |Funct3 \t| Funct7 \t | Opcode|\n");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");  

end
always @(posedge Clk) begin : fetch_print
    $fwrite(trk_fetch,"%t\t| %8h \t |%3b \t |%7b\t |%7b| \n", $realtime,big_core_top.big_core.PcQ100H, big_core_top.big_core.Funct3Q101H, big_core_top.big_core.Funct7Q101H, big_core_top.big_core.OpcodeQ101H); // # FIXME
end

integer trk_memory_access;
initial begin: trk_memory_access_gen
    $timeformat(-9, 1, " ", 6);
    trk_memory_access = $fopen({"../../target/big_core/trk_memory_access.log"},"w");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_memory_access,"Time\t\t\t| PC\t\t\t\t\t| Opcode\t| Adress\t\t\t| Data \n");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");  

end
//tracker on memory_access operations
always @(posedge Clk) begin : memory_access_print
    if(DMemWrEn) begin
    $fwrite(trk_memory_access,"%t\t\t| %8h\t\t| write\t\t| %8h\t\t| %8h \n", $realtime, big_core_top.big_core.PcQ100H, big_core_top.big_core.DMemAddressQ103H, big_core_top.big_core.DMemWrDataQ103H);
    end
    if(DMemRdEn) begin
    $fwrite(trk_memory_access,"%t\t\t| %8h\t\t| read\t\t| %8h\t\t| %8h \n", $realtime, big_core_top.big_core.PcQ100H, big_core_top.big_core.DMemAddressQ103H, big_core_top.big_core.DMemWrDataQ103H);
    end
end

 





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


endmodule //big_core_tb

