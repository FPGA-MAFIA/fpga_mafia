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
#define SPACE_TOP 0x0                         
#define SPACE_BTM 0x0                         
#define COMMA_TOP 0x00000000                  
#define COMMA_BTM 0x08101000                  
#define DASH_TOP  0x00000000 
#define DASH_BTM  0x0000007C
#define POINT_TOP 0x00000000                  
#define POINT_BTM 0x00100000                  
#define ZERO_TOP  0x52623C00                  
#define ZERO_BTM  0x003C464A                  
#define ONE_TOP   0x1A1C1800                  
#define ONE_BTM   0x007E1818                  
#define TWO_TOP   0x40423C00                  
#define TWO_BTM   0x007E023C                  
#define THREE_TOP 0x40423C00                  
#define THREE_BTM 0x003C4238                  
#define FOUR_TOP  0x24283000                  
#define FOUR_BTM  0x0020207E                  
#define FIVE_TOP  0x3E027E00                  
#define FIVE_BTM  0x003C4240                  
#define SIX_TOP   0x02423C00                  
#define SIX_BTM   0x003C423E                  
#define SEVEN_TOP 0x30407E00                  
#define SEVEN_BTM 0x00080808                  
#define EIGHT_TOP 0x42423C00                  
#define EIGHT_BTM 0x003C423C                  
#define NINE_TOP  0x42423C00                  
#define NINE_BTM  0x003E407C
#define COLON_TOP 0x00100000
#define COLON_BTM 0x00001000                 
#define A_TOP     0x663C1800  
#define A_BTM     0x00667E66                  
#define B_TOP     0x3E221E00                  
#define B_BTM     0x001E223E                  
#define C_TOP     0x023E3C00                  
#define C_BTM     0x003C3E02                  
#define D_TOP     0x223E1E00                  
#define D_BTM     0x001E3E22                  
#define E_TOP     0x06067E00                  
#define E_BTM     0x007E067E                  
#define F_TOP     0x06067E00                  
#define F_BTM     0x0006067E                  
#define G_TOP     0x023E3C00                  
#define G_BTM     0x003C223A                  
#define H_TOP     0x66666600                  
#define H_BTM     0x0066667E                  
#define I_TOP     0x18187E00                  
#define I_BTM     0x007E1818                  
#define J_TOP     0x60606000                  
#define J_BTM     0x007C6666                  
#define K_TOP     0x3E664600                  
#define K_BTM     0x0046663E                  
#define L_TOP     0x06060600                  
#define L_BTM     0x007E0606                  
#define M_TOP     0x5A664200                  
#define M_BTM     0x0042425A                  
#define N_TOP     0x6E666200                  
#define N_BTM     0x00466676                  
#define O_TOP     0x66663C00                  
#define O_BTM     0x003C6666                  
#define P_TOP     0x66663E00                  
#define P_BTM     0x0006063E                  
#define Q_TOP     0x42423C00                  
#define Q_BTM     0x007C6252                  
#define R_TOP     0x66663E00                  
#define R_BTM     0x0066663E                  
#define S_TOP     0x1E067C00                  
#define S_BTM     0x003E6078                  
#define T_TOP     0x18187E00                  
#define T_BTM     0x00181818                  
#define U_TOP     0x66666600                  
#define U_BTM     0x003C7E66                  
#define V_TOP     0x66666600                  
#define V_BTM     0x00183C66                  
#define W_TOP     0x42424200                  
#define W_BTM     0x00427E5A                  
#define X_TOP     0x3C666600                  
#define X_BTM     0x0066663C                  
#define Y_TOP     0x3C666600                  
#define Y_BTM     0x00181818                  
#define Z_TOP     0x10207E00                  
#define Z_BTM     0x007E0408
#define a_TOP     0x24180000
#define a_BTM     0x00005824
#define b_TOP     0x241C0404
#define b_BTM     0x00001C24
#define c_TOP     0x04380000
#define c_BTM     0x00003804
#define d_TOP     0x24382020
#define d_BTM     0x00003824
#define e_TOP     0x24380000
#define e_BTM     0x0000781c
#define f_TOP     0x081C0830
#define f_BTM     0x00000808
#define g_TOP     0x24180000
#define g_BTM     0x18203824
#define h_TOP     0x241C0404
#define h_BTM     0x00002424
#define i_TOP     0x60002000
#define i_BTM     0x00003020
#define j_TOP     0x20002000
#define j_BTM     0x30282020
#define k_TOP     0x14240404
#define k_BTM     0x0000340C
#define l_TOP     0x10101030
#define l_BTM     0x00003810
#define m_TOP     0xB64A0000
#define m_BTM     0x00009292
#define n_TOP     0x4C340000
#define n_BTM     0x00004444
#define o_TOP     0x423C0000
#define o_BTM     0x00003C42
#define p_TOP     0x4C340000
#define p_BTM     0x0404344C
#define q_TOP     0x64580000
#define q_BTM     0x40C05864
#define r_TOP     0x4C340000
#define r_BTM     0x00000404
#define s_TOP     0x08300000
#define s_BTM     0x00182010
#define t_TOP     0x38101000
#define t_BTM     0x00305010
#define u_TOP     0x44440000
#define u_BTM     0x00005864
#define v_TOP     0x42420000
#define v_BTM     0x00001824
#define w_TOP     0x81810000
#define w_BTM     0x0000663A
#define x_TOP     0x48840000
#define x_BTM     0x0000CC30
#define y_TOP     0x48480000
#define y_BTM     0x38404070
#define z_TOP     0x20780000
#define z_BTM     0x00007810

#define LT_TOP     0x08100000 // LESS_THAN_TOP          
#define LT_BTM     0x00100804 // LESS_THAN_BTM          
#define GT_TOP     0x10080000 // GREATER_THAN_TOP       
#define GT_BTM     0x00081020 // GREATER_THAN_BTM       
#define QMARK_TOP  0x20241800 // QUESTION_MARK_TOP      
#define QMARK_BTM  0x00100010 // QUESTION_MARK_BTM      
#define SLASH_TOP  0x10204000 // SLASH_TOP              
#define SLASH_BTM  0x00020408 // SLASH_BTM              
#define SCOLON_TOP 0x00100000 // SEMICOLON_TOP          
#define SCOLON_BTM 0x08101000 // SEMICOLON_BTM          
#define BSLASH_TOP 0x08040200 // BACKSLASH_TOP          
#define BSLASH_BTM 0x00402010 // BACKSLASH_BTM          
#define EXCLM_TOP  0x08080800 // EXCLAMATION_MARK_TOP   
#define EXCLM_BTM  0x00000800 // EXCLAMATION_MARK_BTM   
#define DQ_TOP     0x00181800 // DOUBLE_QUOTES_TOP      
#define DQ_BTM     0x00000000 // DOUBLE_QUOTES_BTM      
#define NUM_TOP    0x247E2400 // NUMBER_SIGN_TOP        
#define NUM_BTM    0x00247E24 // NUMBER_SIGN_BTM        
#define DOL_TOP    0x14781010 // DOLLAR_TOP             
#define DOL_BTM    0x103C5038 // DOLLAR_BTM             
#define PCNT_TOP   0x10244000 // PER_CENT_SIGN_TOP      
#define PCNT_BTM   0x00022408 // PER_CENT_SIGN_BTM      
#define AMP_TOP    0x24241800 // AMPERSAND_TOP          
#define AMP_BTM    0x00582458 // AMPERSAND_BTM          
#define SQ_TOP     0x00080800 // SINGLE_QUOTE_TOP       
#define SQ_BTM     0x00000000 // SINGLE_QUOTE_BTM       
#define OP_PRN_TOP 0x02020400 // OPN_PRNTS_TOP          
#define OP_PRN_BTM 0x00040202 // OPN_PRNTS_BTM          
#define CL_PRN_TOP 0x40402000 // CLS_PRNTS_TOP          
#define CL_PRN_BTM 0x00204040 // CLS_PRNTS_BTM          
#define AST_TOP    0x24181824 // ASTERISK_TOP           
#define AST_BTM    0x00000000 // ASTERISK_BTM           
#define PLUS_TOP   0x10000000 // PLUS_TOP               
#define PLUS_BTM   0x0000107C // PLUS_BTM               
#define EQL_TOP    0x3C000000 // EQUALS_TOP             
#define EQL_BTM    0x00003C00 // EQUALS_BTM             
#define AT_TOP     0xA599423C // AT_SIGN_TOP            
#define AT_BTM     0x3C0259A5 // AT_SIGN_BTM            
#define OB_TOP     0x02020600 // OPEN_BRACKET_TOP       
#define OB_BTM     0x00060202 // OPEN_BRACKET_BTM       
#define CB_TOP     0x40406000 // CLOSE_BRACKET_TOP      
#define CB_BTM     0x00604040 // CLOSE_BRACKET_BTM      
#define CIR_TOP    0x00140800 // CIRCUMFLEX_TOP         
#define CIR_BTM    0x00000000 // CIRCUMFLEX_BTM         
#define GRV_TOP    0x00100800 // GRAVE_ACCENT_TOP       
#define GRV_BTM    0x00000000 // GRAVE_ACCENT_BTM       
#define UNDR_SCR_TOP 0x00000000
#define UNDR_SCR_BTM 0x007E0000
#define OBR_TOP    0x04040800 // OPENING_BRACE_TOP      
#define OBR_BTM    0x08040402 // OPENING_BRACE_BTM      
#define CBR_TOP    0x40402000 // CLOSING_BRACE_TOP      
#define CBR_BTM    0x20404080 // CLOSING_BRACE_BTM      
#define VBAR_TOP   0x10101000 // VERTICAL_BAR_TOP       
#define VBAR_BTM   0x00101010 // VERTICAL_BAR_BTM       
#define TLD_TOP    0x4C000000 // TILDE_TOP              
#define TLD_BTM    0x00000032 // TILDE_BTM              

/* ANIME Values */
#define WALK_MAN_TOP_0 0x7c381030
#define WALK_MAN_BTM_0 0x828448ba             
#define WALK_MAN_TOP_1 0x38381030             
#define WALK_MAN_BTM_1 0x4448ac78             
#define WALK_MAN_TOP_2 0x38381030             
#define WALK_MAN_BTM_2 0x10282878             
#define WALK_MAN_TOP_3 0x7c381030             
#define WALK_MAN_BTM_3 0x281038ba             
#define WALK_MAN_TOP_4 0x38381030             
#define WALK_MAN_BTM_4 0x4848387c    
#define CLEAR_TOP      0x0             
#define CLEAR_BTM      0x0           

/* ASCII tables */
unsigned int ASCII_TOP[128] = {
    0           ,0           ,0           ,0          ,0           ,0          ,0            ,0           , // 0x00 - 0x07
    0           ,0           ,0           ,0          ,0           ,0          ,0            ,0           , // 0x08 - 0x0F
    0           ,0           ,0           ,0          ,0           ,0          ,0            ,0           , // 0x10 - 0x17
    0           ,0           ,0           ,0          ,0           ,0          ,0            ,0           , // 0x18 - 0x1F
    SPACE_TOP   ,EXCLM_TOP   ,DQ_TOP      ,NUM_TOP    ,DOL_TOP     ,PCNT_TOP   ,AMP_TOP      ,SQ_TOP      , // 0x20 - 0x27
    OP_PRN_TOP  ,CL_PRN_TOP  ,AST_TOP     ,PLUS_TOP   ,COMMA_TOP   ,DASH_TOP   ,POINT_TOP    ,SLASH_TOP   , // 0x28 - 0x2F
    ZERO_TOP    ,ONE_TOP     ,TWO_TOP     ,THREE_TOP  ,FOUR_TOP    ,FIVE_TOP   ,SIX_TOP      ,SEVEN_TOP   , // 0x30 - 0x37
    EIGHT_TOP   ,NINE_TOP    ,COLON_TOP   ,SCOLON_TOP ,LT_TOP      ,EQL_TOP    ,GT_TOP       ,QMARK_TOP   , // 0x38 - 0x3F
    AT_TOP      ,A_TOP       ,B_TOP       ,C_TOP      ,D_TOP       ,E_TOP      ,F_TOP        ,G_TOP       , // 0x40 - 0x47
    H_TOP       ,I_TOP       ,J_TOP       ,K_TOP      ,L_TOP       ,M_TOP      ,N_TOP        ,O_TOP       , // 0x48 - 0x4F
    P_TOP       ,Q_TOP       ,R_TOP       ,S_TOP      ,T_TOP       ,U_TOP      ,V_TOP        ,W_TOP       , // 0x50 - 0x57
    X_TOP       ,Y_TOP       ,Z_TOP       ,OB_TOP     ,BSLASH_TOP  ,CB_TOP     ,CIR_TOP      ,UNDR_SCR_TOP, // 0x58 - 0x5F
    GRV_TOP     ,a_TOP       ,b_TOP       ,c_TOP       ,d_TOP      ,e_TOP      ,f_TOP        ,g_TOP       , // 0x60 - 0x67
    h_TOP       ,i_TOP       ,j_TOP       ,k_TOP       ,l_TOP      ,m_TOP      ,n_TOP        ,o_TOP       , // 0x68 - 0x6F
    p_TOP       ,q_TOP       ,r_TOP       ,s_TOP       ,t_TOP      ,u_TOP      ,v_TOP        ,w_TOP       , // 0x70 - 0x77
    x_TOP       ,y_TOP       ,z_TOP       ,OBR_TOP     ,VBAR_TOP   ,CBR_TOP    ,TLD_TOP      ,0            
};



/* ASCII tables */
unsigned int ASCII_BTM[128] = {
    0           ,0           ,0           ,0          ,0           ,0          ,0            ,0           , // 0x00 - 0x07
    0           ,0           ,0           ,0          ,0           ,0          ,0            ,0           , // 0x08 - 0x0F
    0           ,0           ,0           ,0          ,0           ,0          ,0            ,0           , // 0x10 - 0x17
    0           ,0           ,0           ,0          ,0           ,0          ,0            ,0           , // 0x18 - 0x1F
    SPACE_BTM   ,EXCLM_BTM   ,DQ_BTM      ,NUM_BTM    ,DOL_BTM     ,PCNT_BTM   ,AMP_BTM      ,SQ_BTM      , // 0x20 - 0x27
    OP_PRN_BTM  ,CL_PRN_BTM  ,AST_BTM     ,PLUS_BTM   ,COMMA_BTM   ,DASH_BTM   ,POINT_BTM    ,SLASH_BTM   , // 0x28 - 0x2F
    ZERO_BTM    ,ONE_BTM     ,TWO_BTM     ,THREE_BTM  ,FOUR_BTM    ,FIVE_BTM   ,SIX_BTM      ,SEVEN_BTM   , // 0x30 - 0x37
    EIGHT_BTM   ,NINE_BTM    ,COLON_BTM   ,SCOLON_BTM ,LT_BTM      ,EQL_BTM    ,GT_BTM       ,QMARK_BTM   , // 0x38 - 0x3F
    AT_BTM      ,A_BTM       ,B_BTM       ,C_BTM      ,D_BTM       ,E_BTM      ,F_BTM        ,G_BTM       , // 0x40 - 0x47
    H_BTM       ,I_BTM       ,J_BTM       ,K_BTM      ,L_BTM       ,M_BTM      ,N_BTM        ,O_BTM       , // 0x48 - 0x4F
    P_BTM       ,Q_BTM       ,R_BTM       ,S_BTM      ,T_BTM       ,U_BTM      ,V_BTM        ,W_BTM       , // 0x50 - 0x57
    X_BTM       ,Y_BTM       ,Z_BTM       ,OB_BTM     ,BSLASH_BTM  ,CB_BTM     ,CIR_BTM      ,UNDR_SCR_BTM, // 0x58 - 0x5F
    GRV_BTM     ,a_BTM       ,b_BTM       ,c_BTM       ,d_BTM      ,e_BTM      ,f_BTM        ,g_BTM       , // 0x60 - 0x67
    h_BTM       ,i_BTM       ,j_BTM       ,k_BTM       ,l_BTM      ,m_BTM      ,n_BTM        ,o_BTM       , // 0x68 - 0x6F
    p_BTM       ,q_BTM       ,r_BTM       ,s_BTM       ,t_BTM      ,u_BTM      ,v_BTM        ,w_BTM       , // 0x70 - 0x77
    x_BTM       ,y_BTM       ,z_BTM       ,OBR_BTM     ,VBAR_BTM   ,CBR_BTM    ,TLD_BTM      ,0            
};


/* ANIME tables */
unsigned int ANIME_TOP[6]    = {WALK_MAN_TOP_0,   WALK_MAN_TOP_1,   WALK_MAN_TOP_2,   WALK_MAN_TOP_3,   WALK_MAN_TOP_4,   CLEAR_TOP};
unsigned int ANIME_BTM[6] = {WALK_MAN_BTM_0,WALK_MAN_BTM_1,WALK_MAN_BTM_2,WALK_MAN_BTM_3,WALK_MAN_BTM_4,CLEAR_BTM};

/* Control registers addresses */
unsigned int CR_CURSOR_H[1] = {0};
unsigned int CR_CURSOR_V[1] = {0};

/* This function print a char note on the screen in (raw,col) position */
void draw_char(char note, int row, int col)
{
    unsigned int vertical   = row * LINE;
    unsigned int horizontal = col * BYTES;
    volatile int *ptr_TOP;
    volatile int *ptr_BTM;

    VGA_PTR(ptr_TOP    , horizontal + vertical);
    VGA_PTR(ptr_BTM , horizontal + vertical + LINE);

    WRITE_REG(ptr_TOP    , ASCII_TOP[note]);
    WRITE_REG(ptr_BTM , ASCII_BTM[note]);
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
    volatile int *ptr_TOP;
    volatile int *ptr_BTM;

    for (i = 0; i < rect->height; i++)
    {
        for (j = 0; j < rect->width; j++)
        {
            VGA_PTR(ptr_TOP, horizontal + j * BYTES + vertical);
            VGA_PTR(ptr_BTM, horizontal + j * BYTES + vertical + LINE);

            if (value == 0)
            {
                WRITE_REG(ptr_TOP, 0x00000000);    // Turn off the pixel
                WRITE_REG(ptr_BTM, 0x00000000); // Turn off the pixel
            }
            else
            {
                WRITE_REG(ptr_TOP, 0xFFFFFFFF);    // Draw the pixel
                WRITE_REG(ptr_BTM, 0xFFFFFFFF); // Draw the pixel
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
    volatile int *ptr_TOP;
    volatile int *ptr_BTM;

    VGA_PTR(ptr_TOP    , horizontal + vertical);
    VGA_PTR(ptr_BTM , horizontal + vertical + LINE);

    WRITE_REG(ptr_TOP    , ANIME_TOP[symbol]);
    WRITE_REG(ptr_BTM , ANIME_BTM[symbol]);
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
    int ready = 0;               // Flag to indicate data is ready
    int i = 0;                   // Index for storing into 'str'
    int rd_code = 0;             // Read code from keyboard
    char rd_char = 0;            // Character corresponding to read code
    int release_pressed = 0; // Flag to ignore the next scan code following a release code
    int left_shift_pressed  = 0; // Flag indicated if left shift was pressed
    int unexpected_scan_code = 0; // Flag to indicate if an unexpected scan code was received
    //Make sure the CR_KBD_DATA is empty before accepting new input
    while (ready) {
        READ_REG(rd_code, CR_KBD_DATA); // Read the HW FIFO which will pop the buffer and make it empty
    }

    // Enable keyboard scanning
    WRITE_REG(CR_KBD_SCANF_EN, 0x1); // Enable keyboard scanning
    // Loop until the Enter key is pressed or the buffer size is reached
    while ((i < size - 1) && (rd_code != ENTER_KEY_CODE) && (!unexpected_scan_code)) {
        ready = 0;
        // Wait until data is ready - the HW FIFO is not empty
        while (!ready) {
            READ_REG(ready, CR_KBD_READY);
        }
        READ_REG(rd_code, CR_KBD_DATA); // Read the scan code
        
        //Make sure the rd_code is only utilizing the 8 LSB
        // the keymap tables are 256 entries long
        if(rd_code > 255){
            rd_code = 0;
            unexpected_scan_code = 1;
        }

        if (rd_code == RELEASE_KEY_CODE) {
            // If release code, set flag to ignore the next code
            release_pressed = 1;
        } 
        else if (release_pressed) {
            // If the flag is set, reset it and ignore this scan code
            release_pressed = 0;
            if (rd_code == LEFT_SHIFT_KEY_CODE) {
                left_shift_pressed = 0;
            }
        
        }
        else if (rd_code == LEFT_SHIFT_KEY_CODE ) { // The next key code will be taken from shifted map
            left_shift_pressed = 1;
        }
        else if (rd_code != ENTER_KEY_CODE) {
            if(left_shift_pressed == 1){
                // Process normal key press using the shifted keymap
                rd_char = keymap_shifted[rd_code];
                str[i++] = rd_char;      // Store character and increment index
                char_arr[0] = rd_char;   // Set for printing
                rvc_printf(char_arr);    // Print the character
            }
                // Process normal key press using the shifted keymap
            else {
                rd_char = keymap[rd_code]; 
                str[i++] = rd_char;      // Store character and increment index
                char_arr[0] = rd_char;   // Set for printing
                rvc_printf(char_arr);    // Print the character
            }
        } 
        // Ready flag reset is optional here since it's reassigned in the loop
    }

    str[i] = '\0'; // Ensure the string is null-terminated
    WRITE_REG(CR_KBD_SCANF_EN, 0x0); // Disable keyboard scanning

    if(unexpected_scan_code){
        return -1;
    }
    return i; // Return the number of characters read, not including '\0'

}


#endif /* GRAPHIC_VGA_H */
