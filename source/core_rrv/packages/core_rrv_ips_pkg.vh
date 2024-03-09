//-----------------------------------------------------------------------------
// Title            : core_rrv_ips_pkg 
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : core_rrv_ips_pkg.sv
// Original Author  :  
// Code Owner       : Amichai Ben-David
// Created          : 12/2023
//-----------------------------------------------------------------------------
// Description :
// keyboar, uart and vga package
//-----------------------------------------------------------------------------


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

// Ascii code to scan code. // TODO include special characters
typedef enum logic [7:0] {
    ESC         = 8'h76,
    F1          = 8'h05,
    F2          = 8'h06,
    F3          = 8'h04,
    F4          = 8'h0C,
    F5          = 8'h03,
    F6          = 8'h0B,
    F7          = 8'h83,
    F8          = 8'h0A,
    F9          = 8'h01,
    F10         = 8'h09,
    F11         = 8'h78,
    F12         = 8'h07,
    TICK        = 8'h0E, // `
    ONE         = 8'h16, 
    TWO         = 8'h1E,
    THREE       = 8'h26,
    FOUR        = 8'h25,
    FIVE        = 8'h2E,
    SIX         = 8'h36,
    SEVEN       = 8'h3D,
    EIGHT       = 8'h3E,
    NINE        = 8'h46,
    ZERO        = 8'h45,
    HYPHEN      = 8'h4E, // -
    EQUAL       = 8'h55,
    BACKSPACE   = 8'h66, // =
    TAB         = 8'h0D,
    Q           = 8'h15,
    W           = 8'h1D,
    E           = 8'h24,
    R           = 8'h2D,
    T           = 8'h2C,
    Y            = 8'h35,
    U           = 8'h3C,
    I           = 8'h43,
    O           = 8'h44,
    P           = 8'h4D,
    LSBR        = 8'h54,  // left square bracket [
    RSBR        = 8'h5B,  // right square bracket ]
    BACKSLASH   = 8'h5D,   // \
    CAPSLOCK    = 8'h58,
    A           = 8'h1C,
    S           = 8'h1B,
    D           = 8'h23,
    F           = 8'h2B,
    G           = 8'h34,
    H           = 8'h33,
    J           = 8'h3B,
    K           = 8'h42,
    L           = 8'h4B,
    SEMICOLON   = 8'h4C,  // ;
    APOSTROPHE  = 8'h52,  // '
    ENTER       = 8'h5A,
    LSHIFT      = 8'h12,
    Z           = 8'h1A,
    X           = 8'h22,
    C           = 8'h21,
    V           = 8'h2A,
    B           = 8'h32,
    N           = 8'h31,
    M           = 8'h3A,
    COMMA       = 8'h41,  // ,
    DOT         = 8'h49,  // .
    SLASH       = 8'h4A,  // /
    RSHIFT      = 8'h59,  // right shift
    LCTRL       = 8'h14,  // left control
    LALT        = 8'h11,  // left alt
    SPACE       = 8'h29
} t_ascii_to_scan_code;

//-----------------------------------
//         uart structs 
//-----------------------------------
typedef enum logic [1:0] {
    UART_RD                = 2'b00 , 
    UART_RD_RSP            = 2'b01 ,
    UART_WR                = 2'b10 , 
    UART_WR_BCAST          = 2'b11 
} t_uart_opcode ;