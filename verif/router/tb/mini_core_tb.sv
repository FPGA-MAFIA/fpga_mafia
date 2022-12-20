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


module mini_core_tb ;
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

initial begin: test_seq
    //======================================
    //load the program to the TB
    //======================================
    $readmemh({"../../target/mini_core/gcc_gen_files/inst_mem.sv"}, IMem);
    //$readmemh({"../app/data_mem.sv"}, DMem);
    #1us $finish;
end // test_seq


integer trk_alu;
initial begin: trk_alu_gen
    $timeformat(-9, 1, " ", 6);
    trk_alu = $fopen({"../../target/trk_alu.log"},"w");
    $fwrite(trk_alu,"---------------------------------------------------------\n");
    $fwrite(trk_alu,"Time\t|\tPC \t | AluIn1Q102H\t| AluIn2Q102H\t| AluOutQ102H\t|\n");
    $fwrite(trk_alu,"---------------------------------------------------------\n");  

end
//tracker on ALU operations
always @(posedge Clk) begin : alu_print
    $fwrite(trk_alu,"%t\t| %8h |%8h \t|%8h \t|%8h \t| \n", $realtime,PcQ100H, mini_core.AluIn1Q102H , mini_core.AluIn2Q102H, mini_core.AluOutQ102H);
end

integer trk_inst;
initial begin: trk_inst_gen
    $timeformat(-9, 1, " ", 6);
    trk_inst = $fopen({"../../target/trk_inst.log"},"w");
    $fwrite(trk_inst,"---------------------------------------------------------\n");
    $fwrite(trk_inst,"Time\t|\tPC \t | Instraction\t|\n");
    $fwrite(trk_inst,"---------------------------------------------------------\n");  

end
always @(posedge Clk) begin : inst_print
    $fwrite(trk_inst,"%t\t| %8h \t |%32b | \n", $realtime,PcQ100H, Instruction);
end
integer trk_fetch;
initial begin: trk_fetch_gen
    $timeformat(-9, 1, " ", 6);
    trk_fetch = $fopen({"../../target/trk_fetch.log"},"w");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");
    $fwrite(trk_fetch,"Time\t|\tPC \t |Funct3 \t| Funct7 \t | Opcode|\n");
    $fwrite(trk_fetch,"---------------------------------------------------------\n");  

end
always @(posedge Clk) begin : fetch_print
    $fwrite(trk_fetch,"%t\t| %8h \t |%3b \t |%7b\t |%7b| \n", $realtime,PcQ100H, mini_core.Funct3Q101H, mini_core.Funct7Q101H, mini_core.OpcodeQ101H);
end

integer trk_memory_access;
initial begin: trk_memory_access_gen
    $timeformat(-9, 1, " ", 6);
    trk_memory_access = $fopen({"../../target/trk_memory_access.log"},"w");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");
    $fwrite(trk_memory_access,"Time\t|\tPC \t | Opcode\t| Adress\t| Data\t|\n");
    $fwrite(trk_memory_access,"---------------------------------------------------------\n");  

end
//tracker on memory_access operations
always @(posedge Clk) begin : memory_access_print
    if(DMemWrEn) begin
    $fwrite(trk_memory_access,"%t\t| %8h \t write \t|%8h \t|%8h \n", $realtime, PcQ100H, DMemAddress, DMemData);
    end
    if(DMemRdEn) begin
    $fwrite(trk_memory_access,"%t\t| %8h \t|read \t|%8h \t|%8h \n", $realtime, PcQ100H, DMemAddress, DMemData);
    end
end

// DUT instance mini_core 

mini_core mini_core (
    .Clock               (Clk),
    .Rst                 (Rst),
    .PcQ100H             (PcQ100H),          // To I_MEM
    .PreInstructionQ101H (Instruction), // From I_MEM
    .DMemWrDataQ103H     (DMemData),  // To D_MEM
    .DMemAddressQ103H    (DMemAddress), // To D_MEM
    .DMemByteEnQ103H     (DMemByteEn),  // To D_MEM
    .DMemWrEnQ103H       (DMemWrEn),    // To D_MEM
    .DMemRdEnQ103H       (DMemRdEn),    // To D_MEM
    .DMemRdRspQ104H      (DMemRdRspData)    // From D_MEM
);      





assign Instruction = {IMem[PcQ100H + 3] ,
                      IMem[PcQ100H + 2] ,
                      IMem[PcQ100H + 1] ,
                      IMem[PcQ100H + 0]};


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
assign DMemRdRspData = {DMem[DMemAddress+3] ,
                      DMem[DMemAddress+2] ,
                      DMem[DMemAddress+1] ,
                      DMem[DMemAddress+0]};


endmodule //mini_core_tb

