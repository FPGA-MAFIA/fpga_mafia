`include "macros.vh"

module sdram_top_bursts
import sdram_ctrl_pkg::*; 
(
    input logic         Clock,
    input logic         Rst,
    input logic         Busy,

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


    sdram_top_states State, NextState;
    // perform 4 writes and reads in bursts
    logic [1:0] ReadCounter,  NextReadCounter; 
    logic [1:0] WriteCounter, NextWriteCounter;

    assign NextWriteCounter = (State != WRITE_TOP) ? 0 : WriteCounter + 1;
    assign NextReadCounter  = (State != READ_TOP)  ? 0 : ReadCounter  + 1;
    
    `MAFIA_DFF(WriteCounter, NextWriteCounter, Clock)
    `MAFIA_DFF(ReadCounter, NextReadCounter, Clock)

    `MAFIA_RST_VAL_DFF(State, NextState, Clock, Rst, IDLE_TOP)

    logic [31:0] Address;
    logic [15:0] DataOutToSdramCtrl;
    logic ReadReq, WriteReq;

    always_comb begin
        Address            = 0;
        DataOutToSdramCtrl = 0;
        ReadReq            = 0;
        WriteReq           = 0;
        NextState          = State;
        case(State) 
            IDLE_TOP: begin
                if(!Busy)
                    NextState = WRITE_TOP;
                else    
                    NextState = IDLE_TOP;        
            end
            WRITE_TOP: begin
                if(WriteCounter <= 3) begin
                    Address            = 8*WriteCounter;  // each write must be multipkication of 8
                    WriteReq           = 1;
                    DataOutToSdramCtrl = WriteCounter;
                    NextState          = WRITE_TOP;
                end
                else
                    NextState = READ_TOP;
            end
            READ_TOP: begin
                if(ReadCounter <=3) begin
                    Address   = 8*ReadCounter;   // each read must be multipkication of 8
                    ReadReq   = 1;
                    NextState = READ_TOP;
                end
                else
                    NextState = DONE_TOP;
            end
            DONE_TOP: 
                NextState = DONE_TOP;
            default: NextState = DONE_TOP;        
        endcase

    end

logic [15:0] DataFromSdram;

sdram_ctrl_bursts sdram_ctrl_bursts
(   
    .Clock(Clock),  
    .Rst(Rst),
    .Busy(),      // signal goes high in case of refresh or INIT states
    .Address(Address),  // bank: bits (25,24), rows: bits (23-11), cols: bits (10-1)
    .ReadReq(ReadReq),
    .WriteReq(WriteReq),
    .DataIn(DataOutToSdramCtrl),
    .DataOut(DataFromSdram),

	//********************************
    //       SDRAM INTERFACE        
    //******************************** 
	.DRAM_ADDR(DRAM_ADDR),  
	.DRAM_BA(DRAM_BA),    
	.DRAM_CAS_N(DRAM_CAS_N), 
	.DRAM_CKE(DRAM_CKE),   
	.DRAM_CLK(DRAM_CLK),   
	.DRAM_CS_N(DRAM_CS_N),  
	.DRAM_DQ(DRAM_DQ),    
	.DRAM_DQML(DRAM_DQML),  
	.DRAM_RAS_N(DRAM_RAS_N), 
	.DRAM_DQMH(DRAM_DQMH),  
	.DRAM_WE_N(DRAM_WE_N)   
);

endmodule

