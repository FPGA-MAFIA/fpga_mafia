`include "macros.vh"

module de10_lite_sdram_full
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

  logic [127:0] WriteData [0:7];  // write 128bit to 8 random places
    logic [31:0]   Addr     [0:7]; // strores addreses

    typedef enum {IDLE, ACTIVATION, SET_READ, READ,  SET_WRITE, WRITE, DONE} States;

    always_comb begin: fill_data 
        WriteData[0] = 128'h1111_2222_3333_4444_5555_6666_7777_8888;
        WriteData[1] = 128'h1000_2000_3000_4000_5000_6000_7000_8000;
        WriteData[2] = 128'h1230_1231_1232_1233_1234_1235_1236_1237;
        WriteData[3] = 128'h0321_1321_2321_3321_4321_5321_6321_7321;
        WriteData[4] = 128'habc1_abc2_abc3_abc4_abc5_abc6_abc7_abc8;
        WriteData[5] = 128'ha4cd_a5cd_a7cd_a8cd_a9cd_a0cd_a56d_a76d;
        WriteData[6] = 128'hffff_eeee_cccc_bbbb_aaaa_9999_1dce_4bac;
        WriteData[7] = 128'h2323_4534_4543_8798_6854_ab1d_ab2d_abcd;
    end 

    always_comb begin: address_bank_row_col
        Addr[0] = 32'b0000000_00_0000000000000_0000000000;  // Bank = 0, row = 0, col = 0
        Addr[1] = 32'b0000000_00_0000000000000_0000001000;  // Bank = 0, row = 0, col = 8
        Addr[2] = 32'b0000000_00_0000000000000_0000011000;  // Bank = 0, row = 0, col = 24
        Addr[3] = 32'b0000000_00_0000000000001_0000101000;  // Bank = 0, row = 1, col = 40
        Addr[4] = 32'b0000000_01_0000000000001_0000101000;  // Bank = 1, row = 1, col = 40
        Addr[5] = 32'b0000000_10_0000000000001_0000001000;  // Bank = 2, row = 1, col = 8
        Addr[6] = 32'b0000000_10_0000000000001_0000010000;  // Bank = 2, row = 1, col = 16
        Addr[7] = 32'b0000000_11_0000000000001_0000010000;  // Bank = 3, row = 1, col = 16;
    end
    
    logic [31:0] Address;
    logic        ReadReq, WriteReq;
    logic [15:0] DataOutToSdramCtrl;
    States       State, NextState; 
    
    // Read/Write index Counter
    // increments by 1 every read/write new operation
    logic [4:0] IndexCounter, NextIndexCounter;
    // increments by 1 evrey read/write to count 8 packets of 16bits
    logic [3:0] PacketCounter, NextPacketCounter; 
    // When read wait 3 cycles for activation
    logic [1:0]  WaitActivation, NextWaitActivation;

    `MAFIA_RST_DFF(IndexCounter, NextIndexCounter, Clock133, !Rst_N)
    `MAFIA_RST_DFF(PacketCounter, NextPacketCounter, Clock133, !Rst_N)
    `MAFIA_RST_DFF(WaitActivation, NextWaitActivation, Clock133, !Rst_N) 

    // state macro
    `MAFIA_RST_VAL_DFF(State, NextState, Clock133, !Rst_N, IDLE)

    always_comb begin :next_state_logic
        Address            = 0;
        ReadReq            = 0;
        WriteReq           = 0;
        DataOutToSdramCtrl = 0;
        NextState          = State;
        NextIndexCounter   = IndexCounter;
        NextWaitActivation = WaitActivation;
        NextPacketCounter  = PacketCounter;
        case(State)
            IDLE: begin
                if(Busy)
                    NextState = IDLE;
                else begin
                    if(IndexCounter < 8) begin
                        WriteReq  = 1;
                        NextState = ACTIVATION;
                    end
                    else if(IndexCounter < 16) begin
                        ReadReq   = 1;
                        NextState = ACTIVATION;
                    end
                    else
                        NextState = DONE;
                end
            end // idle
            ACTIVATION: begin
                Address  = Addr[IndexCounter[2:0]];
                NextWaitActivation = WaitActivation + 1;
                if(WaitActivation < 1) 
                    NextState = ACTIVATION;
                else begin
                    if(IndexCounter < 8) begin
                        NextWaitActivation = 0;
                        WriteReq           = 1;
                        NextState          = SET_WRITE;
                    end
                    else if(IndexCounter < 16) begin
                        NextWaitActivation = 0;
                        ReadReq            = 1;
                        NextState          = SET_READ;
                    end
                    else 
                        NextState = DONE;
                end
            end
            SET_WRITE: begin
                Address             = Addr[IndexCounter];
                DataOutToSdramCtrl  = WriteData[IndexCounter][16*PacketCounter +: 16];
                NextPacketCounter   = PacketCounter + 1;
                NextState           = WRITE;
            end
            WRITE: begin
                if(PacketCounter < 8) begin
                    Address             = Addr[IndexCounter];
                    DataOutToSdramCtrl  = WriteData[IndexCounter][16*PacketCounter +: 16];
                    NextPacketCounter   = PacketCounter + 1;
                    NextState           = WRITE;
                end
                else begin
                    NextIndexCounter  = IndexCounter + 1;
                    NextPacketCounter = 0;
                    NextState         = IDLE;
                end
            end
            SET_READ: begin
                Address             = Addr[IndexCounter[2:0]];
                NextPacketCounter   = PacketCounter + 1;
                NextState           = READ; 
            end
            READ: begin
                if(PacketCounter < 8) begin
                    Address             = Addr[IndexCounter[2:0]];
                    NextPacketCounter   = PacketCounter + 1;
                    NextState           = READ;
                end
                else begin
                    NextIndexCounter  = IndexCounter + 1;
                    NextPacketCounter = 0;
                    NextState         = IDLE;
                end
            end
            DONE    : NextState = DONE;
            default : NextState = IDLE;
        endcase
    end

logic [15:0] DataFromSdram;
logic  Clock133;
logic Busy;

    sdram_ctrl_bursts sdram_ctrl_bursts
(   
    .Clock(Clock133),
    .Rst(!Rst_N),
    .Busy(Busy),      // signal goes high in case of refresh or INIT states
    .Address(Address),  // bank: bits (25,24), rows: bits (23-11), cols: bits (10-1)
    .ReadReq(ReadReq),
    .WriteReq(WriteReq),
    .DataIn(DataOutToSdramCtrl),
    .DataOut(),

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

Pll	Pll_inst (
	.areset (),
	.inclk0 (MAX10_CLK1_50),
	.c0 (Clock133),
	.locked ()
	);


endmodule

