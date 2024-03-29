 
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
`ifndef sdram_fsm_SV
`define sdram_fsm_SV

`include "macros.vh"
module sdram_fsm 
import sdram_fsm_pkg::*;
(
    input logic Clock,  // 100Mhz from PLL
    input logic nRst,
    input logic StartWr, // start writing to memory
    // write to sdram interface
    output logic WrRequest,    // write request - start writing to FIFO  
    output logic [DATA_WIDTH-1:0] WriteData,
    output logic [ADDR_WIDTH-1:0] WriteAddress,
    // read from  sdram interface
    output logic RdRequest,   // read request - start reading from FIFO
    input  logic [DATA_WIDTH-1:0] ReadData,
    output logic [ADDR_WIDTH-1:0] ReadAddress,
    output logic Done  // finish reading from memory
    
);

    States state, next_state; // define stated 
    logic [6:0]  WriteFromMem [9:0];
    logic [6:0]  WriteToMem   [9:0];
    logic [3:0] Counter, Next_counter;      // responsible for writing only 10 times as the size of WriteFromMem 
    logic OnProgress;                      // when counter reaches 10 it indicates that 10 addresses where written/red

    // Initialization of WriteFromMeme with seven segment data (DE10 lite has a low active outputs)
    always_comb begin
        WriteFromMem[0] = 7'b1000000;  // 0x40
        WriteFromMem[1] = 7'b1111001;  // 0x79
        WriteFromMem[2] = 7'b0100100;  // 0x24
        WriteFromMem[3] = 7'b0110000;  // 0x30
        WriteFromMem[4] = 7'b0011001;  // 0x19
        WriteFromMem[5] = 7'b0010010;  // 0x12
        WriteFromMem[6] = 7'b0000010;  // 0x02
        WriteFromMem[7] = 7'b1111000;  // 0x78
        WriteFromMem[8] = 7'b0000000;  // 0x00
        WriteFromMem[9] = 7'b0010000;  // 0x10
    end
    

    // counter logic
    always_ff@(posedge Clock) begin
        if(!nRst)
            Counter <= 0;
        else 
            Counter <= Next_counter;
    end

    logic IncCounterEn;
    assign IncCounterEn = (state == WRITE & state != READ) || (state != WRITE & state == READ);
    assign Next_counter    = (Counter == 4'ha || !IncCounterEn) ? 4'h0 : Counter + 1;
    assign OnProgress      = !(Counter == 4'ha);

    // state register
    always_ff@(posedge Clock) begin
        if(!nRst)
            state <= IDLE;
        else begin
            state <= next_state;
        end

    end

    // next state logic
    always_comb begin
        WrRequest    = 0;
        WriteData    = 0;
        WriteAddress = 0;
        RdRequest    = 0;
        ReadAddress  = 0;
        Done         = 0;
        case(state)
            IDLE : begin
                if (StartWr) 
                    next_state = WRITE;
                else
                    next_state = IDLE;
            end
            WRITE: begin
                if (OnProgress) begin
                    WrRequest    = 1'b1;
                    WriteData    = {{9{1'b0}}, WriteFromMem[Counter]};  // width of data in real SDRAM is 16
                    WriteAddress = {{21{1'b0}}, Counter};               // with of address in real SDRAM is 25
                    next_state = WRITE;
                end
                else begin
                    WrRequest  = 1'b0;
                    next_state = READ;
                end
            end
            READ: begin
                 if (OnProgress) begin
                    RdRequest  = 1'b1;
                    ReadAddress = {{21{1'b0}}, Counter};
                    next_state = READ;
                 end
                   else begin
                    next_state = DONE;
                    RdRequest  = 1'b0;
                   end
                end
            DONE: begin
                Done         = 1'b1;
                next_state   = DONE;
            end
            default: next_state = IDLE;
        endcase

        
    end

endmodule

`endif
