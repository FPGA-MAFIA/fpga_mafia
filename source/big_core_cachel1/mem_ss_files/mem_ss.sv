`include "macros.vh"

module mem_ss
import big_core_pkg::*;
import d_cache_param_pkg::*;
(
    input logic Clock,
    input logic Rst,
    //============================================
    //     i_mem
    //============================================
    input  logic        ReadyQ101H,
    input  logic [31:0] PcQ100H,             //cur_pc    ,
    output logic [31:0] PreInstructionQ101H, //instruction,
    //============================================
    //     d_mem_ss components: cache, vga, CR
    //============================================
    input var t_core2mem_req Core2DmemReqQ103H,
    output logic [31:0]      DMemRdRspQ105H, // From D_MEM
    output logic             DMemReady  , // From D_MEM
    //============================================
    //      keyboard interface
    //============================================
    input  var t_kbd_data_rd kbd_data_rd,
    output t_kbd_ctrl        kbd_ctrl,
    //============================================
    //      vga interface
    //============================================
    output logic        inDisplayArea,
    output t_vga_out    vga_out,         // VGA_OUTPUT
    //============================================
    // FM interface
    //============================================
    output  t_fm_req        cache2fm_req_q3, 
    input   var t_fm_rd_rsp fm2cache_rd_rsp,
    //============================================
    //      fpga interface
    //============================================             
    input  var t_fpga_in   fpga_in,  // CR_MEM
    output t_fpga_out      fpga_out      // CR_MEM 
);

//================================================================
//                 d_mem_ss module(L1 CACHE, VGA, CR)    
//================================================================

d_mem_ss d_mem_ss (
    .Clock              (Clock),
    .Rst                (Rst),
    .Core2DmemReqQ103H  (Core2DmemReqQ103H),
    .DMemRdRspQ105H     (DMemRdRspQ105H),
    .DMemReady          (DMemReady),          // back pressure  
    .inDisplayArea      (inDisplayArea),
    .vga_out            (vga_out),
    .kbd_data_rd        (kbd_data_rd),
    .kbd_ctrl           (kbd_ctrl),
    .fpga_in            (fpga_in),
    .fpga_out           (fpga_out),
    .cache2fm_req_q3(cache2fm_req_q3),
    .fm2cache_rd_rsp(fm2cache_rd_rsp)  
);

//================================================================
//                  imem module   
//================================================================
logic [31:0] InstructionQ101H;

i_mem_reissue i_mem_reissue
(
    .Clock(Clock), 
    .ReadyQ101H(ReadyQ101H),
    .InstructionQ101H(InstructionQ101H),
    .PreInstructionQ101H(PreInstructionQ101H)
);


mem  #(
  .WORD_WIDTH(32),                //FIXME - Parametrize!!
  .ADRS_WIDTH(I_MEM_ADRS_MSB+1)   
)
 i_mem  (
    .clock    (Clock),
    //Core interface (instruction fitch)
    .address_a  (PcQ100H[I_MEM_ADRS_MSB:2]),           
    .data_a     ('0),
    .wren_a     (1'b0),
    .byteena_a  (4'b0),
    .q_a        (InstructionQ101H),
    //fabric interface // TODO - integrate fabric
    .address_b  (),
    .data_b     (),              
    .wren_b     (),                
    .byteena_b  (4'b1111), 
    .q_b        ()              
    );

endmodule