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
import big_core_pkg::*;
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
    input  var t_fpga_in    fpga_in,
    

    input  logic [31:0] address_b,
    input  logic [31:0] data_b,
    input  logic        wren_b,
    output logic [31:0] q_b,
    // Keyboard interface
    input  var t_kbd_data_rd kbd_data_rd,
    output t_kbd_ctrl    kbd_ctrl,
    // FPGA interface outputs
    output t_fpga_out   fpga_out
);

// Memory CR objects (behavrial - not for FPGA/ASIC)
// t_cr_ro cr_ro;
// t_cr_rw cr_rw;
t_fpga_in  fpga_in_1, fpga_in_2;    // fpga_in     -> fpga_in_1  -> fpga_in_2
t_fpga_out fpga_out_1, fpga_out_2;  // fpga_out_2  -> fpga_out_1 -> fpga_out

// Data-Path signals
logic [31:0] pre_q;
logic [31:0] pre_q_b;

t_kbd_cr kbd_cr_next;
t_kbd_cr kbd_cr;
//==============================
// Memory Access
//------------------------------
// 1. Access CR_MEM for Wrote (STORE) and Reads (LOAD)
//==============================
always_comb begin
    // fpga_in_1  = fpga_in_2;
    fpga_out_2 = fpga_out_1; 
    kbd_cr_next.kbd_scanf_en =  kbd_cr.kbd_scanf_en;
    if(wren) begin
        unique casez (address) // address holds the offset
            // ---- RW memory ----
            CR_SEG7_0   : fpga_out_2.SEG7_0    = data[7:0];
            CR_SEG7_1   : fpga_out_2.SEG7_1    = data[7:0];
            CR_SEG7_2   : fpga_out_2.SEG7_2    = data[7:0];
            CR_SEG7_3   : fpga_out_2.SEG7_3    = data[7:0];
            CR_SEG7_4   : fpga_out_2.SEG7_4    = data[7:0];
            CR_SEG7_5   : fpga_out_2.SEG7_5    = data[7:0];
            CR_LED      : fpga_out_2.LED       = data[9:0];
            CR_KBD_SCANF_EN : kbd_cr_next.kbd_scanf_en = data[0];
            // ---- Other ----
            default   : /* Do nothing */;
        endcase
    end
    // ---- RO memory - writes from FPGA ----
    // fpga_in_next.Button_0 = Button_0;
end


// `MAFIA_DFF(fpga_out, pre_fpga_out, Clk)
// `MAFIA_DFF(fpga_in, fpga_in_next, Clk)

// Sample the data load - synchorus load
`MAFIA_DFF(q,   pre_q, Clk)
`MAFIA_DFF(q_b, pre_q_b, Clk)

// Reflects outputs to the FPGA - synchorus reflects
// fpga_in -> fpga_in_1 -> fpga_in_2
// fpga_out_2 -> fpga_out_1 -> fpga_out
`MAFIA_DFF(fpga_out_1   , fpga_out_2 , Clk)
`MAFIA_DFF(fpga_out     , fpga_out_1 , Clk)

`MAFIA_DFF(fpga_in_1    , fpga_in    , Clk)
`MAFIA_DFF(fpga_in_2    , fpga_in_1  , Clk)
// `MAFIA_DFF(fpga_out.SEG7_1 , fpga_out_next.SEG7_1 , Clk)

// This is the load
always_comb begin
    pre_q   = 32'b0;
    pre_q_b = 32'b0;
    if(rden) begin
        unique casez (address) // address holds the offset
            // ---- RW memory ----
            CR_SEG7_0       : pre_q = {24'b0 , fpga_out.SEG7_0}     ; 
            CR_SEG7_1       : pre_q = {24'b0 , fpga_out.SEG7_1}     ;
            CR_SEG7_2       : pre_q = {24'b0 , fpga_out.SEG7_2}     ;
            CR_SEG7_3       : pre_q = {24'b0 , fpga_out.SEG7_3}     ;
            CR_SEG7_4       : pre_q = {24'b0 , fpga_out.SEG7_4}     ;
            CR_SEG7_5       : pre_q = {24'b0 , fpga_out.SEG7_5}     ;
            CR_LED          : pre_q = {22'b0 , fpga_out.LED}        ;
            CR_KBD_SCANF_EN : pre_q = {31'b0 , kbd_cr.kbd_scanf_en} ;
            // ---- RO memory ----
            CR_Button_0   : pre_q = {31'b0 , fpga_in_2.Button_0}  ;
            CR_Button_1   : pre_q = {31'b0 , fpga_in_2.Button_1}  ;
            CR_SWITCH     : pre_q = {22'b0 , fpga_in_2.Switch}    ;
            CR_JOYSTICK_X : pre_q = {20'b0 , fpga_in_2.Joystick_x};
            CR_JOYSTICK_Y : pre_q = {20'b0 , fpga_in_2.Joystick_y};
            CR_KBD_READY  : pre_q = {31'b0 , kbd_cr.kbd_ready}  ;
            CR_KBD_DATA   : pre_q = {24'b0 , kbd_cr.kbd_data}   ;
            default       : pre_q = 32'b0                         ;
        endcase
    end
    
    //Fabric Read
    unique casez (address_b) // address holds the offset
        // ---- RW memory ----
        CR_SEG7_0     : pre_q_b = {24'b0 , fpga_out.SEG7_0}   ; 
        CR_SEG7_1     : pre_q_b = {24'b0 , fpga_out.SEG7_1}   ;
        CR_SEG7_2     : pre_q_b = {24'b0 , fpga_out.SEG7_2}   ;
        CR_SEG7_3     : pre_q_b = {24'b0 , fpga_out.SEG7_3}   ;
        CR_SEG7_4     : pre_q_b = {24'b0 , fpga_out.SEG7_4}   ;
        CR_SEG7_5     : pre_q_b = {24'b0 , fpga_out.SEG7_5}   ;
        CR_LED        : pre_q_b = {22'b0 , fpga_out.LED}      ;
        CR_KBD_SCANF_EN: pre_q_b = {31'b0 , kbd_cr.kbd_scanf_en} ;
        // ---- RO memory ----
        CR_Button_0   : pre_q_b = {31'b0 , fpga_in_2.Button_0} ;
        CR_Button_1   : pre_q_b = {31'b0 , fpga_in_2.Button_1} ;
        CR_SWITCH     : pre_q_b = {22'b0 , fpga_in_2.Switch}   ;
        CR_JOYSTICK_X : pre_q_b = {20'b0 , fpga_in_2.Joystick_x};
        CR_JOYSTICK_Y : pre_q_b = {20'b0 , fpga_in_2.Joystick_y};
        CR_KBD_READY  : pre_q_b = {31'b0 , kbd_cr.kbd_ready}  ;
        CR_KBD_DATA   : pre_q_b = {24'b0 , kbd_cr.kbd_data}   ;
        default       : pre_q_b = 32'b0                         ;
    endcase

end



// Storing into CR the Keyboard data 
assign kbd_cr_next.kbd_data  = kbd_data_rd.kbd_data;
assign kbd_cr_next.kbd_ready = kbd_data_rd.kbd_ready;
//assign kbd_cr_next.kbd_scanf_en -> This comes from core write request
`MAFIA_RST_DFF(kbd_cr, kbd_cr_next, Clk, Rst)


//==============================
// output to KBD
//==============================
// logic to detect a read from Keyboard so we should pop:
assign kbd_ctrl.kbd_pop      = ((address   == CR_KBD_DATA) && rden ) ;
                               //FIXME currently cant read from fabric - need to support the rd_en
assign kbd_ctrl.kbd_scanf_en = kbd_cr.kbd_scanf_en;

// `MAFIA_DFF(fpga_out.SEG7_2 , fpga_out_next.SEG7_2 , Clk)
// `MAFIA_DFF(fpga_out.SEG7_3 , fpga_out_next.SEG7_3 , Clk)
// `MAFIA_DFF(fpga_out.SEG7_4 , fpga_out_next.SEG7_4 , Clk)
// `MAFIA_DFF(fpga_out.SEG7_5 , fpga_out_next.SEG7_5 , Clk)
// `MAFIA_DFF(fpga_out.LED    , fpga_out_next.LED    , Clk)

endmodule // Module rvc_asap_5pl_cr_mem