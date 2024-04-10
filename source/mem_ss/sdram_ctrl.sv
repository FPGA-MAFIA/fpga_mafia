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
    output logic Busy, // signal goes high in case of refresh or INIT states
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
    logic PerformRefreshFlag;

     // State registers
    `MAFIA_RST_VAL_DFF(State, NextState, Clock, Rst, INIT)

    // Counters
    `MAFIA_RST_VAL_DFF(SdramCounters, NextSdramCounters, Clock, Rst, '0)



    // State machine
    always_comb begin :state_machine
        DRAM_ADDR   = 0;
        DRAM_BA     = 0;
        DRAM_CAS_N  = 0;
	    DRAM_CKE    = 1;
	    DRAM_CS_N   = 0;
	    DRAM_DQML   = 0;
        DRAM_RAS_N  = 0;
        DRAM_DQMH   = 0;
        DRAM_WE_N   = 0; 
        Busy        = 1;
        NextSdramCounters  = SdramCounters;
        PerformRefreshFlag = 1'b1;  
            case(State)
            INIT: begin
                    // 100us of NOP
                    if(SdramCounters.NopInitCounter < NopMaxDuration) begin  
                        {DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} = NOP_CMD;
                        NextSdramCounters.NextNopInitCounter = SdramCounters.NopInitCounter+1;   
                    end
                    // precharge all.
                    else if(SdramCounters.PrechargeCounter == 0) begin
                        {DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} = PRECHARGE_ALL_CMD;
                         DRAM_ADDR[10]       = 1'b1;
                        NextSdramCounters.NextPrechargeCounter = SdramCounters.PrechargeCounter+1;
                    end
                    else if(SdramCounters.PrechargeCounter < tRP) begin
                        {DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} = NOP_CMD;
                        NextSdramCounters.NextPrechargeCounter = SdramCounters.PrechargeCounter+1;
                    end
                    // refresh 8 times
                    else if((SdramCounters.RefreshInitCounter < TimesToRefreshWhenInit & PerformRefreshFlag)) begin
                        {DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} = AUTO_REFRESH_CMD;
                        PerformRefreshFlag = 1'b0;
                        NextSdramCounters.NextRefreshInitCounter = SdramCounters.RefreshInitCounter+1;
                    end
                    else if((SdramCounters.RefreshCounter < tRC) & (SdramCounters.RefreshInitCounter < TimesToRefreshWhenInit)) begin
                           {DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} = NOP_CMD;
                           if(SdramCounters.RefreshCounter == 8) begin   // FIXME - need to be refactored. in the eight cycle we make the last nop and goes back to auto refresh
                                NextSdramCounters.NextRefreshCounter = 0;
                                PerformRefreshFlag = 1'b1;
                           end
                           else begin
                                NextSdramCounters.NextRefreshCounter = SdramCounters.RefreshCounter+1;
                           end
 
                    end
                    // update mode register
                    else if(SdramCounters.ModeRegisterSetCounter == 0) begin
                        {DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} = MRS_CMD;
                         DRAM_ADDR = Set2Burst;
                        NextSdramCounters.NextModeRegisterSetCounter = SdramCounters.ModeRegisterSetCounter+1;
                    end
                    else if(SdramCounters.ModeRegisterSetCounter < tMRD) begin
                        {DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} = NOP_CMD;
                        NextSdramCounters.NextModeRegisterSetCounter = SdramCounters.ModeRegisterSetCounter+1;
                    end
                    else begin
                        NextState = IDLE;
                    end

            end  // end INIT 
            default: NextState = IDLE;
        endcase
    end :state_machine

  
    assign DRAM_CLK = Clock;
endmodule



