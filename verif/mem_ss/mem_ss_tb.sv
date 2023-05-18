module mem_ss_tb;

//create clock
//create reset



mem_ss mem_ss (
.clock              (clock),//    input logic clock,
.rst                (rst),  //    input logic rst,
.imem_core2cache_req('0),   //    input  t_req    imem_core2cache_req,
.imem_stall         (),     //    output logic    imem_stall,
.imem_cache2core_rsp(),     //    output t_rd_rsp imem_cache2core_rsp,
.dmem_core2cache_req('0),   //    input  t_req    dmem_core2cache_req,
.dmem_stall         (),     //    output logic    dmem_stall,
.dmem_cache2core_rsp()      //    output t_rd_rsp dmem_cache2core_rsp,
);



endmodule 