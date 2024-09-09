//-----------------------------------------------------------------------------
// Title            : uart_tx package
// Project          : design of a uart transmiter
//-----------------------------------------------------------------------------
// File             : uart_tx_pkg.sv
// Original Author  : Morin Binyamin
// Code Owner       : Morin Binyamin
// Created          : 9/2024
//-----------------------------------------------------------------------------
// Description : state enumerators, structs and project constants
//-----------------------------------------------------------------------------

package uart_tx_pkg;

parameter N_TIMER = 4340; // 50Mhz/11520

typedef enum {
    IDLE, 
    SEND_START,
    CLEAR_TIMER,
    SEND_DATA, 
    TEST_EOC,    // end of 8 bits count 
    SHIFT_COUNT,
    SEND_STOP
} t_states;





endpackage