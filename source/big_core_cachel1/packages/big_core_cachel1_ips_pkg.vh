//-----------------------------------------------------------------------------
// Title            : big_core_cachel1_ips_pkg 
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : big_core_cachel1_ips_pkg.sv
// Original Author  :  
// Code Owner       : Amichai Ben-David
// Created          : 12/2023
//-----------------------------------------------------------------------------
// Description :
// keyboar, uart and vga package
//-----------------------------------------------------------------------------


parameter RELEASE_CODE    = 8'hF0;
parameter LEFT_SHIFT_CODE = 8'h12;
parameter ENTER_CODE      = 8'h5A;

//-----------------------------------
//         vga structs 
//-----------------------------------
typedef struct packed {
    logic [3:0] VGA_R;
    logic [3:0] VGA_G;
    logic [3:0] VGA_B;
    logic       VGA_VS;
    logic       VGA_HS;
} t_vga_out;

//-----------------------------------
//         keyboard structs 
//-----------------------------------
typedef struct packed {
    logic       start;
    logic [7:0] data;
    logic       odd_parity;
    logic       stop;
} t_kbd_word;

// Interface from kbd -> CR
typedef struct packed {
    logic [7:0] kbd_data;
    logic       kbd_ready;
} t_kbd_data_rd;

// Interface from CR -> kbd
typedef struct packed {
    logic       kbd_scanf_en;
    logic       kbd_pop;
} t_kbd_ctrl;

// Internal CR structure for kbd
typedef struct packed {
    logic [7:0] kbd_data;
    logic       kbd_ready;
    logic       kbd_scanf_en;
} t_kbd_cr;

//-----------------------------------
//         uart structs 
//-----------------------------------
typedef enum logic [1:0] {
    UART_RD                = 2'b00 , 
    UART_RD_RSP            = 2'b01 ,
    UART_WR                = 2'b10 , 
    UART_WR_BCAST          = 2'b11 
} t_uart_opcode ;