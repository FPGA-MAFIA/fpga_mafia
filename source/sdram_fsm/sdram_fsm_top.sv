 
//-----------------------------------------------------------------------------
// Title            : SDRAM FSM UNIT
// Project          : Placeholder
//-----------------------------------------------------------------------------
// File             : sdram_fsm.sv
// Original Author  : Placeholder
// Code Owner       : Placeholder
// Created          : MM/YYYY
//-----------------------------------------------------------------------------
// Description :
// Design of asimple FSM that writes to sdram and reads the same values
// Written values are 7 segments
//-----------------------------------------------------------------------------

module sdram_fsm_top
import sdram_fsm_pkg::*; 
(
    input logic Clock,
    input logic nRst,
    input logic StartWr // start writing to memory

);

    // write to sdram interface
    logic WrRequest;   // write request - start writing to FIFO. //FIXME - only in real scenario we use fifo  
    logic [DATA_WIDTH-1:0] WriteData;
    logic [ADDR_WIDTH-1:0] WriteAddress;
     // read from  sdram interface
    logic RdRequest;   // read request - start reading from FIFO. //FIXME - only in real scenario we use fifo
    logic [DATA_WIDTH-1:0] ReadData;
    logic [ADDR_WIDTH-1:0] ReadAddress;
    logic Done;  // finish reading from memory

    
// ========================
// sdram fsm unit
// ========================
sdram_fsm sdram_fsm 
(
    .Clock(Clock),  
    .nRst(nRst),
    .StartWr(StartWr), // start writing to memory
    // write to sdram interface
    .WrRequest(WrRequest),    // write request - start writing to FIFO  
    .WriteData(WriteData),
    .WriteAddress(WriteAddress),
    // read from  sdram interface
    .RdRequest(RdRequest),   // read request - start reading from FIFO
    .ReadData(ReadData),
    .ReadAddress(ReadAddress),
    .Done(Done)  // finish reading from memory    
);

// ==========================
// Immitation of real SDRAM 
// ==========================
logic [15:0] DemoSdram    [63:0];       // that memory imitates small version of SDRAM. FIXME in real SDRAM the size is 32M and not 64. For simulation purposes only
// Immitation of real SDRAM
    always_ff@(posedge Clock) begin
        if(WrRequest)
            DemoSdram[WriteAddress[5:0]] <= WriteData; 
        else if(RdRequest)
            ReadData <= DemoSdram[ReadAddress[5:0]]; 
    end
endmodule

