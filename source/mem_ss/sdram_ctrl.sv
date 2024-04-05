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
	//////////// SDRAM //////////
	output logic    [12:0]  DRAM_ADDR,  // Address Bus: Multiplexed row/column address for accessing SDRAM
	output logic	[1:0]	DRAM_BA,    // Bank Address: Selects one of the internal banks within the SDRAM 
	output logic		   	DRAM_CAS_N, // Column Address Strobe (CAS) Negative: Initiates column access
	output logic	      	DRAM_CKE,   // Clock Enable: Enables or disables the clock to save power
	output logic	     	DRAM_CLK,   // Clock: System clock signal for SDRAM
	output logic     		DRAM_CS_N,  // Chip Select Negative: Enables the SDRAM chip when low
	inout 		    [15:0]	DRAM_DQ,    // Data Bus: Bidirectional bus for data transfer to/from SDRAM
	output logic		    DRAM_LDQM,  // Lower Byte Data Mask: Masks lower byte during read/write operations
	output logic			DRAM_RAS_N, // Row Address Strobe (RAS) Negative: Initiates row access
	output logic		    RAM_UDQM,   // Upper Byte Data Mask: Masks upper byte during read/write operations
	output logic		    DRAM_WE_N   // Write Enable Negative: Determines if the operation is a read(high) or write(low)
);



endmodule



