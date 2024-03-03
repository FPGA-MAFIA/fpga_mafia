//-----------------------------------------------------------------------------
// Title            : Serial to paraller PS2 data converter
// Project          : PS2 keyboard
//-----------------------------------------------------------------------------
// File             : 
// Original Author  : Amichai Ben-David
// Created          : 2/2024
//-----------------------------------------------------------------------------
// Description :
// Converts  serial data bits comes from PS2 into parallel 8 bits
//------------------------------------------------------------------------------
// Modification history :
//------------------------------------------------------------------------------

`include "macros.sv"

module ps2_kbd_sp_converter(
    input  logic       Rst,
    input  logic       KbdClk,
    input  logic       KbdSerialData,    
    output logic [7:0] ParallelData,   
    output logic       ParallelDataReady    
    );
    
    logic [3:0] BitCounter;         // counts package bits. Counts from 0 to 10
    logic [3:0] NextBitCounter;
    logic [7:0] NextParallelData;
    
    logic       DataBits;           // data bits are [8:1] bits afrom 11 bits transfered out of the KeyBoard
   
    assign DataBits          = (BitCounter >= 4'h1  &&  BitCounter <= 4'h8) ? 1'b1 : 1'b0;      
    assign NextBitCounter    = (BitCounter == 4'ha) ? 0 : BitCounter + 1;
    assign NextParallelData  = (DataBits) ? {KbdSerialData, ParallelData[7:1]} : ParallelData;    
         
    assign ParallelDataReady = (BitCounter == 4'ha) ? 1'b1 :  1'b0; // parallel data ready only after 11th bit
        
    `MAFIA_RST_DFF(BitCounter, NextBitCounter, KbdClk,  Rst);
    `MAFIA_EN_RST_DFF(ParallelData, NextParallelData, KbdClk, DataBits, Rst);
   
      
    
    
endmodule
