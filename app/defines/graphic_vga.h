/* VGA defines */


#define VGA_MEM_SIZE_BYTES 38400
#define VGA_MEM_SIZE_WORDS 9600
#define LINE               320
#define BYTES              4
#define COLUMN             80 /* COLUMN between 0 - 79 (80x60) */
#define RAWS               60 /* RAWS between 0 - 59 (80x60) */
#define VGA_PTR(PTR,OFF)   PTR    = (volatile int *) (VGA_MEM_BASE + OFF)
#define WRITE_REG(REG,VAL) (*REG) = VAL
#define READ_REG(VAL,REG)  VAL    = (*REG)
#define VGA_MEM ((volatile char *) (VGA_MEM_BASE))

/* ASCII Values */
#define SPACE_TOP    0x0                         
#define SPACE_BOTTOM 0x0                         
#define COMMA_TOP    0x00000000                  
#define COMMA_BOTTOM 0x061E1818                  
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
#define A_TOP        0x663C1800                  
#define A_BOTTOM     0x00667E66                  
#define B_TOP        0x3E221E00                  
#define B_BOTTOM     0x001E223E                  
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
unsigned int ASCII_TOP[97]   = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,SPACE_TOP,
                                0,0,0,0,0,0,0,0,0,0,COMMA_TOP,0,POINT_TOP,0,ZERO_TOP,ONE_TOP,TWO_TOP,
                                THREE_TOP,FOUR_TOP,FIVE_TOP,SIX_TOP,SEVEN_TOP,EIGHT_TOP,NINE_TOP,0,0,0,0,0,0,0,A_TOP,
                                B_TOP,C_TOP,D_TOP,E_TOP,F_TOP,G_TOP,H_TOP,I_TOP,J_TOP,K_TOP,L_TOP,M_TOP,
                                N_TOP,O_TOP,P_TOP,Q_TOP,R_TOP,S_TOP,T_TOP,U_TOP,V_TOP,W_TOP,X_TOP,Y_TOP,Z_TOP};
unsigned int ASCII_BOTTOM[97] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                SPACE_BOTTOM,0,0,0,0,0,0,0,0,0,0,COMMA_BOTTOM,0,POINT_BOTTOM,0,ZERO_BOTTOM,
                                ONE_BOTTOM,TWO_BOTTOM,THREE_BOTTOM,FOUR_BOTTOM,FIVE_BOTTOM,SIX_BOTTOM,
                                SEVEN_BOTTOM,EIGHT_BOTTOM,NINE_BOTTOM,0,0,0,0,0,0,0,A_BOTTOM,B_BOTTOM,C_BOTTOM,D_BOTTOM,
                                E_BOTTOM,F_BOTTOM,G_BOTTOM,H_BOTTOM,I_BOTTOM,J_BOTTOM,K_BOTTOM,L_BOTTOM,
                                M_BOTTOM,N_BOTTOM,O_BOTTOM,P_BOTTOM,Q_BOTTOM,R_BOTTOM,S_BOTTOM,T_BOTTOM,
                                U_BOTTOM,V_BOTTOM,W_BOTTOM,X_BOTTOM,Y_BOTTOM,Z_BOTTOM};

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

/* This function draws a rectangle on the screen at the specified location and size */
void draw_rectangle(int row, int col, int width, int height, int value)
{
    int i, j;
    unsigned int vertical = row * LINE;
    unsigned int horizontal = col * BYTES;
    volatile int *ptr_top;
    volatile int *ptr_bottom;

    for (i = 0; i < height; i++)
    {
        for (j = 0; j < width; j++)
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

void move_rectangle(int row, int col, int width, int height, char direction)
{
    // Calculate the new position based on the direction
    int newRow = row;
    int newCol = col;

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
    if (newRow < 0 || newRow + height > RAWS || newCol < 0 || newCol + width > COLUMN)
    {
        return; // New position is outside the screen boundaries, exit the function
    }

    // Turn off the original rectangle
    draw_rectangle(row, col, width, height, 0);

    // Draw the new rectangle in the new position
    draw_rectangle(newRow, newCol, width, height, 1);
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
            if(raw == (RAWS * 2)) /* End of screen */
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
            if(raw == (RAWS * 2)) /* End of screen */
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
}

void rvc_print_int(int num)
{
    char str[12];  // Maximum length of a 32-bit integer is 11 digits + sign
    int i = 0, j = 0;

    // Convert integer to string
    if (num < 0) {
        str[i++] = '-';
        num = -num;
    }
    do {
        str[i++] = num % 10 + '0';
        num /= 10;
    } while (num > 0);

    // Reverse the string
    j = 0;
    while (j < i / 2) {
        char temp = str[j];
        str[j] = str[i - j - 1];
        str[i - j - 1] = temp;
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
        if (raw >= RAWS * 2) {
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

        if (err <= 0)
        {
            y += 1;
            err += 2*y + 1;
        }
        if (err > 0)
        {
            x -= 1;
            err -= 2*x + 1;
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
    int dx = abs(x2 - x1), sx = x1 < x2 ? 1 : -1;
    int dy = -abs(y2 - y1), sy = y1 < y2 ? 1 : -1;
    int err = dx + dy, e2; 

    while(1){
        set_pixel(x1, y1, value);
        
        if (x1==x2 && y1==y2) break;
        
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
