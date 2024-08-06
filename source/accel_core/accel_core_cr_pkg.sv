
package accel_core_cr_pkg;


// define CR memory sizes
parameter CR_MEM_OFFSET       = 'h00FE_0000;
parameter CR_MEM_REGION_FLOOR = CR_MEM_OFFSET;
parameter CR_MEM_REGION_ROOF  = 'h00FF_0000 - 1;

// Region bits
parameter LSB_REGION = 0;
parameter MSB_REGION = 23;

// CR Address Offsets
parameter CR_SEG7_0      = CR_MEM_OFFSET + 'h0  ; // RW 8 bit
parameter CR_SEG7_1      = CR_MEM_OFFSET + 'h4  ; // RW 8 bit
parameter CR_SEG7_2      = CR_MEM_OFFSET + 'h8  ; // RW 8 bit
parameter CR_SEG7_3      = CR_MEM_OFFSET + 'hC  ; // RW 8 bit
parameter CR_SEG7_4      = CR_MEM_OFFSET + 'h10 ; // RW 8 bit
parameter CR_SEG7_5      = CR_MEM_OFFSET + 'h14 ; // RW 8 bit
parameter CR_LED         = CR_MEM_OFFSET + 'h18 ; // RW 10 bit
parameter CR_Button_0    = CR_MEM_OFFSET + 'h1C ; // RO 1 bit
parameter CR_Button_1    = CR_MEM_OFFSET + 'h20 ; // RO 1 bit
parameter CR_SWITCH      = CR_MEM_OFFSET + 'h24 ; // RO 10 bit
parameter CR_JOYSTICK_X  = CR_MEM_OFFSET + 'h28 ; // RO 10 bit
parameter CR_JOYSTICK_Y  = CR_MEM_OFFSET + 'h2C ; // RO 10 bit

typedef struct packed {
    
    logic [7:0]   SEG7_0;
    logic [7:0]   SEG7_1;
    logic [7:0]   SEG7_2;
    logic [7:0]   SEG7_3;
    logic [7:0]   SEG7_4;
    logic [7:0]   SEG7_5;
    logic [9:0]   LED;
    //logic [7:0] kbd_data;
    //logic       kbd_ready;
    //logic       kbd_scanf_en;
} t_cr;

endpackage

