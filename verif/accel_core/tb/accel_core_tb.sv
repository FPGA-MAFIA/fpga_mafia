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


`include "macros.vh"


module accel_core_tb;


import mini_core_pkg::*;
//FIXME - dont know why need to include the common_pkg.. its already included in the the mini_core_pkg
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
logic  [7:0] IMem     [I_MEM_SIZE_MINI + I_MEM_OFFSET_MINI - 1 : I_MEM_OFFSET_MINI];
logic  [7:0] DMem     [D_MEM_SIZE_MINI + D_MEM_OFFSET_MINI - 1 : D_MEM_OFFSET_MINI];


string test_name;
`include "accel_core_tasks.vh"
`include "accel_core_trk.sv"
`include "accel_core_pmon_tasks.vh"


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
    file = $fopen({"../../../target/accel_core/tests/",test_name,"/gcc_files/inst_mem.sv"}, "r");
    if (!file) begin
        $error("the file: ../../../target/accel_core/tests/%s/gcc_files/inst_mem.sv does not exist", test_name);
        $display("ERROR: inst_mem.sv file does not exist");
        $finish;
    end
    $readmemh({"../../../target/accel_core/tests/",test_name,"/gcc_files/inst_mem.sv"} , IMem);
    force accel_core_top.accel_core_mem_wrap.i_mem.mem = IMem; //backdoor to actual memory
    force rv32i_ref.imem                        = IMem; //backdoor to reference model memory
    //load the data to the DUT & reference model 
    file = $fopen({"../../../target/accel_core/tests/",test_name,"/gcc_files/data_mem.sv"}, "r");
    if (file) begin
        $fclose(file);
        $readmemh({"../../../target/accel_core/tests/",test_name,"/gcc_files/data_mem.sv"} , DMem);
        force accel_core_top.accel_core_mem_wrap.d_mem.mem = DMem; //backdoor to actual memory
        force rv32i_ref.dmem                        = DMem; //backdoor to reference model memory
        #10
        release accel_core_top.accel_core_mem_wrap.d_mem.mem;
        release rv32i_ref.dmem;
    end

    
    //=======================================
    // enable the checker data collection (monitor)
    //=======================================
    fork
    get_rf_write();
    get_ref_rf_write();
    begin wait(accel_core_top.mini_core.mini_core_ctrl.ebreak_was_calledQ101H == 1'b1);
        track_performance();
        eot(.msg("ebreak was called"));
    end
    join

end // test_seq

parameter V_TIMEOUT = 100000000;
parameter MINI_RF_NUM_MSB = 31;
initial begin: detect_timeout
    //=======================================
    // timeout
    //=======================================
    #V_TIMEOUT 
    $error("test ended with timeout");
    $display("ERROR: No data integrity running - try to increase the timeout value");
    $finish;
end


t_tile_id    local_tile_id;
logic        InFabricValidQ503H  ; 
logic        OutFabricValidQ505H ;
t_tile_trans InFabricQ503H ; 
t_tile_trans [2:0] ShiftInFabric ; 
logic        [2:0] ShiftInFabricValid ; 
t_tile_trans OutFabricQ505H ;

logic  [7:0] TILE33_DMem      [D_MEM_SIZE_MINI + D_MEM_OFFSET_MINI - 1 : D_MEM_OFFSET_MINI];
logic  [7:0] next_TILE33_DMem [D_MEM_SIZE_MINI + D_MEM_OFFSET_MINI - 1 : D_MEM_OFFSET_MINI];
`MAFIA_DFF(TILE33_DMem, next_TILE33_DMem, Clk)

logic [31:0] next_test;
logic [31:0] test;
`MAFIA_DFF(test, next_test, Clk)
always_comb begin
    next_TILE33_DMem = TILE33_DMem;
    next_test = test;
    if (OutFabricValidQ505H) begin
        if (OutFabricQ505H.opcode == WR) begin
            next_TILE33_DMem[OutFabricQ505H.address[23:0]+0] = OutFabricQ505H.data[7:0];
            next_TILE33_DMem[OutFabricQ505H.address[23:0]+1] = OutFabricQ505H.data[15:8];
            next_TILE33_DMem[OutFabricQ505H.address[23:0]+2] = OutFabricQ505H.data[23:16];
            next_TILE33_DMem[OutFabricQ505H.address[23:0]+3] = OutFabricQ505H.data[31:24];
        end
    end
end

logic [31:0] RdDataData;
assign RdDataData[7:0]   = TILE33_DMem[OutFabricQ505H.address[23:0]+0];
assign RdDataData[15:8]  = TILE33_DMem[OutFabricQ505H.address[23:0]+1];
assign RdDataData[23:16] = TILE33_DMem[OutFabricQ505H.address[23:0]+2];
assign RdDataData[31:24] = TILE33_DMem[OutFabricQ505H.address[23:0]+3];

assign ShiftInFabricValid[0] = OutFabricValidQ505H && (OutFabricQ505H.opcode == RD);
// Set the target address to the requestor id (This is the Read response address)
always_comb begin 
    ShiftInFabric[0] = '0;
    if (OutFabricValidQ505H && OutFabricQ505H.opcode == RD) begin
        ShiftInFabric[0].address[31:0]         = {local_tile_id,OutFabricQ505H.address[23:0]};
        ShiftInFabric[0].opcode                = RD_RSP;
        ShiftInFabric[0].data                  = (OutFabricQ505H.opcode==RD) ? RdDataData : '0;
        ShiftInFabric[0].requestor_id          = OutFabricQ505H.address[31:0];
        ShiftInFabric[0].next_tile_fifo_arb_id = OutFabricQ505H.next_tile_fifo_arb_id;
    end
end
`MAFIA_DFF(ShiftInFabric[2:1],      ShiftInFabric[1:0],      Clk)
`MAFIA_DFF(ShiftInFabricValid[2:1], ShiftInFabricValid[1:0], Clk)
assign InFabricQ503H        = ShiftInFabric[2];
assign InFabricValidQ503H   = ShiftInFabricValid[2];
// DUT instance mini_core 
assign  local_tile_id = 8'h2_2;
accel_core_top
#( .RF_NUM_MSB(MINI_RF_NUM_MSB) )    
accel_core_top (
.Clock               (Clk),
.Rst                 (Rst),
.local_tile_id       (local_tile_id),
//============================================
//      fabric interface
//============================================
 .InFabricValidQ503H    (InFabricValidQ503H),// input  logic        F2C_ReqValidQ503H     ,
 .InFabricQ503H         (InFabricQ503H),// input  t_opcode     F2C_ReqOpcodeQ503H    ,
 .mini_core_ready       (),  // output  logic  mini_core_ready       ,
 //
 .OutFabricQ505H        (OutFabricQ505H),  // output t_rdata      F2C_RspDataQ504H      ,
 .OutFabricValidQ505H   (OutFabricValidQ505H),  // output logic        F2C_RspValidQ504H
 .fab_ready             (5'b11111)   // input  t_fab_ready  fab_ready 
);      


rv32i_ref
# (
    .I_MEM_LSB (I_MEM_OFFSET_MINI),
    .I_MEM_MSB (I_MEM_MSB_MINI),
    .D_MEM_LSB (D_MEM_OFFSET_MINI),
    .D_MEM_MSB (D_MEM_MSB_MINI)
)  rv32i_ref (
.clk    (Clk),
.rst    (Rst),
.run    (1'b1) // FIXME - set the RUN only when the mini_core DUT is retiring the instruction.
               // every time the run is set, the next instruction is executed
);
endmodule //mini_core_tb

