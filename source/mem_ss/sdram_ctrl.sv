//-----------------------------------------------------------------------------
// Title            : SDRAM DE10 LITE Controller
// Project          : 
//-----------------------------------------------------------------------------
// File             : sdram_ctrl.sv
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Created          : 
//-----------------------------------------------------------------------------
// Description : sdram de10 lite board controller
// For more infomation please refer to de10-lite cd and search for documentation
//-----------------------------------------------------------------------------

`include "macros.vh"

module sdram_ctrl
import sdram_ctrl_pkg::*;
(   
    input logic Clock,  
    input logic Rst,
    output logic Busy,      // signal goes high in case of refresh or INIT states
    input logic [31:0] Address,
    input logic ReadReq,
    input logic WriteReq,
	//********************************
    //       SDRAM INTERFACE        
    //******************************** 
	output logic    [12:0]  DRAM_ADDR,  // Address Bus: Multiplexed row/column address for accessing SDRAM
	output logic	[1:0]	DRAM_BA,    // Bank Address: Selects one of the internal banks within the SDRAM 
	output logic		   	DRAM_CAS_N, // Column Address Strobe (CAS) Negative: Initiates column access
	output logic	      	DRAM_CKE,   // Clock Enable: Enables or disables the clock to save power
	output logic	     	DRAM_CLK,   // Clock: System clock signal for SDRAM
	output logic     		DRAM_CS_N,  // Chip Select Negative: Enables the SDRAM chip when low
	inout 		    [15:0]	DRAM_DQ,    // Data Bus: Bidirectional bus for data transfer to/from SDRAM
	output logic		    DRAM_DQML,  // Lower Byte Data Mask: Masks lower byte during read/write operations
	output logic			DRAM_RAS_N, // Row Address Strobe (RAS) Negative: Initiates row access
	output logic		    DRAM_DQMH,  // Upper Byte Data Mask: Masks upper byte during read/write operations
	output logic		    DRAM_WE_N   // Write Enable Negative: Determines if the operation is a read(high) or write(low)
);

    sdram_states State, NextState;
    var sdram_counters       SdramCounters;
    var next_sdram_counters  NextSdramCounters;
    logic [2:0]              Command;

     // State registers
    `MAFIA_RST_VAL_DFF(State, NextState, Clock, Rst, RST)

    // Counters
    `MAFIA_RST_VAL_DFF(SdramCounters, NextSdramCounters, Clock, Rst, '0)


    // State machine
    always_comb begin :state_machine
        DRAM_ADDR   = 0;
        DRAM_BA     = 0;
	    DRAM_CKE    = 1;
	    DRAM_CS_N   = 0;
	    DRAM_DQML   = 0;
        DRAM_DQMH   = 0;
        Command     = NOP_CMD;  
        Busy        = 1;
        NextSdramCounters  = SdramCounters;
        NextState          = State;
            case(State)
            RST: 
                NextState = INIT_WAIT;
            // TODO - minus one was added to all counter to avoid extra muxes by adding some if's
            // its possible to leave it without minus one but then 1 extra nop will be added. Its not that wrong, it "wastes" few clocks
            // at the initialization state
            // We also could dec the counters by 1 in the sdram_ctrl_pkg but we choose to leave it that way
            // for more readability of the code
            INIT_WAIT: begin
                if (SdramCounters.NopInitCounter < NopMaxDuration-1) begin
                    Command = NOP_CMD;
                    NextSdramCounters.NopInitCounter = SdramCounters.NopInitCounter + 1;
                end
                else 
                    NextState = INIT_PREA;
            end
            INIT_PREA: begin
                if(SdramCounters.PrechargeCounter == 0) begin
                    Command = PRECHARGE_ALL_CMD;
                    DRAM_ADDR[10]       = 1'b1;
                    NextSdramCounters.PrechargeCounter = SdramCounters.PrechargeCounter + 1;
                end
                else if(SdramCounters.PrechargeCounter < tRP-1) begin
                    Command = NOP_CMD;
                    NextSdramCounters.PrechargeCounter = SdramCounters.PrechargeCounter + 1;
                end    
                else
                    NextState = INIT_REFRESH;
            end
            INIT_REFRESH: begin
                if(SdramCounters.RefreshTrcCounter < tRC-1) begin  // FIXME - in the 8th time only when it return to the state than for 1 cycle we have extra nop. I leave it to avoid extra muxes, its not error!  
                    Command = AUTO_REFRESH_CMD;
                    NextSdramCounters.RefreshTrcCounter =  SdramCounters.RefreshTrcCounter + 1;
                    NextState = INIT_NOP;
                end
                else
                    NextState = INIT_MODE_REG;
            end
            INIT_NOP: begin
                if(SdramCounters.RefreshInitCounter < 7) begin  // 7=8-1
                    Command = NOP_CMD;
                    NextSdramCounters.RefreshInitCounter =  SdramCounters.RefreshInitCounter + 1;
                    NextState = INIT_NOP;
                end
                else begin 
                    NextSdramCounters.RefreshInitCounter = 0;
                    NextState = INIT_REFRESH;
                end
            end
            INIT_MODE_REG: begin
                if(SdramCounters.ModeRegisterSetCounter == 0) begin
                    Command = MRS_CMD;
                    DRAM_ADDR[10] = Set2Burst;
                    NextSdramCounters.ModeRegisterSetCounter = SdramCounters.ModeRegisterSetCounter + 1;
                end
                else if(SdramCounters.ModeRegisterSetCounter < tMRD-1) begin
                    Command = NOP_CMD;
                    NextSdramCounters.ModeRegisterSetCounter = SdramCounters.ModeRegisterSetCounter + 1;
                end    
                else
                    NextState = IDLE;
            end
            default: NextState = IDLE;
            endcase
    end :state_machine

  
    assign DRAM_CLK                            = Clock;
    assign {DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} = Command;

endmodule



