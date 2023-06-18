`include "macros.sv"

module mem_ss_tb;
import mem_ss_param_pkg::*;  //FIXME: what about i_cache_param_pkg

string test_name;
logic    clk;
logic    rst;
logic imem_ready;
logic dmem_ready;
t_req    dmem_core2cache_req;
t_req    imem_core2cache_req;
t_rd_rsp imem_cache2core_rsp;
t_rd_rsp dmem_cache2core_rsp;
//create clock
//==================
//      clk Gen
//==================
initial begin: clock_gen
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end
end// clock_gen

`include "mem_ss_tasks.vh"
`include "mem_ss_trk.vh"
initial begin : start_test
if ($value$plusargs ("STRING=%s", test_name)) begin
    $display("STRING value %s", test_name);
end
$display("================\n     START\n================\n");
        rst= 1'b1;
        dmem_core2cache_req = '0;
        imem_core2cache_req = '0;
//exit reset
delay(80);  rst= 1'b0;
$display("=========================");
$display("====== Reset Done =======");
$display("=========================\n");
//start test
$display("=========================");
$display("====== start test =======");
$display("=========================\n");
if(test_name == "alive") begin
`include "alive.sv"
end else begin
    $display("\n\n=============================================");
    $display("ERROR: Test \'%s\' not found", test_name);
    $display("=============================================");
    $error("ERROR: Test \'%s\' not found", test_name);
    delay(80); $finish;
    $finish;
end
$display("\n\n================\n     Done\n================\n");
delay(80);
eot("END-OF-TEST: TIME OUT!");
end// initial

t_sram_rd_rsp cl_rsp_from_sram;
t_fm_req    cl_req_to_sram;
//create reset

mem_ss mem_ss (
.clk                (clk),                  // input logic clock,
.rst                (rst),                  // input logic rst,
.imem_core2cache_req(imem_core2cache_req),  // input  t_req    imem_core2cache_req,
.imem_ready         (imem_ready),                     // output logic    imem_ready,
.imem_cache2core_rsp(imem_cache2core_rsp),                     // output t_rd_rsp imem_cache2core_rsp,
.dmem_core2cache_req(dmem_core2cache_req),  // input  t_req    dmem_core2cache_req,
.dmem_ready         (dmem_ready),                     // output logic    dmem_ready,
.dmem_cache2core_rsp(dmem_cache2core_rsp),                     // output t_rd_rsp dmem_cache2core_rsp,
.cl_req_to_sram     (cl_req_to_sram),       // output t_fm_req    cl_req_to_sram,
.cl_rsp_from_sram   (cl_rsp_from_sram)      // input  t_sram_rd_rsp cl_rsp_from_sram
);


array  #(
    .WORD_WIDTH     (CL_WIDTH),
    .ADRS_WIDTH     (SET_ADRS_WIDTH + TAG_WIDTH)
) far_memory_array (
    .clk            (clk),                                     //input
    .rst            (rst),                                     //input
    //write interface
    .wr_en          (cl_req_to_sram.valid && (cl_req_to_sram.opcode == DIRTY_EVICT_OP)),                   //input
    .wr_address     (cl_req_to_sram.address[MSB_TAG:LSB_SET]),//input
    .wr_data        (cl_req_to_sram.data),                    //input
    //read interface
    .rd_address     (cl_req_to_sram.address[MSB_TAG:LSB_SET]),//input
    .q              (cl_rsp_from_sram.data)                   //output  
);
t_fm_req sample_cl_req_to_sram;
`MAFIA_DFF(sample_cl_req_to_sram  ,cl_req_to_sram   , clk)
assign cl_rsp_from_sram.valid = sample_cl_req_to_sram.valid;
assign cl_rsp_from_sram.address = sample_cl_req_to_sram.address;

   

endmodule 