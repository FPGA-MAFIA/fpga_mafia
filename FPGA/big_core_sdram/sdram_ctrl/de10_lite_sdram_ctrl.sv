`include "macros.vh"

module de10_lite_sdram_ctrl
import sdram_ctrl_pkg::*; 
(
    input logic         MAX10_CLK1_50,
    input logic         Rst_N,

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
    // perform 16 executive writes and reads
    logic [3:0] ReadCounter,  NextReadCounter; 
    logic [3:0] WriteCounter, NextWriteCounter;

    //assign NextWriteCounter = (State != WRITE_TOP) ? 0 : WriteCounter + 1;
    //assign NextReadCounter  = (State != READ_TOP)  ? 0 : ReadCounter  + 1;
    assign NextWriteCounter = !Rst_N ? 0: (State == WRITE_TOP && !Busy) ? WriteCounter + 1 : WriteCounter;
    assign NextReadCounter  = !Rst_N ? 0: (State == READ_TOP && !Busy) ?  ReadCounter + 1 : ReadCounter;
	 
	 `MAFIA_DFF(WriteCounter, NextWriteCounter, Clock133)
    `MAFIA_DFF(ReadCounter, NextReadCounter, Clock133)

    `MAFIA_RST_VAL_DFF(State, NextState, Clock133, !Rst_N, IDLE_TOP)

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
                if(WriteCounter < 15) begin
                    Address            = 2*WriteCounter;
                    WriteReq           = 1;
                    DataOutToSdramCtrl = WriteCounter;
                    NextState          = WRITE_TOP;
                end
                else
                    NextState = READ_TOP;
            end
            READ_TOP: begin
                if(ReadCounter < 15) begin
                    Address   = 2*ReadCounter;
                    ReadReq   = 1;
                    NextState = READ_TOP;
                end
                else
                    NextState = DONE_TOP;
            end
            default: NextState = DONE_TOP;        
        endcase

    end

logic [15:0] DataFromSdram;
logic  Clock133;
logic Busy;

sdram_ctrl sdram_ctrl
(   
    .Clock(Clock133),
    .Rst(!Rst_N),
    .Busy(Busy),      // signal goes high in case of refresh or INIT states
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


pll	pll_inst (
	.areset (),
	.inclk0 (MAX10_CLK1_50),
	.c0 (Clock133),
	.locked ()
	);


	
	
 
endmodule

