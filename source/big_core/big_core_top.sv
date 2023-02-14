//-----------------------------------------------------------------------------
// Title            :  
// Project          : fpga_mafia
//-----------------------------------------------------------------------------
// File             : big_core_top 
// Original Author  : Daniel Kaufman
// Code Owner       : 
// Adviser          : Amichai Ben-David
// Created          : 12/2022
//-----------------------------------------------------------------------------
// Description :
// This module serves as the top module of the core, memory and FPGA.
`include "macros.sv"

module big_core_top (
    input  logic        Clk,
    input  logic        Rst,
    
    // FPGA interface inputs              
    input  logic       Button_0, // CR_MEM
    input  logic       Button_1, // CR_MEM
    input  logic [9:0] Switch,   // CR_MEM
    // FPGA interface outputs
    output logic [7:0] SEG7_0,   // CR_MEM
    output logic [7:0] SEG7_1,   // CR_MEM
    output logic [7:0] SEG7_2,   // CR_MEM
    output logic [7:0] SEG7_3,   // CR_MEM
    output logic [7:0] SEG7_4,   // CR_MEM
    output logic [7:0] SEG7_5,   // CR_MEM
    output logic [9:0] LED,      // CR_MEM
    // VGA output
    output logic [3:0] RED,
    output logic [3:0] GREEN,
    output logic [3:0] BLUE,
    output logic       h_sync,
    output logic       v_sync          
);
import big_core_pkg::*;  

//=========================================
//     Core - Memory interface
//=========================================
// Instruction Memory
logic [31:0] PcQ100H;             // To I_MEM
logic [31:0] InstructionQ101H;    // I_MEM
logic [31:0] DMemWrDataQ103H;     // To D_MEM
logic [31:0] DMemAddressQ103H;    // To D_MEM
logic [3:0]  DMemByteEnQ103H;     // To D_MEM
logic        DMemWrEnQ103H;       // To D_MEM
logic        DMemRdEnQ103H;       // To D_MEM
logic [31:0] DMemRdRspQ104H;      // From D_MEM
//=========================================
// Instantiating the mafia_asap_5pl core
//=========================================
big_core big_core (
    .Clk                 (Clk),
    .Rst                 (Rst),
    .PcQ100H             (PcQ100H),          // To I_MEM
    .PreInstructionQ101H (InstructionQ101H), // From I_MEM
    .DMemWrDataQ103H     (DMemWrDataQ103H),  // To D_MEM
    .DMemAddressQ103H    (DMemAddressQ103H), // To D_MEM
    .DMemByteEnQ103H     (DMemByteEnQ103H),  // To D_MEM
    .DMemWrEnQ103H       (DMemWrEnQ103H),    // To D_MEM
    .DMemRdEnQ103H       (DMemRdEnQ103H),    // To D_MEM
    .DMemRdRspQ104H      (DMemRdRspQ104H)    // From D_MEM
);                                                            

//=========================================
// Instantiating the mafia_asap_5pl_mem_wrap memory
//=========================================
big_core_mem_wrap big_core_mem_wrap (
    .Clk              (Clk),     
    .Rst              (Rst),
    .PcQ100H          (PcQ100H),             // I_MEM
    .InstructionQ101H (InstructionQ101H),    // I_MEM
    .DMemWrDataQ103H  (DMemWrDataQ103H),     // D_MEM
    .DMemAddressQ103H (DMemAddressQ103H),    // D_MEM
    .DMemByteEnQ103H  (DMemByteEnQ103H),     // D_MEM
    .DMemWrEnQ103H    (DMemWrEnQ103H),       // D_MEM
    .DMemRdEnQ103H    (DMemRdEnQ103H),       // D_MEM
    .DMemRdRspQ104H   (DMemRdRspQ104H),      // D_MEM
    .Button_0         (Button_0),            // CR_MEM
    .Button_1         (Button_1),            // CR_MEM
    .Switch           (Switch),              // CR_MEM
    .SEG7_0           (SEG7_0),              // CR_MEM
    .SEG7_1           (SEG7_1),              // CR_MEM
    .SEG7_2           (SEG7_2),              // CR_MEM
    .SEG7_3           (SEG7_3),              // CR_MEM
    .SEG7_4           (SEG7_4),              // CR_MEM
    .SEG7_5           (SEG7_5),              // CR_MEM
    .LED              (LED),                 // CR_MEM
    .RED              (RED),                 // VGA_OUTPUT
    .GREEN            (GREEN),               // VGA_OUTPUT
    .BLUE             (BLUE),                // VGA_OUTPUT
    .h_sync           (h_sync),              // VGA_OUTPUT
    .v_sync           (v_sync)               // VGA_OUTPUT
);

endmodule // Module big_core_top