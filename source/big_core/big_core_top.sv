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
`include "macros.vh"

module big_core_top 
import big_core_pkg::*;  
(
    input  logic        Clk,
    input  logic        Rst,
    input  t_tile_id    local_tile_id,
    input  logic        RstPc,
    output logic        out_for_pd,
    
    // FPGA interface inputs              
    input  var t_fpga_in   fpga_in,  // CR_MEM
    // Fabric interface
    input  logic            InFabricValidQ503H  ,
    input  var t_tile_trans InFabricQ503H       ,
    output logic            OutFabricValidQ505H ,
    output var t_tile_trans OutFabricQ505H      ,
    // inputs from Keyboard 
    input logic             kbd_clk, // Clock from keyboard
    input logic             data_in_kc, // Data from keyboard
    // FPGA interface outputs
    output t_fpga_out fpga_out,      // CR_MEM
    // VGA output
    output logic        inDisplayArea,
    output t_vga_out    vga_out  // VGA_OUTPUT          
);

t_kbd_ctrl      kbd_ctrl;
t_kbd_data_rd   kbd_data_rd;
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
    .RstPc               (RstPc),            // logic
    .out_for_pd          (out_for_pd),       // logic
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
    .local_tile_id    (local_tile_id),       //input  t_tile_id    local_tile_id,
    //
    .PcQ100H          (PcQ100H),             // I_MEM
    .InstructionQ101H (InstructionQ101H),    // I_MEM
    .DMemWrDataQ103H  (DMemWrDataQ103H),     // D_MEM
    .DMemAddressQ103H (DMemAddressQ103H),    // D_MEM
    .DMemByteEnQ103H  (DMemByteEnQ103H),     // D_MEM
    .DMemWrEnQ103H    (DMemWrEnQ103H),       // D_MEM
    .DMemRdEnQ103H    (DMemRdEnQ103H),       // D_MEM
    .DMemRdRspQ104H   (DMemRdRspQ104H),      // D_MEM
    // Fabric interface
    .InFabricValidQ503H (InFabricValidQ503H), //input  logic        ,
    .InFabricQ503H      (InFabricQ503H),      //input  t_tile_trans ,
    .OutFabricValidQ505H(OutFabricValidQ505H),//output logic        ,
    .OutFabricQ505H     (OutFabricQ505H),     //output t_tile_trans ,
    // Keyboard interface
    .kbd_data_rd  (kbd_data_rd ), //input  t_kbd_data_rd kbd_data_rd,
    .kbd_ctrl     (kbd_ctrl    ), //output t_kbd_ctrl    kbd_ctrl,
    //
    .fpga_in          (fpga_in),            // CR_MEM
    .fpga_out         (fpga_out),            // CR_MEM
    .inDisplayArea    (inDisplayArea),       // VGA_OUTPUT
    .vga_out          (vga_out)              // VGA_OUTPUT
);

big_core_kdb_controller big_core_kdb_controller  
(
    .kbd_clk       (kbd_clk    ), //input  logic       kbd_clk,
    .data_in_kc    (data_in_kc ), //input  logic       data_in_kc,

    .core_clk      (Clk    ), //input  logic       core_clk,
    .core_rst      (Rst    ), //input  logic       core_rst, 
    // Pop when the kbd_pop signal is high -> automatically set when core reads the kbd cr data
    .core_read_en  (kbd_ctrl.kbd_pop     ), //input  logic       core_read_en,
    // the pop signals from the fifo:
    .data_out_cc   (kbd_data_rd.kbd_data ), //output logic [7:0] data_out_cc, 
    .data_ready    (kbd_data_rd.kbd_ready), //output logic       data_ready,
    .valid_cc      (                     ), //output logic       valid_cc, 
    .error         (                     ), //output logic       error,
    // disable keyboard inputs when scanf is disabled
    .scanf_en      (kbd_ctrl.kbd_scanf_en)  //input  logic       scanf_en   
);



endmodule // Module big_core_top