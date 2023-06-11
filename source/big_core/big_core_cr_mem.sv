//-----------------------------------------------------------------------------
// Title            : big_core_cr_mem
// Project          : fpga_mafia
//-----------------------------------------------------------------------------
// File             : big_core_cr_mem.sv
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Adviser          : 
// Created          : 3/2023
//-----------------------------------------------------------------------------
// Description :
// The CR memory module - Control Registers memory.
// contains Flop based memory for the Control Registers.
// The memory is accessed by the core and the FPGA.
// Some CR are read only from Core and write from FPGA. (SWITCH, BUTTON) 
// and some are read/write from core and READ only from FPGA (LED, SEG7)

`include "macros.sv"

module big_core_cr_mem 
import common_pkg::*;
(
    input  logic       Clk,
    input  logic       Rst,

    // Core interface
    input  logic [31:0] data,
    input  logic [31:0] address,
    input  logic        wren,
    input  logic        rden,
    output logic [31:0] q,

    // FPGA interface inputs
    input  logic       Button_0,
    input  logic       Button_1,
    input  logic [9:0] Switch,

    input  logic [31:0] address_b,
    input  logic [31:0] data_b,
    input  logic        wren_b,
    output logic [31:0] q_b,
    // FPGA interface outputs
    output t_fpga_out   fpga_out
);

// Memory CR objects (behavrial - not for FPGA/ASIC)
t_cr_ro cr_ro;
t_cr_rw cr_rw;
t_cr_ro cr_ro_next;
t_cr_rw cr_rw_next;

// Data-Path signals
logic [31:0] pre_q;
logic [31:0] pre_q_b;

//==============================
// Memory Access
//------------------------------
// 1. Access CR_MEM for Wrote (STORE) and Reads (LOAD)
//==============================
always_comb begin
    cr_ro_next = cr_ro;
    cr_rw_next = cr_rw; 
    if(wren) begin
        unique casez (address) // address holds the offset
            // ---- RW memory ----
            CR_SEG7_0   : cr_rw_next.SEG7_0         = data[7:0];
            CR_SEG7_1   : cr_rw_next.SEG7_1         = data[7:0];
            CR_SEG7_2   : cr_rw_next.SEG7_2         = data[7:0];
            CR_SEG7_3   : cr_rw_next.SEG7_3         = data[7:0];
            CR_SEG7_4   : cr_rw_next.SEG7_4         = data[7:0];
            CR_SEG7_5   : cr_rw_next.SEG7_5         = data[7:0];
            CR_LED      : cr_rw_next.LED            = data[9:0];
            // ---- Other ----
            default   : /* Do nothing */;
        endcase
    end
    // ---- RO memory - writes from FPGA ----
    cr_ro_next.Button_0 = Button_0;
    cr_ro_next.Button_1 = Button_1;
    cr_ro_next.Switch   = Switch;
end

`MAFIA_DFF(cr_rw, cr_rw_next, Clk)
`MAFIA_DFF(cr_ro, cr_ro_next, Clk)

// This is the load
always_comb begin
    pre_q   = 32'b0;
    pre_q_b = 32'b0;
    if(rden) begin
        unique casez (address) // address holds the offset
            // ---- RW memory ----
            CR_SEG7_0   : pre_q = {24'b0 , cr_rw.SEG7_0}   ; 
            CR_SEG7_1   : pre_q = {24'b0 , cr_rw.SEG7_1}   ;
            CR_SEG7_2   : pre_q = {24'b0 , cr_rw.SEG7_2}   ;
            CR_SEG7_3   : pre_q = {24'b0 , cr_rw.SEG7_3}   ;
            CR_SEG7_4   : pre_q = {24'b0 , cr_rw.SEG7_4}   ;
            CR_SEG7_5   : pre_q = {24'b0 , cr_rw.SEG7_5}   ;
            CR_LED      : pre_q = {22'b0 , cr_rw.LED}      ;
            // ---- RO memory ----
            CR_Button_0 : pre_q = {31'b0 , cr_ro_next.Button_0} ;
            CR_Button_1 : pre_q = {31'b0 , cr_ro_next.Button_1} ;
            CR_SWITCH   : pre_q = {22'b0 , cr_ro_next.Switch}   ;
            default     : pre_q = 32'b0                         ;
        endcase
    end
    
    //Fabric Read
    unique casez (address_b) // address holds the offset
        // ---- RW memory ----
        CR_SEG7_0   : pre_q_b = {24'b0 , cr_rw.SEG7_0}   ; 
        CR_SEG7_1   : pre_q_b = {24'b0 , cr_rw.SEG7_1}   ;
        CR_SEG7_2   : pre_q_b = {24'b0 , cr_rw.SEG7_2}   ;
        CR_SEG7_3   : pre_q_b = {24'b0 , cr_rw.SEG7_3}   ;
        CR_SEG7_4   : pre_q_b = {24'b0 , cr_rw.SEG7_4}   ;
        CR_SEG7_5   : pre_q_b = {24'b0 , cr_rw.SEG7_5}   ;
        CR_LED      : pre_q_b = {22'b0 , cr_rw.LED}      ;
        // ---- RO memory ----
        CR_Button_0 : pre_q_b = {31'b0 , cr_ro.Button_0} ;
        CR_Button_1 : pre_q_b = {31'b0 , cr_ro.Button_1} ;
        CR_SWITCH   : pre_q_b = {22'b0 , cr_ro.Switch}   ;
        default     : pre_q_b = 32'b0                         ;
    endcase

end

// Sample the data load - synchorus load
`MAFIA_DFF(q,   pre_q, Clk)
`MAFIA_DFF(q_b, pre_q_b, Clk)

// Reflects outputs to the FPGA - synchorus reflects
`MAFIA_DFF(fpga_out.SEG7_0 , cr_rw_next.SEG7_0 , Clk)
`MAFIA_DFF(fpga_out.SEG7_1 , cr_rw_next.SEG7_1 , Clk)
`MAFIA_DFF(fpga_out.SEG7_2 , cr_rw_next.SEG7_2 , Clk)
`MAFIA_DFF(fpga_out.SEG7_3 , cr_rw_next.SEG7_3 , Clk)
`MAFIA_DFF(fpga_out.SEG7_4 , cr_rw_next.SEG7_4 , Clk)
`MAFIA_DFF(fpga_out.SEG7_5 , cr_rw_next.SEG7_5 , Clk)
`MAFIA_DFF(fpga_out.LED    , cr_rw_next.LED    , Clk)

endmodule // Module rvc_asap_5pl_cr_mem