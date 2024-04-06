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
	output logic		    DRAM_LDQM,  // Lower Byte Data Mask: Masks lower byte during read/write operations
	output logic			DRAM_RAS_N, // Row Address Strobe (RAS) Negative: Initiates row access
	output logic		    DRAM_UDQM,  // Upper Byte Data Mask: Masks upper byte during read/write operations
	output logic		    DRAM_WE_N   // Write Enable Negative: Determines if the operation is a read(high) or write(low)
);

    sdram_states State, NextState;
    logic  [14:0] InitNopCounter, NextInitNopCounter;
    logic  [1:0]  tRPCounter, NexttRPCounter;
    logic  [3:0]  tRCCounter, NexttRCCounter;
    logic  [6:0]  InitRefreshCounter, NextInitRefreshCounter;
    logic  [3:0]  tMRDCounter, NexttMRDCounter;

    // Counters 
    always_ff@(posedge Clock) begin
        if(Rst) begin
            InitNopCounter     <= 0;
            tRPCounter         <= 0;
            tRCCounter         <= 0;
            InitRefreshCounter <= 0;
            tMRDCounter        <= 0;
        end
        else begin
            InitNopCounter     <= NextInitNopCounter;
            tRPCounter         <= NexttRPCounter;
            InitRefreshCounter <= NextInitRefreshCounter;
            tMRDCounter        <= NexttMRDCounter;
        end
    end

    assign NextInitNopCounter     = (State != INIT_NOP)                        ? 0 : InitNopCounter + 1; 
    assign NexttRPCounter         = (State == INIT_PALL || State == PRECHARGE) ? tRPCounter + 1  : 0;
    assign NextInitRefreshCounter = (State != INIT_REFRESH)                    ? 0 : InitRefreshCounter + 1; 
    assign NexttMRDCounter        = (State != MRS)                             ? 0 : tMRDCounter + 1;

    // State registers
    always_ff@(posedge Clock) begin : state_register
        if(Rst) begin
            State <= INIT_NOP;
        end
        else begin
            State <= NextState;
        end
    end

    // Next state logic
    always_comb begin : next_state_logic
        case(State)
            INIT_NOP: begin
                if(InitNopCounter <= InhibitMax) begin
                    NextState = INIT_NOP;
                end
                else begin   
                    NextState = INIT_PALL;
                end
            end
            INIT_PALL: begin
                if(tRPCounter <= tRPMax) begin
                    NextState = INIT_PALL;
                end
                else begin
                   NextState = INIT_REFRESH; 
                end
            end
            INIT_REFRESH: begin
                if(InitRefreshCounter <= InitRefreshMax) begin
                    NextState = INIT_REFRESH;
                end
                else begin
                    NextState = MRS; 
                end
            end
            MRS: begin
                 if(tMRDCounter <= tMRDMax) begin
                    NextState = MRS;
                end
                else begin
                    NextState = IDLE; 
            end
            // other states TODO

                
            end

        endcase
    end

    // outputs in each state
    always_comb begin: output_logic
        // Default values sets to NOP command
        // for other values please refer to page.9 in the documentation
        DRAM_ADDR   = 13'b0;
        DRAM_BA     = 2'b00;
        DRAM_CAS_N  = 1'b1;
        DRAM_CS_N   = 1'b0;
        DRAM_LDQM   = 1'b0;
        DRAM_RAS_N  = 1'b1;
        DRAM_UDQM   = 1'b0;
        DRAM_WE_N   = 1'b1;
        Busy        = 1'b0; 
        case(State)   
            INIT_PALL: begin
                DRAM_ADDR[10] = 1'b1;
                DRAM_CAS_N    = 1'b1;
                DRAM_RAS_N    = 1'b0;
                DRAM_WE_N     = 1'b0;
                Busy          = 1'b1;
            end
            INIT_REFRESH: begin
                DRAM_CAS_N  = 1'b0;
                DRAM_RAS_N  = 1'b0;
                DRAM_WE_N   = 1'b1;
                Busy        = 1'b1;
            end
            MRS: begin
                DRAM_CAS_N  = 1'b0;
                DRAM_RAS_N  = 1'b0;
                DRAM_WE_N   = 1'b0;
                DRAM_ADDR   = ModeRegAddrBitsSetSingle; // for details plese refer to documantation Page.26
                Busy        = 1'b1;
            end

            //other states TODO

            default: begin // NOP
                DRAM_CAS_N  = 1'b1;
                DRAM_RAS_N  = 1'b1;
                DRAM_WE_N   = 1'b1;
                Busy        = 1'b1;
            end
        endcase
    end



    //SDRAM interface
    assign DRAM_CKE    = 1'b1;  // TODO clock enable is always set. In the future consider adding some logic to save power 
    assign DRAM_CLK    = Clock;





endmodule



