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



/* Function to check if the space key is pressed */
int isKeyPressed()
{
    //volatile unsigned int* cr_button_1 = (volatile unsigned int*)(CR_MEM_BASE + CR_Button_1);
    volatile unsigned int button_1_value;
    READ_REG(button_1_value, CR_Button_1);
    if (button_1_value == 0x1) {
        return 1;
    } else {
        return 0;
    }
}

/* Function to check if two rectangles overlap */
int rectanglesOverlap(int x1, int y1, int width1, int height1, int x2, int y2, int width2, int height2)
{
    int left1 = x1;
    int right1 = x1 + width1;
    int top1 = y1;
    int bottom1 = y1 + height1;

    int left2 = x2;
    int right2 = x2 + width2;
    int top2 = y2;
    int bottom2 = y2 + height2;

    if (left1 > right2 || right1 < left2 || top1 > bottom2 || bottom1 < top2) {
        return 0; // No overlap
    }

    return 1; // Overlap detected
}

/* Function to draw the dino */
void drawDino(int x, int y)
{
    draw_rectangle(y, x, DINO_WIDTH, DINO_HEIGHT, 1);
}

/* Function to erase the dino */
void eraseDino(int x, int y)
{
    draw_rectangle(y, x, DINO_WIDTH, DINO_HEIGHT, 0);
}

/* Function to draw the obstacle */
void drawObstacle(int x, int y)
{
    draw_rectangle(y, x, OBSTACLE_WIDTH, OBSTACLE_HEIGHT, 1);
}

/* Function to erase the obstacle */
void eraseObstacle(int x, int y)
{
    draw_rectangle(y, x, OBSTACLE_WIDTH, OBSTACLE_HEIGHT, 0);
}

/* Function to handle the game logic */
void playGame()
{
    int dinoX = DINO_INITIAL_X;
    int dinoY = DINO_INITIAL_Y;

    int obstacleX = OBSTACLE_INITIAL_X;
    int obstacleY = OBSTACLE_INITIAL_Y;

    int isJumping = 0;
    int jumpHeight = 0;
    int jumpcounter = 0;

    drawDino(dinoX, dinoY);
    drawObstacle(obstacleX, obstacleY);
    while (1) {
        eraseDino(dinoX, dinoY);
        eraseObstacle(obstacleX, obstacleY);

        /* Move the dino */
        if (isJumping) {
            if (jumpcounter < 6) {
                dinoY = dinoY - 2;
            }
            else {
                dinoY = dinoY + 2;
            }
        }
        
        /* Check for user input */
        if (isKeyPressed() && !isJumping) {
            if (jumpcounter < 12 ){
                isJumping = 1;
                jumpcounter++;
            }
            else {
                jumpcounter = 0;
                isJumping = 0;
            }
        }

        /* Move the obstacle */
        obstacleX--;
        if (obstacleX < 0) {
            obstacleX = SCREEN_WIDTH;
        }

        /* Check for collision */
        if (rectanglesOverlap(dinoX, dinoY, DINO_WIDTH, DINO_HEIGHT, obstacleX, obstacleY, OBSTACLE_WIDTH, OBSTACLE_HEIGHT)) {
            rvc_printf("Game Over!");
            break;
        }

        drawDino(dinoX, dinoY);
        drawObstacle(obstacleX, obstacleY);

        rvc_delay(FRAME_DELAY);
    }
}

/* Main function */
void main()
{
    clear_screen();
    playGame();
}
