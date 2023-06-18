#include "big_core_defines.h"
#include "graphic_vga.h"

/* Define the dimensions of the game screen */
#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 60

/* Define the dimensions and initial position of the dino */
#define DINO_WIDTH 2
#define DINO_HEIGHT 8
#define DINO_INITIAL_X 10
#define DINO_INITIAL_Y (SCREEN_HEIGHT - DINO_HEIGHT)

/* Define the dimensions and initial position of the obstacles */
#define OBSTACLE_WIDTH 3
#define OBSTACLE_HEIGHT 10
#define OBSTACLE_INITIAL_X SCREEN_WIDTH
#define OBSTACLE_INITIAL_Y (SCREEN_HEIGHT - OBSTACLE_HEIGHT)

/* Delay between frames */
#define FRAME_DELAY 1000000
#define KEY_SPACE 0b00000001 // Assuming the bottom button corresponds to bit 0

Rectangle dino_rect, obst_rect;

/* Function to check if the space key is pressed */
int isKeyPressed()
{
    //volatile unsigned int* cr_button_1 = (volatile unsigned int*)(CR_MEM_BASE + CR_Button_1);
    volatile unsigned int button_0_value, button_1_value;
    READ_REG(button_0_value, CR_Button_0);
    READ_REG(button_1_value, CR_Button_1);
    if (button_0_value && !button_1_value) {
        return 1;
    } else if (button_1_value && !button_0_value) {
        return 2;
    } else {
        return 0;
    }
}

/* Function to check if two rectangles overlap */
//int rectanglesOverlap(int rect1.col, int rect1.row, int rect1.width, int rect1.height, int rect2.col, int rect2.row, int rect2.width, int rect2.height)
int rectanglesOverlap(Rectangle rect1, Rectangle rect2)
{
    
    int left1 = rect1.col;
    int right1 = rect1.col + rect1.width;
    int top1 = rect1.row;
    int bottom1 = rect1.row + rect1.height;

    int left2 = rect2.col;
    int right2 = rect2.col + rect2.width;
    int top2 = rect2.row;
    int bottom2 = rect2.row + rect2.height;

    if (left1 > right2 || right1 < left2 || top1 > bottom2 || bottom1 < top2) {
        return 0; // No overlap
    }

    return 1; // Overlap detected
}

/* Function to draw the dino */
void drawDino() {
    // draw_rectangle(y, x + 4, 1, 1, 1);      // Head
    // draw_rectangle(y + 1, x + 2, 3, 1, 1);  // Neck
    // draw_rectangle(y + 2, x, 7, 1, 1);      // Body
    // draw_rectangle(y + 3, x + 2, 3, 1, 1);  // Back
    // draw_rectangle(y + 4, x + 1, 2, 1, 1);  // Leg 1
    // draw_rectangle(y + 4, x + 4, 2, 1, 1);  // Leg 2
    // draw_rectangle(y + 3, x - 1, 1, 2, 1);  // Arm 1
    // draw_rectangle(y + 3, x + 6, 1, 2, 1);  // Arm 2
// }
    //draw_rectangle(y, x, DINO_WIDTH, DINO_HEIGHT, 1);
    //dino_rect.col=x;
    //dino_rect.row=y;
    draw_rectangle(dino_rect, 1);
}

/* Function to erase the dino */
void eraseDino()
{
    draw_rectangle(dino_rect, 0);
}

/* Function to draw the obstacle */
void drawObstacle()
{
    //obst_rect.col=x;
    //obst_rect.row=y;
    draw_rectangle(obst_rect, 1);
}

/* Function to erase the obstacle */
void eraseObstacle()
{
    draw_rectangle(obst_rect, 0);
}

/* Function to handle the game logic */
void playGame()
{
    dino_rect.col = DINO_INITIAL_X;
    dino_rect.row = DINO_INITIAL_Y;
    dino_rect.height = DINO_HEIGHT;
    dino_rect.width = DINO_WIDTH;

    obst_rect.col = OBSTACLE_INITIAL_X;
    obst_rect.row = OBSTACLE_INITIAL_Y;
    obst_rect.height = OBSTACLE_HEIGHT;
    obst_rect.width = OBSTACLE_WIDTH;

    int keyValue = 0;
    int game_over_flag = 0;
    //int jumpHeight = 0;
    //int jumpcounter = 0;

    drawDino();
    drawObstacle();
    while (1) {
        if (game_over_flag) {
            continue;
        }
        eraseDino();
        eraseObstacle();

        /* Move the dino */
        // if (isJumping) {
            // if (jumpcounter < 6) {
                // dino_rect.row = dino_rect.row - 2;
            // }
            // else {
                // dino_rect.row = dino_rect.row + 2;
            // }
        // }
        
        /* Check for user input */
        //if (isKeyPressed() && !isJumping ) {
        //    isJumping = 1;
        //}

        //if (isJumping) {
        //    if (jumpcounter < 12 ) {
        //        if (jumpcounter < 6) {
        //            dino_rect.row = dino_rect.row - 2;
        //        }
        //        else {
        //            dino_rect.row = dino_rect.row + 2;
        //        }
        //        jumpcounter++;
        //    } else {
        //        isJumping = 0;
        //    }
        //}
        keyValue = isKeyPressed();
        if (keyValue) {
            switch (keyValue)
            {
            case 1:
                dino_rect.row++;
                break;
            case 2:
                dino_rect.row;
                break;
            default:
                break;
            }
        }
        /* Move the obstacle */
        obst_rect.col--;
        if (obst_rect.col < 0) {
            obst_rect.col = SCREEN_WIDTH;
        }

        /* Check for collision */
        //if (rectanglesOverlap(dino_rect.col, dino_rect.row, DINO_WIDTH, DINO_HEIGHT, obst_rect.col, obst_rect.row, OBSTACLE_WIDTH, OBSTACLE_HEIGHT)) {
        if (rectanglesOverlap(dino_rect, obst_rect)) {
            clear_screen();
            rvc_printf("   GAME OVER");
            game_over_flag = 1;
            continue;
        }

        drawDino();
        drawObstacle();

        rvc_delay(FRAME_DELAY);
    }
}

/* Main function */
void main()
{
    clear_screen();
    playGame();
}
