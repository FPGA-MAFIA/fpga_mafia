`include "macros.vh"

module mini_core_rrv_mem_wrap
import mini_core_rrv_pkg::*;
(
    input logic Clock,
    input logic Rst,
    input logic [31:0] PcQ100H,
    output logic [31:0] PreInstructionQ101H 

);



mem  #(
  .WORD_WIDTH(32),                //FIXME - Parametrize!!
  .ADRS_WIDTH(I_MEM_ADRS_MSB+1)   //FIXME - Parametrize!!
) i_mem  (
    .clock    (Clock),
    //Core interface (instruction fitch)
    .address_a  (PcQ100H[I_MEM_ADRS_MSB:2]),           
    .data_a     ('0),
    .wren_a     (1'b0),
    .byteena_a  (4'b0),
    .q_a        (PreInstructionQ101H),
    //fabric interface
    .address_b  (),
    .data_b     (),              
    .wren_b     (1'b0),                
    .byteena_b  (4'b0), 
    .q_b        ()              
    );







endmodule