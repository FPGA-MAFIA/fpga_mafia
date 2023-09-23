#include "../../../app/defines/big_core_defines.h"
#include "../../../app/defines/graphic_vga.h"

// Define constants for game parameters
#define BLOCK_SIZE 8
#define START_WIDTH  40 
#define START_HEIGHT 40
#define GAME_WIDTH  320
#define GAME_HEIGHT 320
#define END_WIDTH   START_WIDTH  +  GAME_WIDTH    
#define END_HEIGHT  START_HEIGHT +  GAME_HEIGHT
//#define END_WIDTH  200
//#define END_HEIGHT 100
#define SNAKE_MAX_LENGTH 3000

typedef struct {
    int x; // X-coordinate of the segment
    int y; // Y-coordinate of the segment
    int size; // Size of the block (e.g., 8 pixels)
} Segment;

// Define the Snake struct
typedef struct {
    Segment body[SNAKE_MAX_LENGTH];
    int length;
    int directionX;
    int directionY;
} Snake;

// Function to set an entire block of pixels to a given color
void set_block(int x, int y, int block_size, int color) {
    // Assuming BLOCK_SIZE is the size of each block in pixels
    for (int dx = 0; dx < block_size; dx++) {
        for (int dy = 0; dy < block_size; dy++) {
            set_pixel(x + dx, y + dy, color);
        }
    }
}

unsigned int myRand(unsigned int* seed) {
    *seed = (*seed * 1103515245 + 12345) & 0x7FFFFFFF;
    return *seed;
}

Snake snake;
Segment food;
int gameOver;
unsigned int seed = 42;

// Function to print the border of the game board
void drawBoardBorder(int set) {
    for (int x = START_WIDTH; x <= END_WIDTH; x += BLOCK_SIZE) {
            set_block(x, START_HEIGHT, BLOCK_SIZE, set);  // Vertical border
            set_block(x, END_HEIGHT  , BLOCK_SIZE, set);  // Vertical border
            //set_pixel(x, START_HEIGHT, 1);  // Vertical border
            //set_pixel(x, END_HEIGHT  , 1);  // Vertical border
        }
    for (int y = START_HEIGHT; y <= END_HEIGHT; y += BLOCK_SIZE) {
            set_block(START_WIDTH, y, BLOCK_SIZE, set); // Horizontal border
            set_block(END_WIDTH  , y, BLOCK_SIZE, set); // Horizontal border
            //set_pixel(START_WIDTH, y,  1); // Horizontal border
            //set_pixel(END_WIDTH  , y,  1); // Horizontal border
        }
}

// Function to set/clear the block of pixels representing the food
void drawFood(int set) {
    set_block(food.x, food.y,BLOCK_SIZE ,set);
}

// Function to set/clear the block of pixels representing the snake
void drawSnake(int set) {
    for (int i = 0; i < snake.length; i++) {
        set_block(snake.body[i].x, snake.body[i].y, BLOCK_SIZE, set); 
    }
}

// Make the board blink
void board_blink() {
   for(int i = 0; i<10 ; i++) {
        drawBoardBorder(i%2);
        drawSnake(i%2);
        rvc_delay(1500000);
   } 
}

// Function to generate a new random position for the food, ensuring it's not on the snake's body
void generateFoodPosition() {
    int maxAttempts = 100;  // Maximum attempts to find a valid food position
    int attempt = 0;

    do {
        // Generate random X and Y coordinates within the game area using myRand
        seed = myRand(&seed);
        food.x = (seed % GAME_WIDTH + START_WIDTH) - (seed % GAME_WIDTH + START_WIDTH)%BLOCK_SIZE;
        seed = myRand(&seed);
        food.y = (seed % GAME_HEIGHT + START_HEIGHT) - (seed % GAME_HEIGHT + START_HEIGHT)%BLOCK_SIZE;

        // Check if the new position collides with the snake's body
        int collision = 0;
        for (int i = 0; i < snake.length; i++) {
            if (food.x == snake.body[i].x && food.y == snake.body[i].y) {
                collision = 1;
                break;
            }
        }

        if (!collision) {
            // Valid position found, exit the loop
            break;
        }

        // Increment attempt count and try again
        attempt++;
    } while (attempt < maxAttempts);

    // If we couldn't find a valid position after maxAttempts, you may handle it as needed (e.g., game over).
}

// Update the score to the screen
void updateScore() {
    set_cursor(8,5);
    rvc_printf("SCORE      ");
    set_cursor(8,11);
    rvc_print_int(snake.length-5);
}

// Initialize the game state
void initGame() {
    // Initialize the snake's position, length, and direction
    snake.length = 5;
    snake.body[0].x = ((GAME_WIDTH  / 2) + START_WIDTH)  - ((GAME_WIDTH  / 2) + START_WIDTH)%BLOCK_SIZE;
    snake.body[0].y = ((GAME_HEIGHT / 2) + START_HEIGHT) - ((GAME_HEIGHT / 2) + START_HEIGHT)%BLOCK_SIZE;
    snake.directionX = BLOCK_SIZE;
    snake.directionY = 0;

    // Initialize the food's position
    generateFoodPosition(); 

    // Initialize game over flag
    gameOver = 0;
}

// Handle user input to change the snake's direction
void handleInput() {
    int Joystick_x;
    int Joystick_y;
    READ_REG(Joystick_x, CR_JOYSTICK_X);
    READ_REG(Joystick_y, CR_JOYSTICK_Y);

    if (Joystick_x < 1500) {
        snake.directionX = BLOCK_SIZE;
        snake.directionY = 0;
    } else if (Joystick_x > 2500) {
        snake.directionX = -BLOCK_SIZE;
        snake.directionY = 0;
    } else if (Joystick_y > 2500) {
        snake.directionX = 0;
        snake.directionY = BLOCK_SIZE;
    } else if (Joystick_y < 1500) {
        snake.directionX = 0;
        snake.directionY = -BLOCK_SIZE;
    }

    // Use your custom hardware functions to get user input
    // Update directionX and directionY accordingly
}


void updateGame() {
    // Check if the game is already over
    if (gameOver) {
        return;
    }

    // Update the snake's position based on the direction
    int newHeadX = snake.body[0].x + snake.directionX;
    int newHeadY = snake.body[0].y + snake.directionY;

    // Check for collisions with walls
    if (newHeadX < START_WIDTH+BLOCK_SIZE || newHeadX > END_WIDTH-BLOCK_SIZE || newHeadY < START_HEIGHT+BLOCK_SIZE || newHeadY > END_HEIGHT-BLOCK_SIZE) {
        gameOver = 1;  // Snake hit a wall, game over
        return;
    }

    // Check for collisions with food
    if (newHeadX == food.x && newHeadY == food.y) {
        // Snake ate the food, increase the length and generate new food
        snake.length++;
        updateScore();
        generateFoodPosition(); 
    }

    // Check for collisions with itself
    for (int i = 1; i < snake.length; i++) {
        if (newHeadX == snake.body[i].x && newHeadY == snake.body[i].y) {
            gameOver = 1;  // Snake collided with itself, game over
            return;
        }
    }

    // Move the snake
    for (int i = snake.length - 1; i > 0; i--) {
        snake.body[i] = snake.body[i - 1];
    }
    snake.body[0].x = newHeadX;
    snake.body[0].y = newHeadY;
}


// Render the game on the VGA display
void renderGame() {
    // Draw the food (use your custom function)
    drawFood(1);

    // Draw the snake (use your custom function)
    drawSnake(1);

    // Check if the game is over and display a message (use your custom function)
    if (gameOver) {
        set_cursor(50,21);
        rvc_printf("GAME OVER");
        board_blink();
        while(1){};
    }
}

int main() {
    // Initialize your custom hardware and VGA interface

    //clear_screen();
    //set_block(10, 10, 8, 1);
    //set_block(10, 20, 8, 1);
    //rvc_delay(1000000000);
    //rvc_delay(1000000000);
    //rvc_delay(1000000000);
    //rvc_delay(1000000000);
    
    //clear the screen
    clear_screen();
    //draw board borders
    drawBoardBorder(1);

    // Initialize the game state
    initGame();

    //draw the score
    updateScore();

    while (!gameOver) {
        // Handle user input
        handleInput();

        // Update the game logic
        updateGame();

        // Render the game on the VGA display
        renderGame();

        //delay for the game
        rvc_delay(1000000);

        //clear the old snake & food
        drawFood(0);
        drawSnake(0);
    }

    // Game over logic, display score, etc.

    // Cleanup and exit
    return 0;
}
