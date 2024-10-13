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
//-----------------------------------------------------------------------------


`include "macros.vh"


module big_core_cachel1_tb  ;
import big_core_pkg::*;
import rv32i_ref_pkg::*;
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
logic  [7:0] IMem     [I_MEM_SIZE + I_MEM_OFFSET - 1 : I_MEM_OFFSET];
logic  [7:0] TempDMem [D_MEM_SIZE + D_MEM_OFFSET - 1 : D_MEM_OFFSET];
logic  [7:0] DMem     [D_MEM_SIZE + D_MEM_OFFSET - 1 : D_MEM_OFFSET];
logic  [7:0] NextDMem [D_MEM_SIZE + D_MEM_OFFSET - 1 : D_MEM_OFFSET];

logic ps2_clk;
logic ps2_data;

string test_name;
logic [31:0] PcQ101H;
logic [31:0] PcQ102H;
logic [31:0] PcQ103H, PcQ104H, PcQ105H;
assign PcQ101H = big_core_cachel1_top.big_core.big_core_ctrl.CtrlQ101H.Pc;
assign PcQ102H = big_core_cachel1_top.big_core.big_core_ctrl.CtrlQ102H.Pc;
assign PcQ103H = big_core_cachel1_top.big_core.big_core_ctrl.CtrlQ103H.Pc;
assign PcQ104H = big_core_cachel1_top.big_core.big_core_ctrl.CtrlQ104H.Pc;
assign PcQ105H = big_core_cachel1_top.big_core.big_core_ctrl.CtrlQ105H.Pc;


`include "big_core_cachel1_tasks.vh"
`include "big_core_cachel1_mem_tasks.vh"
`include "big_core_cachel1_pmon_tasks.vh"
`include "big_core_cachel1_trk.vh"
`include "big_core_cachel1_ref_trk.vh"

//VGA interface outputs
t_vga_out   vga_out;
logic       inDisplayArea;

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
`MAFIA_DFF(DMem, NextDMem, Clk)

integer file;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    //======================================
    //load the program to the DUT & reference model
    //======================================
    // Make sure inst_mem.sv exists
    file = $fopen({"../../../target/big_core_cachel1/tests/",test_name,"/gcc_files/inst_mem.sv"}, "r");
    if (!file) begin
        $error("the file: ../../../target/big_core_cachel1/tests/%s/gcc_files/inst_mem.sv does not exist", test_name);
        $display("ERROR: inst_mem.sv file does not exist");
        $finish;
    end
    $readmemh({"../../../target/big_core_cachel1/tests/",test_name,"/gcc_files/inst_mem.sv"} , IMem);
    force big_core_cachel1_top.mem_ss.i_mem.mem = IMem; //backdoor to actual memory
    force rv32i_ref.imem                        = IMem; //backdoor to reference model memory
    // loading dmem 
    file = $fopen({"../../../target/big_core_cachel1/tests/",test_name,"/gcc_files/data_mem.sv"}, "r");
    if (file) begin
        $readmemh({"../../../target/big_core_cachel1/tests/",test_name,"/gcc_files/data_mem.sv"} , TempDMem);
        //force array.mem      = DMem; //backdoor to actual memory
        force rv32i_ref.dmem = TempDMem; //backdoor to reference model memory
        force DMem           = TempDMem; //backdoor to reference model memory
        #10
        //release array.mem;
        release rv32i_ref.dmem;
        release DMem;
    end
 
    

    //=======================================
    // enable the checker data collection (monitor)
    //=======================================
    fork
    get_rf_write();
    get_ref_rf_write();   
    get_mem_store();
    get_ref_mem_store();
    get_mem_load();
    get_ref_mem_load();
    begin wait(big_core_cachel1_top.big_core.big_core_ctrl.ebreak_was_calledQ101H == 1'b1);
    track_performance();     // monitoring CPI and IPC
    print_vga_screen();
    eot(.msg("ebreak was called"));
    sl_eot(.s_msg("ebreak was called"), .l_msg("ebreak was called"));
    end
    join

   
end // test_seq

parameter V_TIMEOUT = 250000;
parameter RF_NUM_MSB = 31; // NOTE!!!: auto inserted from script ovrd_params.py
initial begin: detect_timeout
    //=======================================
    // timeout
    //=======================================
    #V_TIMEOUT 
    $error("test ended with timeout");
    $display("ERROR: No data integrity running - try to increase the timeout value");
    $finish;
end

import d_cache_param_pkg::*;
t_fm_rd_rsp fm2cache_rd_rsp;
t_fm_req    cache2fm_req_q3;
// DUT instance big_core_cachel1 
big_core_cachel1_top
#( .RF_NUM_MSB(RF_NUM_MSB) )    
big_core_cachel1_top (
.Clock               (Clk),
.Rst                 (Rst),
.local_tile_id       (),
.RstPc               (Rst), 
//============================================
//      keyboard interface
//============================================
.kbd_clk             ( 1'b0 ),
.data_in_kc          ( 1'b0 ),
//============================================
//      vga interface
//============================================
.inDisplayArea      (inDisplayArea),
.vga_out            (vga_out),        
//============================================
//      fpga interface
//============================================             
.fpga_in            (), 
.fpga_out           (),  
//============================================
// FM interface
//============================================
.cache2fm_req_q3    (cache2fm_req_q3),
.fm2cache_rd_rsp    (fm2cache_rd_rsp), 
//============================================
//      sdram controller interface
//============================================             
.DRAM_ADDR          (),  
.DRAM_BA            (),    
.DRAM_CAS_N         (), 
.DRAM_CKE           (),   
.DRAM_CLK           (),   
.DRAM_CS_N          (),  
.DRAM_DQ            (),    
.DRAM_DQML          (), 
.DRAM_RAS_N         (),
.DRAM_DQMH          (),  
.DRAM_WE_N          ()   
);      

//============================
//     Far Memory ARRAY
//============================
t_fm_rd_rsp [9:0] samp_fm2cache_rd_rsp;
logic  wr_enable_fm;
assign wr_enable_fm = cache2fm_req_q3.valid && (cache2fm_req_q3.opcode == DIRTY_EVICT_OP);

/*
array  #(
    .WORD_WIDTH     (CL_WIDTH),
    .ADRS_WIDTH     (SET_ADRS_WIDTH + TAG_WIDTH)
) far_memory_array (
    .clk            (Clk),                                     //input
    .rst            (Rst),                                     //input
    //write interface
    .wr_en          (cache2fm_req_q3.valid && (cache2fm_req_q3.opcode == DIRTY_EVICT_OP)),                   //input
    .wr_address     (cache2fm_req_q3.address[MSB_TAG:LSB_SET]),//input
    .wr_data        (cache2fm_req_q3.data),                    //input
    //read interface
    .rd_address     (cache2fm_req_q3.address[MSB_TAG:LSB_SET]),//input
    .q              (samp_fm2cache_rd_rsp[0].data)                //output
);
*/



//reading from D_MEM(Acts as FM):
always_comb begin
    samp_fm2cache_rd_rsp[0].data[7:0]     = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h0}];
    samp_fm2cache_rd_rsp[0].data[15:8]    = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h1}];
    samp_fm2cache_rd_rsp[0].data[23:16]   = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h2}];
    samp_fm2cache_rd_rsp[0].data[31:24]   = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h3}];
    samp_fm2cache_rd_rsp[0].data[39:32]   = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h4}];
    samp_fm2cache_rd_rsp[0].data[47:40]   = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h5}];
    samp_fm2cache_rd_rsp[0].data[55:48]   = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h6}];
    samp_fm2cache_rd_rsp[0].data[63:56]   = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h7}];
    samp_fm2cache_rd_rsp[0].data[71:64]   = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h8}];
    samp_fm2cache_rd_rsp[0].data[79:72]   = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h9}];
    samp_fm2cache_rd_rsp[0].data[87:80]   = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hA}];
    samp_fm2cache_rd_rsp[0].data[95:88]   = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hB}];
    samp_fm2cache_rd_rsp[0].data[103:96]  = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hC}];
    samp_fm2cache_rd_rsp[0].data[111:104] = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hD}];
    samp_fm2cache_rd_rsp[0].data[119:112] = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hE}];
    samp_fm2cache_rd_rsp[0].data[127:120] = DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hF}];
end

//writing to D_MEM(Acts as FM):
always_comb begin
    NextDMem = DMem;
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h0}] = wr_enable_fm ? cache2fm_req_q3.data[7:0]     : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h0}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h1}] = wr_enable_fm ? cache2fm_req_q3.data[15:8]    : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h1}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h2}] = wr_enable_fm ? cache2fm_req_q3.data[23:16]   : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h2}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h3}] = wr_enable_fm ? cache2fm_req_q3.data[31:24]   : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h3}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h4}] = wr_enable_fm ? cache2fm_req_q3.data[39:32]   : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h4}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h5}] = wr_enable_fm ? cache2fm_req_q3.data[47:40]   : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h5}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h6}] = wr_enable_fm ? cache2fm_req_q3.data[55:48]   : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h6}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h7}] = wr_enable_fm ? cache2fm_req_q3.data[63:56]   : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h7}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h8}] = wr_enable_fm ? cache2fm_req_q3.data[71:64]   : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h8}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h9}] = wr_enable_fm ? cache2fm_req_q3.data[79:72]   : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'h9}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hA}] = wr_enable_fm ? cache2fm_req_q3.data[87:80]   : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hA}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hB}] = wr_enable_fm ? cache2fm_req_q3.data[95:88]   : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hB}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hC}] = wr_enable_fm ? cache2fm_req_q3.data[103:96]  : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hC}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hD}] = wr_enable_fm ? cache2fm_req_q3.data[111:104] : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hD}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hE}] = wr_enable_fm ? cache2fm_req_q3.data[119:112] : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hE}];
    NextDMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hF}] = wr_enable_fm ? cache2fm_req_q3.data[127:120] : DMem[{cache2fm_req_q3.address[MSB_TAG:LSB_SET],4'hF}];
end
//============================================


// One Cycle Latency on memory read - sample the id & Valid.
//`MAFIA_DFF(samp_fm2cache_rd_rsp[0].address   ,cache2fm_req_q3.address   , Clk)
//`MAFIA_DFF(samp_fm2cache_rd_rsp[0].valid     ,cache2fm_req_q3.valid  && (cache2fm_req_q3.opcode == FILL_REQ_OP)   , Clk)
// Shift register to add 10 cycle latecy on FM read.
assign samp_fm2cache_rd_rsp[0].address = cache2fm_req_q3.address;
assign samp_fm2cache_rd_rsp[0].valid   = cache2fm_req_q3.valid  && (cache2fm_req_q3.opcode == FILL_REQ_OP) ;
`MAFIA_DFF(samp_fm2cache_rd_rsp[9:1]       ,samp_fm2cache_rd_rsp[8:0] , Clk)
`MAFIA_DFF(fm2cache_rd_rsp                 ,samp_fm2cache_rd_rsp[9]   , Clk)



//============================================
//      reference model
//============================================
rv32i_ref
# (
    .I_MEM_LSB (I_MEM_OFFSET),
    .I_MEM_MSB (I_MEM_MSB),
    .D_MEM_LSB (D_MEM_OFFSET),
    .D_MEM_MSB (D_MEM_MSB)
)  rv32i_ref (
.clk    (Clk),
.rst    (Rst),
.run    (1'b1) // FIXME - set the RUN only when the big_core DUT is retiring the instruction.
               // every time the run is set, the next instruction is executed
);


endmodule //big_core_tb

