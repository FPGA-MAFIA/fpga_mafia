#ifndef GRAPHIC_VGA_H  // Check if GRAPHIC_VGA_H is not defined
#define GRAPHIC_VGA_H  // Define GRAPHIC_VGA_H


/* VGA defines */
#define VGA_MEM_SIZE_BYTES 38400
#define VGA_MEM_SIZE_WORDS 9600
#define LINE               320
#define BYTES              4
#define COLUMN             80 /* COLUMN between 0 - 79 (80x60) */
#define ROWS               60 /* ROWS between 0 - 59 (80x60) */
#define VGA_PTR(PTR,OFF)   PTR    = (volatile int *) (VGA_MEM_BASE + OFF)
#define WRITE_REG(REG,VAL) (*REG) = VAL
#define READ_REG(VAL,REG)  VAL    = (*REG)
#define VGA_MEM ((volatile char *) (VGA_MEM_BASE))

/* ASCII Values */
#define SPACE_TOP    0x0                         
#define SPACE_BOTTOM 0x0                         
#define COMMA_TOP    0x00000000                  
#define COMMA_BOTTOM 0x061E1818                  
#define UNDER_SCORE_TOP    0x00000000
#define UNDER_SCORE_BOTTOM 0x007E0000
#define DASH_TOP     0x00000000 
#define DASH_BOTTOM  0x0000003C
#define POINT_TOP    0x00000000                  
#define POINT_BOTTOM 0x00181800                  
#define ZERO_TOP     0x52623C00                  
#define ZERO_BOTTOM  0x003C464A                  
#define ONE_TOP      0x1A1C1800                  
#define ONE_BOTTOM   0x007E1818                  
#define TWO_TOP      0x40423C00                  
#define TWO_BOTTOM   0x007E023C                  
#define THREE_TOP    0x40423C00                  
#define THREE_BOTTOM 0x003C4238                  
#define FOUR_TOP     0x24283000                  
#define FOUR_BOTTOM  0x0020207E                  
#define FIVE_TOP     0x3E027E00                  
#define FIVE_BOTTOM  0x003C4240                  
#define SIX_TOP      0x02423C00                  
#define SIX_BOTTOM   0x003C423E                  
#define SEVEN_TOP    0x30407E00                  
#define SEVEN_BOTTOM 0x00080808                  
#define EIGHT_TOP    0x42423C00                  
#define EIGHT_BOTTOM 0x003C423C                  
#define NINE_TOP     0x42423C00                  
#define NINE_BOTTOM  0x003E407C
#define COLON_TOP    0x00100000
#define COLON_BOTTOM 0x00001000                 
#define A_TOP        0x663C1800  
#define A_BOTTOM     0x00667E66                  
// 0x00 -> 00000000 -> ________
// 0x18 -> 00011000 -> ___XX___
// 0x3C -> 00111100 -> __XXXX__
// 0x66 -> 01100110 -> _XX__XX_
// 0x66 -> 01100110 -> _XX__XX_
// 0x7E -> 01111110 -> _XXXXXX_
// 0x66 -> 01100110 -> _XX__XX_
// 0x00 -> 00000000 -> ________
#define B_TOP        0x3E221E00                  
#define B_BOTTOM     0x001E223E                  
// 0x00 -> 00000000 -> ________
// 0x1E -> 00011110 -> ___XXXX_
// 0x22 -> 00100010 -> __X___X_
// 0x3E -> 00111110 -> __XXXXX_
// 0x3E -> 00111110 -> __XXXXX_
// 0x22 -> 00100010 -> __X___X_
// 0x1E -> 00011110 -> ___XXXX_
// 0x00 -> 00000000 -> ________

#define C_TOP        0x023E3C00                  
#define C_BOTTOM     0x003C3E02                  
#define D_TOP        0x223E1E00                  
#define D_BOTTOM     0x001E3E22                  
#define E_TOP        0x06067E00                  
#define E_BOTTOM     0x007E067E                  
#define F_TOP        0x06067E00                  
#define F_BOTTOM     0x0006067E                  
#define G_TOP        0x023E3C00                  
#define G_BOTTOM     0x003C223A                  
#define H_TOP        0x66666600                  
#define H_BOTTOM     0x0066667E                  
#define I_TOP        0x18187E00                  
#define I_BOTTOM     0x007E1818                  
#define J_TOP        0x60606000                  
#define J_BOTTOM     0x007C6666                  
#define K_TOP        0x3E664600                  
#define K_BOTTOM     0x0046663E                  
#define L_TOP        0x06060600                  
#define L_BOTTOM     0x007E0606                  
#define M_TOP        0x5A664200                  
#define M_BOTTOM     0x0042425A                  
#define N_TOP        0x6E666200                  
#define N_BOTTOM     0x00466676                  
#define O_TOP        0x66663C00                  
#define O_BOTTOM     0x003C6666                  
#define P_TOP        0x66663E00                  
#define P_BOTTOM     0x0006063E                  
#define Q_TOP        0x42423C00                  
#define Q_BOTTOM     0x007C6252                  
#define R_TOP        0x66663E00                  
#define R_BOTTOM     0x0066663E                  
#define S_TOP        0x1E067C00                  
#define S_BOTTOM     0x003E6078                  
#define T_TOP        0x18187E00                  
#define T_BOTTOM     0x00181818                  
#define U_TOP        0x66666600                  
#define U_BOTTOM     0x003C7E66                  
#define V_TOP        0x66666600                  
#define V_BOTTOM     0x00183C66                  
#define W_TOP        0x42424200                  
#define W_BOTTOM     0x00427E5A                  
#define X_TOP        0x3C666600                  
#define X_BOTTOM     0x0066663C                  
#define Y_TOP        0x3C666600                  
#define Y_BOTTOM     0x00181818                  
#define Z_TOP        0x10207E00                  
#define Z_BOTTOM     0x007E0408
#define a_top        0x78403800
#define a_bottom     0x0000B844
#define b_top        0x00000000
#define b_bottom     0x00000000
#define c_top        0x00000000
#define c_bottom     0x00000000
#define d_top        0x00000000
#define d_bottom     0x00000000
#define e_top        0x00000000
#define e_bottom     0x00000000
#define f_top        0x00000000
#define f_bottom     0x00000000
#define g_top        0x00000000
#define g_bottom     0x00000000
#define h_top        0x00000000
#define h_bottom     0x00000000
#define i_top        0x00000000
#define i_bottom     0x00000000
#define j_top        0x00000000
#define j_bottom     0x00000000
#define k_top        0x14240404
#define k_bottom     0x0000340C
#define l_top        0x10101030
#define l_bottom     0x00003810
#define m_top        0xB64A0000
#define m_bottom     0x00009292
#define n_top        0x4C340000
#define n_bottom     0x00004444
#define o_top        0x423C0000
#define o_bottom     0x00003C42
#define p_top        0x4C340000
#define p_bottom     0x0404344C
#define q_top        0x64580000
#define q_bottom     0x40C05864
#define r_top        0x4C340000
#define r_bottom     0x00000404
#define s_top        0x08300000
#define s_bottom     0x00182010
#define t_top        0x38101000
#define t_bottom     0x00305010
#define u_top        0x44440000
#define u_bottom     0x00005864
#define v_top        0x42420000
#define v_bottom     0x00001824
#define w_top        0x81810000
#define w_bottom     0x0000663A
#define x_top        0x48840000
#define x_bottom     0x0000CC30
#define y_top        0x48480000
#define y_bottom     0x38404070
#define z_top        0x20780000
#define z_bottom     0x00007810

#define LESS_THAN_TOP     0x08100000 //
#define LESS_THAN_BOTTOM  0x00100804 //

#define GREATER_THAN_TOP    0x10080000 //
#define GREATER_THAN_BOTTOM 0x00081020 //

#define QUESTION_MARK_TOP    0x20241800 //
#define QUESTION_MARK_BOTTOM 0x00100010 //
/* ANIME Values */
#define WALK_MAN_TOP_0    0x7c381030
#define WALK_MAN_BOTTOM_0 0x828448ba             
#define WALK_MAN_TOP_1    0x38381030             
#define WALK_MAN_BOTTOM_1 0x4448ac78             
#define WALK_MAN_TOP_2    0x38381030             
#define WALK_MAN_BOTTOM_2 0x10282878             
#define WALK_MAN_TOP_3    0x7c381030             
#define WALK_MAN_BOTTOM_3 0x281038ba             
#define WALK_MAN_TOP_4    0x38381030             
#define WALK_MAN_BOTTOM_4 0x4848387c    
#define CLEAR_TOP         0x0             
#define CLEAR_BOTTOM      0x0           

/* ASCII tables */
unsigned int ASCII_TOP[127]   = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,SPACE_TOP,0,
                                0,0,0,0,0,0,0,0,0,0,COMMA_TOP,DASH_TOP,POINT_TOP,0,ZERO_TOP,ONE_TOP,TWO_TOP,
                                THREE_TOP,FOUR_TOP,FIVE_TOP,SIX_TOP,SEVEN_TOP,EIGHT_TOP,NINE_TOP,COLON_TOP,0,LESS_THAN_TOP,0,GREATER_THAN_TOP,QUESTION_MARK_TOP,0,A_TOP,
                                B_TOP,C_TOP,D_TOP,E_TOP,F_TOP,G_TOP,H_TOP,I_TOP,J_TOP,K_TOP,L_TOP,M_TOP,
                                N_TOP,O_TOP,P_TOP,Q_TOP,R_TOP,S_TOP,T_TOP,U_TOP,V_TOP,W_TOP,X_TOP,Y_TOP,Z_TOP,0,0,0,0,UNDER_SCORE_TOP,0,
                                a_top, b_top, c_top, d_top, e_top, f_top, g_top, h_top, i_top, j_top, k_top, l_top, m_top, n_top, o_top,
                                p_top,q_top,r_top,s_top,t_top,u_top,v_top,w_top,x_top,y_top,z_top};
unsigned int ASCII_BOTTOM[127] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                SPACE_BOTTOM,0,0,0,0,0,0,0,0,0,0,COMMA_BOTTOM,DASH_BOTTOM,POINT_BOTTOM,0,ZERO_BOTTOM,
                                ONE_BOTTOM,TWO_BOTTOM,THREE_BOTTOM,FOUR_BOTTOM,FIVE_BOTTOM,SIX_BOTTOM,
                                SEVEN_BOTTOM,EIGHT_BOTTOM,NINE_BOTTOM,COLON_BOTTOM,0,LESS_THAN_BOTTOM,0,GREATER_THAN_BOTTOM,QUESTION_MARK_BOTTOM,0,A_BOTTOM,B_BOTTOM,C_BOTTOM,D_BOTTOM,
                                E_BOTTOM,F_BOTTOM,G_BOTTOM,H_BOTTOM,I_BOTTOM,J_BOTTOM,K_BOTTOM,L_BOTTOM,
                                M_BOTTOM,N_BOTTOM,O_BOTTOM,P_BOTTOM,Q_BOTTOM,R_BOTTOM,S_BOTTOM,T_BOTTOM,
                                U_BOTTOM,V_BOTTOM,W_BOTTOM,X_BOTTOM,Y_BOTTOM,Z_BOTTOM,0,0,0,0,UNDER_SCORE_BOTTOM,0,
                                a_bottom,b_bottom,c_bottom,d_bottom,e_bottom,f_bottom,g_bottom,h_bottom,
                                i_bottom,j_bottom,k_bottom,l_bottom,m_bottom,n_bottom,o_bottom,p_bottom,
                                q_bottom,r_bottom,s_bottom,t_bottom,u_bottom,v_bottom,w_bottom,x_bottom,y_bottom,z_bottom};

/* ANIME tables */
unsigned int ANIME_TOP[6]    = {WALK_MAN_TOP_0,   WALK_MAN_TOP_1,   WALK_MAN_TOP_2,   WALK_MAN_TOP_3,   WALK_MAN_TOP_4,   CLEAR_TOP};
unsigned int ANIME_BOTTOM[6] = {WALK_MAN_BOTTOM_0,WALK_MAN_BOTTOM_1,WALK_MAN_BOTTOM_2,WALK_MAN_BOTTOM_3,WALK_MAN_BOTTOM_4,CLEAR_BOTTOM};

/* Control registers addresses */
unsigned int CR_CURSOR_H[1] = {0};
unsigned int CR_CURSOR_V[1] = {0};

/* This function print a char note on the screen in (raw,col) position */
void draw_char(char note, int row, int col)
{
    unsigned int vertical   = row * LINE;
    unsigned int horizontal = col * BYTES;
    volatile int *ptr_top;
    volatile int *ptr_bottom;

    VGA_PTR(ptr_top    , horizontal + vertical);
    VGA_PTR(ptr_bottom , horizontal + vertical + LINE);

    WRITE_REG(ptr_top    , ASCII_TOP[note]);
    WRITE_REG(ptr_bottom , ASCII_BOTTOM[note]);
}

/* Structure to represent a rectangle */
typedef struct Rectangle {
    int row;
    int col;
    int width;
    int height;
} Rectangle ;


/* This function draws a rectangle on the screen at the specified location and size */
void draw_rectangle(Rectangle* rect, int value)
{
    int i, j;
    unsigned int vertical = rect->row * LINE;
    unsigned int horizontal = rect->col * BYTES;
    volatile int *ptr_top;
    volatile int *ptr_bottom;

    for (i = 0; i < rect->height; i++)
    {
        for (j = 0; j < rect->width; j++)
        {
            VGA_PTR(ptr_top, horizontal + j * BYTES + vertical);
            VGA_PTR(ptr_bottom, horizontal + j * BYTES + vertical + LINE);

            if (value == 0)
            {
                WRITE_REG(ptr_top, 0x00000000);    // Turn off the pixel
                WRITE_REG(ptr_bottom, 0x00000000); // Turn off the pixel
            }
            else
            {
                WRITE_REG(ptr_top, 0xFFFFFFFF);    // Draw the pixel
                WRITE_REG(ptr_bottom, 0xFFFFFFFF); // Draw the pixel
            }
        }
        vertical += LINE;
    }
}

void move_rectangle(Rectangle* rect, char direction)
{
    // Calculate the new position based on the direction
    int newRow = rect->row;
    int newCol = rect->col;

    switch (direction)
    {
        case 'U':
            newRow--;
            break;
        case 'D':
            newRow++;
            break;
        case 'L':
            newCol--;
            break;
        case 'R':
            newCol++;
            break;
        default:
            return; // Invalid direction, exit the function
    }

    // Check if the new position is within the screen boundaries
    if (newRow < 0 || newRow + rect->height > ROWS || newCol < 0 || newCol + rect->width > COLUMN)
    {
        return; // New position is outside the screen boundaries, exit the function
    }

    // Turn off the original rectangle
    draw_rectangle(rect, 0);

    // Update the position of the rectangle
    rect->row = newRow;
    rect->col = newCol;

    // Draw the rectangle in the new position
    draw_rectangle(rect, 1);
}




/* This function print a symbol from anime table on the screen in (raw,col) position */
void draw_symbol(int symbol, int raw, int col)
{
    unsigned int vertical   = raw * LINE;
    unsigned int horizontal = col * BYTES;
    volatile int *ptr_top;
    volatile int *ptr_bottom;

    VGA_PTR(ptr_top    , horizontal + vertical);
    VGA_PTR(ptr_bottom , horizontal + vertical + LINE);

    WRITE_REG(ptr_top    , ANIME_TOP[symbol]);
    WRITE_REG(ptr_bottom , ANIME_BOTTOM[symbol]);
}

void set_cursor(int raw, int col)
{
    WRITE_REG(CR_CURSOR_H, col);
    WRITE_REG(CR_CURSOR_V, raw);
}


/* This function clear the screen */
void clear_screen()
{
    int i = 0;
    volatile int *ptr;
    VGA_PTR(ptr , 0);
    for(i = 0 ; i < VGA_MEM_SIZE_WORDS ; i++)
    {
        ptr[i] = 0;
    }
    set_cursor(0,0);
}

/* This function print a string on the screen in (CR_CURSOR_V,CR_CURSOR_H) position */
void rvc_printf(const char *c)
{
    int i = 0;
    unsigned int raw = 0;
    unsigned int col = 0;

    READ_REG(col,CR_CURSOR_H);
    READ_REG(raw,CR_CURSOR_V);

    while(c[i] != '\0')
    {
        if(c[i] == '\n') /* End of line */
        {
            col = 0;
            raw = raw + 2 ;
            if(raw == (ROWS * 2)) /* End of screen */
            {
                raw = 0;
            }
            i++;
            continue;
        }

        draw_char(c[i], raw, col);
        col++;
        if(col == COLUMN) /* End of line */
        {
            col = 0;
            raw = raw + 2 ;
            if(raw == (ROWS * 2)) /* End of screen */
            {
                raw = 0;
            }
        }
        i++;
    }
    
    /* Update CR_CURSOR */
    WRITE_REG(CR_CURSOR_H, col);
    WRITE_REG(CR_CURSOR_V, raw);
}

void rvc_print_int(int num)
{
    char str[12];  // Maximum length of a 32-bit integer is 11 digits + sign
    int i = 0, j = 0;
    int isNegative = 0;  // Flag to check if the number is negative

    // Convert integer to string
    if (num < 0) {
        str[i++] = '-';
        num = -num;
        isNegative = 1;  // Set flag for negative number
    }
    do {
        str[i++] = num % 10 + '0';
        num /= 10;
    } while (num > 0);

    // Reverse the string, excluding the '-' sign if present
    int start = isNegative ? 1 : 0;  // Start from index 1 if negative
    j = start;
    while (j < start + (i - start) / 2) {
        char temp = str[j];
        str[j] = str[i - (j - start) - 1];
        str[i - (j - start) - 1] = temp;
        j++;
    }

    // Print each digit using draw_char
    int raw, col;
    READ_REG(raw, CR_CURSOR_V);
    READ_REG(col, CR_CURSOR_H);
    for (j = 0; j < i; j++) {
        draw_char(str[j], raw, col);
        col++;
        if (col == COLUMN) {
            col = 0;
            raw += 2;
        }
        if (raw >= ROWS * 2) {
            raw = 0;
        }
    }

    // Update cursor position
    WRITE_REG(CR_CURSOR_H, col);
    WRITE_REG(CR_CURSOR_V, raw);
}


void rvc_print_unsigned_int_hex(unsigned int num)
{
    char str[10];  // Maximum length of a 32-bit integer in hex is 8 digits + "0X" + null-terminator
    int i = 0, j = 0;
    
    // Handle the special case where num is 0
    if (num == 0) {
        str[i++] = '0';
    }

    // Convert unsigned integer to hexadecimal string
    while (num > 0) {
        unsigned int remainder = num % 16;
        str[i++] = (remainder < 10) ? (remainder + '0') : (remainder - 10 + 'A');
        num /= 16;
    }

    str[i++] = 'X';
    str[i++] = '0';
    str[i] = '\0'; // Null-terminate the string

    // Reverse the string
    for (j = 0; j < i / 2; j++) {
        char temp = str[j];
        str[j] = str[i - 1 - j];
        str[i - 1 - j] = temp;
    }

    // Print each character using draw_char
    int raw, col;
    READ_REG(raw, CR_CURSOR_V);
    READ_REG(col, CR_CURSOR_H);
    for (j = 0; j < i; j++) {
        draw_char(str[j], raw, col);
        col++;
        if (col == COLUMN) {
            col = 0;
            raw += 2;
        }
        if (raw >= ROWS * 2) {
            raw = 0;
        }
    }

    // Update cursor position
    WRITE_REG(CR_CURSOR_H, col);
    WRITE_REG(CR_CURSOR_V, raw);
}


void rvc_delay(int delay){
    int timer = 0;       
    while(timer < delay){
        timer++;
    }      
}

// The monochrome VGA support is 480x640 pixels
// The way we achieve is every pixel is a single bit
// so we need 480*640/8 = 38400 bytes
// each row has 8*80 = 640 bits (80 bytes)
// each col has 4*120 = 480 bits 

// demonstration on how to access the VGA memory to different pixels:
// we can write to any "byte" in the VGA memory in the range of 0-38400
// the first byte is the first 8 bits in the first row
// the second byte is the first 8 bits in the second row
// the third byte is the first 8 bits in the third row
// the fourth byte is the first 8 bits in the fourth row
// the fifth byte is the second 8 bits in the first row  (Note First ROW!!!)

// will write it out in a table:
// <  0x0  > _ <  0x4  > _ <  0x8  > _ <  0xC  > _ ... < 0x13C >
// <  0x1  > _ <  0x5  > _ <  0x9  > _ <  0xD  > _ ... < 0x13D >
// <  0x2  > _ <  0x6  > _ <  0xA  > _ <  0xE  > _ ... < 0x13E >
// <  0x3  > _ <  0x7  > _ <  0xB  > _ <  0xF  > _ ... < 0x13F >
// < 0x140 > _ < 0x144 > _ < 0x148 > _ < 0x14C > _ ... < 0x27C >
// < 0x141 > _ < 0x145 > _ < 0x149 > _ < 0x14D > _ ... < 0x27D >
// < 0x142 > _ < 0x146 > _ < 0x14A > _ < 0x14E > _ ... < 0x27E >
// < 0x143 > _ < 0x147 > _ < 0x14B > _ < 0x14F > _ ... < 0x27F >
// < 0x280 > _ < 0x284 > _ < 0x288 > _ < 0x28C > _ ... < 0x3BC >
// ...
// ...
// ...
// < 0x94C0> _ < 0x94C4> _ < 0x94C8> _ < 0x94CC> _ ... < 0x95FC>
// < 0x94C1> _ < 0x94C5> _ < 0x94C9> _ < 0x94CD> _ ... < 0x95FD>
// < 0x94C2> _ < 0x94C6> _ < 0x94CA> _ < 0x94CE> _ ... < 0x95FE>
// < 0x94C3> _ < 0x94C7> _ < 0x94CB> _ < 0x94CF> _ ... < 0x95FF>

// the 0x9600 in hex is 38400 in decimal (the number of bytes in the VGA memory)

//Example x=0, y=0 -> should set the byte_address to 0x0
//Example x=1, y=1 -> should set the byte_address to 0x5
//Example x=2, y=2 -> should set the byte_address to 0xA
//Example x=3, y=3 -> should set the byte_address to 0xF
//Example x=4, y=4 -> should set the byte_address to 0x150
//Example x=5, y=5 -> should set the byte_address to 0x155
//Example x=6, y=6 -> should set the byte_address to 0x15A
//Example x=7, y=7 -> should set the byte_address to 0x15F

// each row_range is 4 rows. in total we have 120 row_ranges -> 480 rows
// to calculate the row_range we need to divide the row number by 4
// to calculate the row_offset we need to take the row number mod 4
// each col_range is 8 cols. in total we have 80 col_ranges -> 640 cols
// to calculate the col_range we need to divide the col number by 8
// to calculate the col_offset we need to take the col number mod 8

// the byte address is calculated by the following formula:
// byte_address = row_range * 80 + col_range * 4 + row_offset * 80 + col_offset


#define SCREEN_WIDTH  640
#define SCREEN_HEIGHT 480
#define ROWS_PER_BLOCK 4
#define COLS_PER_BLOCK 80
#define BITS_PER_BYTE 8
#define BYTES_PER_BLOCK (ROWS_PER_BLOCK * COLS_PER_BLOCK)

/* Function to set/reset a single pixel at (x, y) position */
void set_pixel(int x, int y, int value)
{
    // Checking the boundaries
    if (x < 0 || x >= SCREEN_WIDTH || y < 0 || y >= SCREEN_HEIGHT)
        return;

    // Calculating the block and the offset within the block // Example: for x=5, y=5
    int row_block = y / ROWS_PER_BLOCK;                      // row_block : 5/4 = 1
    int row_offset = y % ROWS_PER_BLOCK;                     // row_offset: 5%4 = 1

    // Calculating the column and the bit within the byte
    int col = x / BITS_PER_BYTE;                             // col    : 5/8 = 0         
    int bit_pos = x % BITS_PER_BYTE;                         // bit_pos: 5%8 = 5

    // Calculating the byte address
    int byte_addr = row_block * BYTES_PER_BLOCK +  //   1*320 +
                    col * ROWS_PER_BLOCK +         //   0*4
                    row_offset;                    //   1  -> 321
    //rvc_print_int(byte_addr);
    //rvc_printf("\n");

    // Reading the current value of the word
    unsigned char val;
    val = VGA_MEM[byte_addr];

    // Setting/resetting the bit
    if (value) {
        val |= (1 << (bit_pos));   // Set the bit
    } else {
        val &= ~(1 << (bit_pos));  // Reset the bit
    }
    
    // Writing the new value back to the VGA buffer
    VGA_MEM[byte_addr] = val;
}

void draw_circle(int x0, int y0, int radius, int value) {
    int x = radius;
    int y = 0;
    int err = 0;
    // loop until x < y
    while (x >= y)
    {
        set_pixel(x0 + x, y0 + y, value);
        set_pixel(x0 + y, y0 + x, value);
        set_pixel(x0 - y, y0 + x, value);
        set_pixel(x0 - x, y0 + y, value);
        set_pixel(x0 - x, y0 - y, value);
        set_pixel(x0 - y, y0 - x, value);
        set_pixel(x0 + y, y0 - x, value);
        set_pixel(x0 + x, y0 - y, value);

        if (err <= 0)       // x and y are the same or y is greater than x
        {
            y += 1;         // increment y
            err += 2*y + 1; // calculate new error
        }
        if (err > 0)        // x is greater than y
        {
            x -= 1;         // decrement x
            err -= 2*x + 1; // calculate new error
        }
    }
}

int abs(int value) {
    if(value < 0) {
        return -value;
    }
    return value;
}


void draw_line(int x1, int y1, int x2, int y2, int value) {
    // Calculate the x and y deltas, and the signs of them
    int dx = abs(x2 - x1);
    int sx = x1 < x2 ? 1 : -1;
    int dy = -abs(y2 - y1);
    int sy = y1 < y2 ? 1 : -1;
    // Calculate the first error term
    int err = dx + dy, e2; 

    // While not at the end
    while(1){
        // Set the pixel
        set_pixel(x1, y1, value);
        // If the end is reached
        if (x1==x2 && y1==y2) break;
        // Calculate the error term
        e2 = 2 * err;
        // Either X or Y step
        if (e2 >= dy) {
            err += dy;
            x1 += sx;
        }
        if (e2 <= dx) {
            err += dx;
            y1 += sy;
        }
    }
}

// Define a keymap array for 256 characters. This array represents the characters
// that would appear if a key were pressed 
// The '?' character is used to denote keys that do not have a ascii representation.

char keymap[256] = { 
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?',  '`', '?', // 0x00 - 0x0F
    '?', '?', '?', '?', '?', 'q', '1', '?', '?', '?', 'z', 's', 'a', 'w',  '2', '?', // 0x10 - 0x1F
    '?', 'c', 'x', 'd', 'e', '4', '3', '?', '?', '?', 'v', 'f', 't', 'r', '5',  '?', // 0x20 - 0x2F
    '?', 'n', 'b', 'h', 'g', 'y', '6', '?', '?', '?', 'm', 'j', 'u', '7',  '8', '?', // 0x30 - 0x3F
    '?', ',', 'k', 'i', 'o', '0', '9', '?', '?', '.', '/', 'l', ';',  'p', '-', '?', // 0x40 - 0x4F
    '?', '?', '\'', '?','[', '=', '?', '?', '?', '?', '\n', ']', '?', '\\','?', '?', // 0x50 - 0x5F
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '1', '?', '4', '7', '?',  '?', '?', // 0x60 - 0x6F
    '0', '.', '2', '5', '6', '8', '?', '?', '?', '+', '3', '-', '*', '9',  '?', '?', // 0x70 - 0x7F
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?',  '?', '?', // 0x80 - 0x8F
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?',  '?', '?', // 0x90 - 0x9F
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?',  '?', '?', // 0xA0 - 0xAF
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?',  '?', '?', // 0xB0 - 0xBF
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?',  '?', '?', // 0xC0 - 0xCF
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?',  '?', '?', // 0xD0 - 0xDF
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?',  '?', '?', // 0xE0 - 0xEF
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?',  '?', '?'  // 0xF0 - 0xFF
};

char keymap_shifted[256] = { 
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '~', '?', // 0x00 - 0x0F
    '?', '?', '?', '?', '?', 'Q', '!', '?', '?', '?', 'Z', 'S', 'A', 'W', '@', '?', // 0x10 - 0x1F
    '?', 'C', 'X', 'D', 'E', '$', '#', '?', '?', '?', 'V', 'F', 'T', 'R', '%', '?', // 0x20 - 0x2F
    '?', 'N', 'B', 'H', 'G', 'Y', '^', '?', '?', '?', 'M', 'J', 'U', '&', '*', '?', // 0x30 - 0x3F
    '?', '<', 'K', 'I', 'O', ')', '(', '?', '?', '>', '\?', 'L', ':', 'P', '_', '?',// 0x40 - 0x4F
    '?', '?', '"', '?', '{', '+', '?', '?', '?', '?', '?', '}', '?', '|', '?', '?', // 0x50 - 0x5F
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '1', '?', '4', '7', '?', '?', '?', // 0x60 - 0x6F
    '0', '.', '2', '5', '6', '8', '?', '?', '?', '+', '3', '-', '*', '9', '?', '?', // 0x70 - 0x7F
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0x80 - 0x8F
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0x90 - 0x9F
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0xA0 - 0xAF
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0xB0 - 0xBF
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0xC0 - 0xCF
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0xD0 - 0xDF
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0xE0 - 0xEF
    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?'  // 0xF0 - 0xFF
};

// Define key codes for special keys
#define ENTER_KEY_CODE 0x5a       // Key code for the Enter key
#define RELEASE_KEY_CODE 0xF0     // Key code indicating that a key has been released
#define LEFT_SHIFT_KEY_CODE 0x12  // Key code indicating the use of left shift

// Function to read characters from the keyboard using a custom scanning method
// and map them using the shifted keymap defined above.
int rvc_scanf(char* str, int size){
    char char_arr[2];            // Helper array for printing characters
    char_arr[1] = '\0';          // Null-terminate for printing

    WRITE_REG(CR_KBD_SCANF_EN, 0x1); // Enable keyboard scanning

    int ready = 0;               // Flag to indicate data is ready
    int i = 0;                   // Index for storing into 'str'
    int rd_code = 0;             // Read code from keyboard
    char rd_char = 0;            // Character corresponding to read code
    int ignore_next_code = 0;    // Flag to ignore the next scan code following a release code
    int left_shift_pressed = 0;  // Flag indicated if left shift was pressed

    // Loop until the Enter key is pressed or the buffer size is reached
    while ((i < size - 1) && (rd_code != ENTER_KEY_CODE)) {
        ready = 0;
        // Wait until data is ready
        while (!ready) {
            READ_REG(ready, CR_KBD_READY);
            // Implement timeout or break condition if needed
        }
        READ_REG(rd_code, CR_KBD_DATA); // Read the scan code

        if (rd_code == RELEASE_KEY_CODE) {
            // If release code, set flag to ignore the next code
            ignore_next_code = 1;
        } else if (ignore_next_code) {
            // If the flag is set, reset it and ignore this scan code
            ignore_next_code = 0;
        }
         else if (rd_code == LEFT_SHIFT_KEY_CODE ) { // The next key code will be taken from shifted map
            left_shift_pressed = 1;
        }
        else if (rd_code != ENTER_KEY_CODE) {
            if(left_shift_pressed = 1){
                // Process normal key press using the shifted keymap
                rd_char = keymap_shifted[rd_code];
                str[i++] = rd_char;      // Store character and increment index
                char_arr[0] = rd_char;   // Set for printing
                rvc_printf(char_arr);    // Print the character
                left_shift_pressed = 0; 
            }
                // Process normal key press using the shifted keymap  // FIXME - Process normal key press using the un-shifted keymap
            else {
                rd_char = keymap_shifted[rd_code]; //FIXME - should use the un-shifted keymap!!
                str[i++] = rd_char;      // Store character and increment index
                char_arr[0] = rd_char;   // Set for printing
                rvc_printf(char_arr);    // Print the character
            }
        } 
        // Ready flag reset is optional here since it's reassigned in the loop
    }

    str[i] = '\0'; // Ensure the string is null-terminated
    WRITE_REG(CR_KBD_SCANF_EN, 0x0); // Disable keyboard scanning

    return i; // Return the number of characters read, not including '\0'
}


#endif /* GRAPHIC_VGA_H */
