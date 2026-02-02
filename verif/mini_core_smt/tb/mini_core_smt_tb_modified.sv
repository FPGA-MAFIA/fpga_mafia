//-----------------------------------------------------------------------------
// Title            : core tb
// Project          : simple_core
// File             : core_tb.sv
// Description      : SMT testbench with dual reference model comparison
//----------------------------------------------------------------------------- 

`include "macros.vh"

module mini_core_smt_tb;

import mini_core_smt_pkg::*;
`include "common_pkg.vh"

logic        Clk;
logic        Rst;
logic [31:0] PcQ100H;
logic [31:0] Instruction;
logic [31:0] DMemAddress;
logic [31:0] DMemData;
logic [3:0]  DMemByteEn;
logic        DMemWrEn;
logic        DMemRdEn;
logic [31:0] DMemRdRspData;
logic  [7:0] IMem     [I_MEM_SIZE_MINI + I_MEM_OFFSET_MINI - 1 : I_MEM_OFFSET_MINI];
logic  [7:0] DMem     [D_MEM_SIZE_MINI + D_MEM_OFFSET_MINI - 1 : D_MEM_OFFSET_MINI];

string test_name;
`include "mini_core_smt_tasks_mod.vh"
`include "mini_core_smt_trk_mod.sv"

// ========================
// Clock generation
// ========================
initial begin: clock_gen
    forever begin
        #5 Clk = 1'b0;
        #5 Clk = 1'b1;
    end
end

// ========================
// Reset generation
// ========================
initial begin: reset_gen
     Rst = 1'b1;
#100 Rst = 1'b0;
end

`MAFIA_DFF(IMem, IMem, Clk)
`MAFIA_DFF(DMem, DMem, Clk)


integer file0,file1;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);

    file0 = $fopen({"../../../target/mini_core_smt/tests/test0/gcc_files/inst_mem.sv"}, "r");
    file1 = $fopen({"../../../target/mini_core_smt/tests/test1/gcc_files/inst_mem.sv"}, "r");

    if (!file0 || !file1) begin
        $error("one of inst_mem.sv couldn't be opened");
        $display("ERROR: inst_mem.sv file does not exist");
        $finish;
    end
    $readmemh({"../../../target/mini_core_smt/tests/instz_mem.sv"} , IMem);
    force mini_core_smt_top.mini_smt_mem_wrap.i_mem.mem = IMem; //backdoor to actual memory
    $readmemh({"../../../target/mini_core_smt/tests/test0/gcc_files/inst_mem.sv"} ,ref_core0.imem);
    $readmemh({"../../../target/mini_core_smt/tests/test1/gcc_files/inst_mem.sv"} ,ref_core1.imem);

    //load the data to the DUT & reference model 
    file0 = $fopen({"../../../target/mini_core_smt/tests/test0/gcc_files/data_mem.sv"}, "r");
    file1 = $fopen({"../../../target/mini_core_smt/tests/test1/gcc_files/data_mem.sv"}, "r");
    if (file0 && file1) begin
        $fclose(file0);
        $fclose(file1);
        $readmemh({"../../../target/mini_core_smt/tests/dataz_mem.sv"} , DMem);
        force mini_core_smt_top.mini_smt_mem_wrap.d_mem.mem = DMem; //backdoor to actual memory
        $readmemh({"../../../target/mini_core_smt/tests/test0/gcc_files/dmem_mem.sv"} ,ref_core0.dmem);
        $readmemh({"../../../target/mini_core_smt/tests/test1/gcc_files/dmem_mem.sv"} ,ref_core1.dmem);
        #10
        release mini_core_smt_top.mini_smt_mem_wrap.d_mem.mem;
        //release rv32i_ref.dmem;
    end
    
    //=======================================
    // enable the checker data collection (monitor)
    //=======================================
    fork
    get_rf_write();
    get_ref_rf_write();
    begin wait(mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.ebreak_was_calledQ101H == 1'b1);
        eot(.msg("ebreak was called"));
    end
    join

end // test_seq

parameter V_TIMEOUT = 1000000;
parameter MINI_RF_NUM_MSB = 31;
initial begin: detect_timeout
    #V_TIMEOUT 
    $error("test ended with timeout");
    $display("ERROR: No data integrity running - try to increase the timeout value");
    $finish;
end

// Fabric & tile simulation logic (unchanged)
t_tile_id    local_tile_id;
logic        InFabricValidQ503H;
logic        OutFabricValidQ505H;
t_tile_trans InFabricQ503H;
t_tile_trans [2:0] ShiftInFabric;
logic        [2:0] ShiftInFabricValid;
t_tile_trans OutFabricQ505H;

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

always_comb begin 
    ShiftInFabric[0] = '0;
    if (OutFabricValidQ505H && OutFabricQ505H.opcode == RD) begin
        ShiftInFabric[0].address[31:0]         = {local_tile_id,OutFabricQ505H.address[23:0]};
        ShiftInFabric[0].opcode                = RD_RSP;
        ShiftInFabric[0].data                  = RdDataData;
        ShiftInFabric[0].requestor_id          = OutFabricQ505H.address[31:0];
        ShiftInFabric[0].next_tile_fifo_arb_id = OutFabricQ505H.next_tile_fifo_arb_id;
    end
end

`MAFIA_DFF(ShiftInFabric[2:1], ShiftInFabric[1:0], Clk)
`MAFIA_DFF(ShiftInFabricValid[2:1], ShiftInFabricValid[1:0], Clk)
assign InFabricQ503H        = ShiftInFabric[2];
assign InFabricValidQ503H   = ShiftInFabricValid[2];

// ========================
// DUT instance
// ========================
assign local_tile_id = 8'h2_2;
mini_core_smt_top #( .RF_NUM_MSB(MINI_RF_NUM_MSB) ) mini_core_smt_top (
    .Clock               (Clk),
    .Rst                 (Rst),
    .local_tile_id       (local_tile_id),
    .InFabricValidQ503H  (InFabricValidQ503H),
    .InFabricQ503H       (InFabricQ503H),
    .mini_core_ready     (),
    .OutFabricQ505H      (OutFabricQ505H),
    .OutFabricValidQ505H (OutFabricValidQ505H),
    .fab_ready           (5'b11111)
);

// ========================
// Reference models (dual thread)
// ========================
rv32i_ref #( .I_MEM_LSB(I_MEM_OFFSET_MINI), .I_MEM_MSB(I_MEM_MSB_MINI), .D_MEM_LSB(D_MEM_OFFSET_MINI), .D_MEM_MSB(D_MEM_MSB_MINI) ) ref_core0 (
    .clk (Clk),
    .rst (Rst),
    .run (1'b1)
);

rv32i_ref #( .I_MEM_LSB(I_MEM_OFFSET_MINI), .I_MEM_MSB(I_MEM_MSB_MINI), .D_MEM_LSB(D_MEM_OFFSET_MINI), .D_MEM_MSB(D_MEM_MSB_MINI) ) ref_core1 (
    .clk (Clk),
    .rst (Rst),
    .run (1'b1)
);

endmodule