`include "macros.vh"

module mini_core_rrv_mem_wrap
import mini_core_rrv_pkg::*;
(
    input logic Clock,
    input logic Rst,
    // instruction memory
    input logic [31:0] PcQ100H,
    output logic [31:0] PreInstructionQ101H,
    // data memory
    input logic [31:0] DMemWrDataQ101H,
    input logic [31:0] DMemAddressQ101H,
    input logic [3:0]  DMemByteEnQ101H,
    input logic DMemWrEnQ101H,
    input logic DMemRdEnQ101H,
    output logic [31:0] DMemRdRspQ102H

);



mem  #(
  .WORD_WIDTH(32),                //FIXME - Parametrize!!
  .ADRS_WIDTH(I_MEM_ADRS_MSB+1)   //FIXME - Parametrize!!
) i_mem  (
    .clock    (Clock),
    //Core interface (instruction fetch)
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

  logic [31:0] ShiftDMemWrDataQ101H;
  logic [3:0]  ShiftDMemByteEnQ101H;
  
  // data allignment when write to d_mem
  always_comb begin
    ShiftDMemWrDataQ101H = (DMemAddressQ101H[1:0] == 2'b01 ) ? { DMemWrDataQ101H[23:0],8'b0  } :
                           (DMemAddressQ101H[1:0] == 2'b10 ) ? { DMemWrDataQ101H[15:0],16'b0 } :
                           (DMemAddressQ101H[1:0] == 2'b11 ) ? { DMemWrDataQ101H[7:0] ,24'b0 } :
                                                             DMemWrDataQ101H;
    ShiftDMemByteEnQ101H = (DMemAddressQ101H[1:0] == 2'b01 ) ? { DMemByteEnQ101H[2:0],1'b0 } :
                           (DMemAddressQ101H[1:0] == 2'b10 ) ? { DMemByteEnQ101H[1:0],2'b0 } :
                           (DMemAddressQ101H[1:0] == 2'b11 ) ? { DMemByteEnQ101H[0]  ,3'b0 } :
                                                             DMemByteEnQ101H;
  end 


  // data allignment when read to d_mem
  logic [31:0] DMemAddressQ102H;
  logic [31:0] PreShiftDMemRdDataQ102H;
  `MAFIA_DFF(DMemAddressQ102H[1:0] , DMemAddressQ101H[1:0] , Clock)
  assign DMemRdRspQ102H =  (DMemAddressQ102H[1:0] == 2'b01) ? { 8'b0,PreShiftDMemRdDataQ102H[31:8] } : 
                           (DMemAddressQ102H[1:0] == 2'b10) ? {16'b0,PreShiftDMemRdDataQ102H[31:16]} : 
                           (DMemAddressQ102H[1:0] == 2'b11) ? {24'b0,PreShiftDMemRdDataQ102H[31:24]} : 
                                                                     PreShiftDMemRdDataQ102H         ; 

mem   
#(.WORD_WIDTH(32),//FIXME - Parametrize!!
  .ADRS_WIDTH(D_MEM_ADRS_MSB+1) //FIXME - Parametrize!!
) d_mem  (
    .clock    (Clock),
    .address_a  (DMemAddressQ101H[D_MEM_ADRS_MSB:2]),//FIXME - Parametrize!!
    .data_a     (ShiftDMemWrDataQ101H),
    .wren_a     (DMemWrEnQ101H),
    .byteena_a  (ShiftDMemByteEnQ101H),
    .q_a        (PreShiftDMemRdDataQ102H),
    //fabric interface
    .address_b  (),
    .data_b     (),              
    .wren_b     (1'b0),                
    .byteena_b  (4'b0000),
    .q_b        ()              
    );





endmodule