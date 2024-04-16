 
//-----------------------------------------------------------------------------
// Title            : Package file for the sdram_fsm unit
// Project          : Placeholder
//-----------------------------------------------------------------------------
// File             : sdram_fsm_pkg.sv
// Original Author  : Placeholder
// Code Owner       : Placeholder
// Created          : MM/YYYY
//-----------------------------------------------------------------------------
// Description :
// the package file for the ALU unit
//-----------------------------------------------------------------------------
`ifndef sdram_fsm_PKG_SV
`define sdram_fsm_PKG_SV
package sdram_fsm_pkg;

// sdram in DE10-LITE board has 32Mx16 bytes
parameter DATA_WIDTH = 16; // width of each read/write transaction
parameter ADDR_WIDTH = 25; // width of address.  

typedef enum {   // state machine 
    IDLE, 
    WRITE, 
    READ, 
    DONE
} States;

endpackage
`endif
