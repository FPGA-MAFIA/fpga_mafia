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

`include "macros.vh"

module big_core_cr_mem 
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

    // VGA info
    input  logic [9:0]  VGA_CounterX,
    input  logic [9:0]  VGA_CounterY,

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

t_cr cr;
t_cr next_cr;

// Data-Path signals
logic [31:0] pre_q;
logic [31:0] pre_q_b;


`MAFIA_DFF(cr, next_cr, Clk)
//==============================
// Memory Access
//------------------------------
// 1. Access CR_MEM for Wrote (STORE) and Reads (LOAD)
//==============================
always_comb begin
    next_cr = Rst ? '0 : cr;//defualt value
    if(wren) begin
        unique casez (address) // address holds the offset
            // ---- RW memory ----
            CR_SEG7_0       : next_cr.SEG7_0       = data[7:0];
            CR_SEG7_1       : next_cr.SEG7_1       = data[7:0];
            CR_SEG7_2       : next_cr.SEG7_2       = data[7:0];
            CR_SEG7_3       : next_cr.SEG7_3       = data[7:0];
            CR_SEG7_4       : next_cr.SEG7_4       = data[7:0];
            CR_SEG7_5       : next_cr.SEG7_5       = data[7:0];
            CR_LED          : next_cr.LED          = data[9:0];
            CR_KBD_SCANF_EN : next_cr.kbd_scanf_en = data[0];
            // ---- Other ----
            default   : /* Do nothing */;
        endcase
    end
    // ---- RO memory - VGA logic
    next_cr.VGA_CounterX = VGA_CounterX;
    next_cr.VGA_CounterY = VGA_CounterY;
    // ---- RO memory - Keyboard
    next_cr.kbd_data     = kbd_data_rd.kbd_data;
    next_cr.kbd_ready    = kbd_data_rd.kbd_ready;
    // ---- RO memory - writes from FPGA ----
    next_cr.Button_0     = fpga_in.Button_0;
    next_cr.Button_1     = fpga_in.Button_1;
    next_cr.Switch       = fpga_in.Switch;
    next_cr.Joystick_x   = fpga_in.Joystick_x;
    next_cr.Joystick_y   = fpga_in.Joystick_y;
end



// Reflects outputs to the FPGA - synchorus reflects
`MAFIA_DFF(fpga_out.SEG7_0 , cr.SEG7_0 , Clk)
`MAFIA_DFF(fpga_out.SEG7_1 , cr.SEG7_1 , Clk)
`MAFIA_DFF(fpga_out.SEG7_2 , cr.SEG7_2 , Clk)
`MAFIA_DFF(fpga_out.SEG7_3 , cr.SEG7_3 , Clk)
`MAFIA_DFF(fpga_out.SEG7_4 , cr.SEG7_4 , Clk)
`MAFIA_DFF(fpga_out.SEG7_5 , cr.SEG7_5 , Clk)
`MAFIA_DFF(fpga_out.LED    , cr.LED    , Clk)

// output to KBD
// logic to detect a read from Keyboard so we should pop:
assign kbd_ctrl.kbd_pop      = ((address   == CR_KBD_DATA) && rden ) ;
                               //FIXME currently cant read from fabric - need to support the rd_en
assign kbd_ctrl.kbd_scanf_en = cr.kbd_scanf_en;

// for debug & verification
t_kbd_cr kbd_cr;
assign kbd_cr.kbd_data    = cr.kbd_data;
assign kbd_cr.kbd_ready   = cr.kbd_ready;
assign kbd_cr.kbd_scanf_en= cr.kbd_scanf_en;




// This is the load
always_comb begin
    pre_q   = 32'b0;
    pre_q_b = 32'b0;
    if(rden) begin
        unique casez (address) // address holds the offset
            // ---- RW memory ----
            CR_SEG7_0       : pre_q = {24'b0 , cr.SEG7_0}     ; 
            CR_SEG7_1       : pre_q = {24'b0 , cr.SEG7_1}     ;
            CR_SEG7_2       : pre_q = {24'b0 , cr.SEG7_2}     ;
            CR_SEG7_3       : pre_q = {24'b0 , cr.SEG7_3}     ;
            CR_SEG7_4       : pre_q = {24'b0 , cr.SEG7_4}     ;
            CR_SEG7_5       : pre_q = {24'b0 , cr.SEG7_5}     ;
            CR_LED          : pre_q = {22'b0 , cr.LED}        ;
            CR_KBD_SCANF_EN : pre_q = {31'b0 , cr.kbd_scanf_en} ;
            // ---- RO memory ----
            CR_Button_0    : pre_q = {31'b0 , cr.Button_0}    ;
            CR_Button_1    : pre_q = {31'b0 , cr.Button_1}    ;
            CR_SWITCH      : pre_q = {22'b0 , cr.Switch}      ;
            CR_JOYSTICK_X  : pre_q = {20'b0 , cr.Joystick_x}  ;
            CR_JOYSTICK_Y  : pre_q = {20'b0 , cr.Joystick_y}  ;
            CR_KBD_READY   : pre_q = {31'b0 , cr.kbd_ready}   ;
            CR_KBD_DATA    : pre_q = {24'b0 , cr.kbd_data}    ;
            CR_VGA_CounterX: pre_q = {22'b0 , cr.VGA_CounterX};
            CR_VGA_CounterY: pre_q = {22'b0 , cr.VGA_CounterY};
            default        : pre_q = 32'b0                    ;
        endcase
    end
    
    //Fabric Read
    unique casez (address_b) // address holds the offset
        // ---- RW memory ----
        CR_SEG7_0      : pre_q_b = {24'b0 , cr.SEG7_0}   ; 
        CR_SEG7_1      : pre_q_b = {24'b0 , cr.SEG7_1}   ;
        CR_SEG7_2      : pre_q_b = {24'b0 , cr.SEG7_2}   ;
        CR_SEG7_3      : pre_q_b = {24'b0 , cr.SEG7_3}   ;
        CR_SEG7_4      : pre_q_b = {24'b0 , cr.SEG7_4}   ;
        CR_SEG7_5      : pre_q_b = {24'b0 , cr.SEG7_5}   ;
        CR_LED         : pre_q_b = {22'b0 , cr.LED}      ;
        CR_KBD_SCANF_EN: pre_q_b = {31'b0 , cr.kbd_scanf_en} ;
        // ---- RO memory ----
        CR_Button_0    : pre_q_b = {31'b0 , cr.Button_0}  ;
        CR_Button_1    : pre_q_b = {31'b0 , cr.Button_1}  ;
        CR_SWITCH      : pre_q_b = {22'b0 , cr.Switch}    ;
        CR_JOYSTICK_X  : pre_q_b = {20'b0 , cr.Joystick_x};
        CR_JOYSTICK_Y  : pre_q_b = {20'b0 , cr.Joystick_y};
        CR_KBD_READY   : pre_q_b = {31'b0 , cr.kbd_ready} ;
        CR_KBD_DATA    : pre_q_b = {24'b0 , cr.kbd_data}  ;
        CR_VGA_CounterX: pre_q_b = {22'b0 , cr.VGA_CounterX};
        CR_VGA_CounterY: pre_q_b = {22'b0 , cr.VGA_CounterY};
        default        : pre_q_b = 32'b0                    ;
    endcase
end


// Sample the data load - synchorus load
`MAFIA_DFF(q,   pre_q, Clk)
`MAFIA_DFF(q_b, pre_q_b, Clk)

endmodule // Module 