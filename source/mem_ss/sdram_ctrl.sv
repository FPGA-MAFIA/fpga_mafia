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
    input  logic        Clock,  
    input  logic        Rst,
    output logic        Busy,      // signal goes high in case of refresh or INIT states
    input  logic [31:0] Address,  // bank: bits (25,24), rows: bits (23-11), cols: bits (10-1)
    input  logic        ReadReq,
    input  logic        WriteReq,
    input  logic [15:0] DataIn,
    output logic [15:0] DataOut,

	//********************************
    //       SDRAM INTERFACE        
    //******************************** 
	output logic    [12:0]  DRAM_ADDR,  // Address Bus: Multiplexed row/column address for accessing SDRAM
	output logic	[1:0]	DRAM_BA,    // Bank Address: Selects one of the internal banks within the SDRAM 
	output logic		   	DRAM_CAS_N, // Column Address Strobe (CAS) Negative: Initiates column access
	output logic	      	DRAM_CKE,   // Clock Enable: Enables or disables the clock to save power
	output logic	     	DRAM_CLK,   // Clock: System clock signal for SDRAM
	output logic     		DRAM_CS_N,  // Chip Select Negative: Enables the SDRAM chip when low
	inout          [15:0]	DRAM_DQ,    // Data Bus: Bidirectional bus for data transfer to/from SDRAM
	output logic		    DRAM_DQML,  // Lower Byte Data Mask: Masks lower byte during read/write operations
	output logic			DRAM_RAS_N, // Row Address Strobe (RAS) Negative: Initiates row access
	output logic		    DRAM_DQMH,  // Upper Byte Data Mask: Masks upper byte during read/write operations
	output logic		    DRAM_WE_N   // Write Enable Negative: Determines if the operation is a read(high) or write(low)
);

    sdram_states             State, NextState;
    var sdram_counters       SdramCounters;
    var next_sdram_counters  NextSdramCounters;
    logic [2:0]              Command;
    
     // State registers
    `MAFIA_RST_VAL_DFF(State, NextState, Clock, Rst, RST)

    // Counters
    `MAFIA_RST_DFF(SdramCounters, NextSdramCounters, Clock, Rst)
    
    // Refresh couter logic
    logic        ResertRefreshCounter;
    logic        StartAutoRefresh;
    logic [10:0] RefreshCounter, NextRefreshCounter;
    // We dont want to trigger auto refresh when we in the initiale states
    assign ResertRefreshCounter = (RefreshCounter == RefreshRate || State == INIT_WAIT || State == INIT_PREA ||
                                  State == INIT_NOP || State == INIT_MODE_REG || INIT_REFRESH);  
    assign NextRefreshCounter   = (ResertRefreshCounter) ? 1'b0 : RefreshCounter + 1;
    assign StartAutoRefresh     = (RefreshCounter == RefreshRate);
    `MAFIA_RST_DFF(RefreshCounter, NextRefreshCounter, Clock, Rst)

    assign Busy = (State == IDLE) ? 1'b0: 1'b1;

   
    assign DataOut = (State == READ)  ? DRAM_DQ : 16'bz;
    assign DRAM_DQ = (State == WRITE) ? DataIn  : 16'bz;


    // State machine
    always_comb begin :state_machine
        DRAM_ADDR   = 0;
        DRAM_BA     = 0;
        Command     = NOP_CMD;  
        NextSdramCounters  = SdramCounters;
        NextState          = State;
            case(State)
            RST: 
                NextState = INIT_WAIT;
            // TODO - minus one was added to all counter to avoid extra muxes by adding some if's
            // its possible to leave it without minus one but then 1 extra nop will be added. Its not a big issue, it "wastes" few clocks
            // at the initialization state
            // We also could dec the counters by 1 in the sdram_ctrl_pkg but we choose to leave it that way
            // for more readability of the code
            INIT_WAIT: begin
                if (SdramCounters.NopInitCounter < NopMaxDuration-1) begin
                    Command = NOP_CMD;
                    NextSdramCounters.NopInitCounter = SdramCounters.NopInitCounter + 1;
                end
                else begin
                    NextState = INIT_PREA;
                    NextSdramCounters.NopInitCounter = 0;
                end
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
                else begin
                    NextState = INIT_REFRESH;
                    NextSdramCounters.PrechargeCounter = 0;
                end
            end
            INIT_REFRESH: begin
                if(SdramCounters.RefreshTrcCounter < 8) begin  // 7 = 8-1. We have to do refresh at least 8 times. //FIXME - there is an extra nop. its not a big issue!  
                    Command = AUTO_REFRESH_CMD;
                    NextSdramCounters.RefreshTrcCounter =  SdramCounters.RefreshTrcCounter + 1;
                    NextState = INIT_NOP;
                end
                else begin
                    NextState = INIT_MODE_REG;
                    NextSdramCounters.RefreshTrcCounter = 0;
                end
            end
            INIT_NOP: begin
                if(SdramCounters.RefreshInitCounter < tRC-1) begin 
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
                    DRAM_ADDR = SetSingleAccess;
                    NextSdramCounters.ModeRegisterSetCounter = SdramCounters.ModeRegisterSetCounter + 1;
                end
                else if(SdramCounters.ModeRegisterSetCounter < tMRD-1) begin
                    Command = NOP_CMD;
                    NextSdramCounters.ModeRegisterSetCounter = SdramCounters.ModeRegisterSetCounter + 1;
                end    
                else begin
                    NextSdramCounters.ModeRegisterSetCounter = 0;
                    NextState = IDLE;
                end
            end
            IDLE: begin
                if(StartAutoRefresh)
                    NextState = REFRESH;
                else if(ReadReq || WriteReq)
                    NextState = ACTIVATE;
                else
                    NextState = IDLE;
            end
            ACTIVATE: begin
                if(SdramCounters.ActivationCounter == 0) begin
                    Command = ACTIVATE_CMD;
                    DRAM_ADDR = Address[23:11];
                    DRAM_BA   = Address[25:24];
                    NextSdramCounters.ActivationCounter = SdramCounters.ActivationCounter + 1;
                end
                else if(SdramCounters.ActivationCounter < tRCD-1) begin
                    Command = NOP_CMD;
                    NextSdramCounters.ActivationCounter = SdramCounters.ActivationCounter + 1;
                end    
                else if(ReadReq) begin
                    NextSdramCounters.ActivationCounter = 0;
                    NextState = READ;
                end
                else begin
                    NextSdramCounters.ActivationCounter = 0;
                    NextState = WRITE;
                end
            end
            READ: begin
                if(SdramCounters.ReadCounter == 0) begin
                    Command = READ_CMD;
                    DRAM_ADDR = Address[10:1];
                    DRAM_BA   = Address[25:24];
                    NextSdramCounters.ReadCounter = SdramCounters.ReadCounter + 1;
                end
                else if(SdramCounters.ReadCounter < tCAC) begin  // note we dont subtruct 1 here. we need two nops
                    Command = NOP_CMD;
                    NextSdramCounters.ReadCounter = SdramCounters.ReadCounter + 1;
                end    
                else begin
                    NextSdramCounters.ReadCounter = 0;
                    NextState = PRECHARGE;
                end
            end
            WRITE: begin
                if(SdramCounters.WriteNopCounter == 0) begin
                    Command = WRITE_CMD;
                    DRAM_ADDR = Address[10:1];
                    DRAM_BA   = Address[25-24];
                    NextSdramCounters.WriteNopCounter = SdramCounters.WriteNopCounter + 1;
                end
                else if(SdramCounters.WriteNopCounter < tDPL) begin  // note we dont subtruct 1 here. we need two nops
                    Command = NOP_CMD;
                    NextSdramCounters.WriteNopCounter = SdramCounters.WriteNopCounter + 1;
                end    
                else begin
                    NextSdramCounters.WriteNopCounter = 0;
                    NextState = PRECHARGE;
                end
            end
            PRECHARGE: begin
                if(SdramCounters.PrechargeCounter == 0) begin
                    Command = PRECHARGE_ALL_CMD; // when DRAM_ADDR[10] = 0 its regular precharge
                    NextSdramCounters.PrechargeCounter = SdramCounters.PrechargeCounter + 1;
                end
                else if(SdramCounters.PrechargeCounter < tRP-1) begin
                    Command = NOP_CMD;
                    NextSdramCounters.PrechargeCounter = SdramCounters.PrechargeCounter + 1;
                end    
                else begin
                    NextSdramCounters.PrechargeCounter = 0;
                    NextState = IDLE;
                end
            end
            REFRESH: begin
                if(SdramCounters.RefreshTrcCounter == 0) begin  
                    Command = AUTO_REFRESH_CMD;
                    NextSdramCounters.RefreshTrcCounter =  SdramCounters.RefreshTrcCounter + 1;
                    NextState = REFRESH;
                end
                else if(SdramCounters.RefreshTrcCounter < tRC - 1) begin
                    NextState = REFRESH;
                    NextSdramCounters.RefreshTrcCounter =  SdramCounters.RefreshTrcCounter + 1;
                    Command = NOP_CMD;
                end
                else begin
                    NextSdramCounters.RefreshTrcCounter = 0;
                    NextState = IDLE;
                end
            end
            default: NextState = IDLE;
            endcase
    end :state_machine

  
    assign  DRAM_CLK                            = Clock;
    assign  {DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} = Command;
    assign 	DRAM_CKE    = 1;
	assign  DRAM_CS_N   = 0;
	assign  DRAM_DQML   = 0;
    assign  DRAM_DQMH   = 0;


endmodule



