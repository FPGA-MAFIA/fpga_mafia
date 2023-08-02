#include "../../../app/defines/big_core_defines.h"
#include "../../../app/defines/graphic_vga.h"
// Game constants
#define BIRD_RADIUS 4
#define PIPE_WIDTH 10
#define PIPE_GAP 15
#define PIPE_VELOCITY 3
#define GRAVITY 0
#define INPUT_DIM 3
#define NULL ((void*)0)

// Game states
#define IDLE 0
#define PLAYING 1
#define GAME_OVER 2

// Neural Network struct
typedef struct {
    int weights[INPUT_DIM][3];
} NeuralNetwork;


// Bird struct
typedef struct {
    int x;
    int y;
    int velocity;
    int alive;
    NeuralNetwork network; // Add the neural network weights here
} Bird;

// Pipe struct
typedef struct {
    int x;
    int height;
} Pipe;

// Flappy Bird Game struct
typedef struct {
    int state;
    int epochs;
    int currentEpoch;
    Bird birds[49]; // Assuming a maximum of 100 birds for demonstration purposes
    Pipe pipes[99]; // Assuming a maximum of 100 pipes for demonstration purposes
    int numBirds;
    int numPipes;
    unsigned int * seed;
    NeuralNetwork bestWeights; // Pointer to the best weights
} FlappyBirdGame;

// Helper function declarations
int sigmoid(int x);
int clamp(int value, int min, int max);
double exp(double x);
unsigned int myRand(unsigned int* seed);

// Bird function declarations
void flap(Bird *bird);
void updateBird(Bird *bird, int *inputs);
void drawBird(Bird *bird);
int checkCollision(Bird *bird, Pipe *pipes, int numPipes);

// Pipe function declarations
void movePipe(Pipe *pipe);
void drawPipe(Pipe *pipe);
int collidesWithBird(Pipe *pipe, Bird *bird);

// Neural Network function declarations
int feedForward(NeuralNetwork *network, int *inputs);

// Game function declarations
void startGame(FlappyBirdGame * game);
void resetGame(FlappyBirdGame * game);
void updateGame(FlappyBirdGame * game);
void drawGame(FlappyBirdGame * game);
Pipe* getNextPipe(FlappyBirdGame * game);
void updateBestWeights(FlappyBirdGame * game);
void addNoiseToWeights(NeuralNetwork *weights, unsigned int *seed);


// Bird function definitions
void flap(Bird *bird) {
    bird->velocity = -7;
}

void updateBird(Bird *bird, int *inputs) {
    if (bird->alive) {
        flap(bird);
       // int output = feedForward(&bird->network, inputs);
       // if (output > 0.5) {
       //     flap(bird);
       // }
    }

    bird->velocity += GRAVITY;
    bird->y += bird->velocity;
}

int checkCollision(Bird *bird, Pipe *pipes, int numPipes) {
    if (bird->y - BIRD_RADIUS < 0 || bird->y + BIRD_RADIUS > SCREEN_HEIGHT) {
        return 1;
    }

    for (int i = 0; i < numPipes; i++) {
        if (collidesWithBird(&pipes[i], bird)) {
            return 1;
        }
    }

    return 0;
}

void drawBird(Bird *bird) {
    // Draw bird circle
    // Ignoring color for now
    // Use bird->x, bird->y, BIRD_RADIUS for drawing
    draw_circle(bird->x, bird->y, BIRD_RADIUS, 1);
}


// Pipe function definitions
void movePipe(Pipe *pipe) {
    pipe->x -= PIPE_VELOCITY;
}

int collidesWithBird(Pipe *pipe, Bird *bird) {
    if (bird->y - BIRD_RADIUS < pipe->height || bird->y + BIRD_RADIUS > pipe->height + PIPE_GAP) {
        if (bird->x + BIRD_RADIUS > pipe->x && bird->x - BIRD_RADIUS < pipe->x + PIPE_WIDTH) {
            return 1;
        }
    }
    return 0;
}

int sigmoid(int x) {
    if (x < -500) {
        return 0;
    }
    else if (x > 500) {
        return 1;
    }
    else {
        int exp_val = exp(x);
        return exp_val / (exp_val + 1);
    }
}

int clamp(int value, int min, int max) {
    if (value < min) {
        return min;
    }
    else if (value > max) {
        return max;
    }
    else {
        return value;
    }
}

double exp(double x) {
    double result = 1.0;
    double term = 1.0;
    int i;

    for (i = 1; i <= 10; ++i) {
        term *= x / i;
        result += term;
    }

    return result;
}

void drawPipe(Pipe *pipe) {
    // Draw pipe rectangles
    // Ignoring color for now
    // Use pipe->x, pipe->height, PIPE_WIDTH, PIPE_GAP, SCREEN_HEIGHT for drawing

    // Upper pipe rectangle
    Rectangle upperRect = {pipe->x, 0, PIPE_WIDTH, pipe->height};
    draw_rectangle(&upperRect, 1);

    // Lower pipe rectangle
    Rectangle lowerRect = {pipe->x, pipe->height + PIPE_GAP, PIPE_WIDTH, SCREEN_HEIGHT - pipe->height - PIPE_GAP};
    draw_rectangle(&lowerRect, 1);
}

// Neural Network function definitions
int feedForward(NeuralNetwork *network, int *inputs) {
    int layer1[4];
    int output;

    // Perform feed-forward calculations
    for (int i = 0; i < 4; i++) {
        int sum = 0;
        for (int j = 0; j < INPUT_DIM; j++) {
            sum += inputs[j] * network->weights[j][i];
        }
        layer1[i] = sigmoid(sum);
    }

    int sum = 0;
    for (int i = 0; i < 4; i++) {
        sum += layer1[i] * network->weights[1][i];
    }
    output = sigmoid(sum);

    return output;
}

// Game function definitions
void startGame(FlappyBirdGame* game) {
    rvc_printf("GAME\n");
    game->state = PLAYING;
    game->currentEpoch += 1;

    for (int i = 0; i < game->numBirds; i++) {
        // Initialize birds with weights and other properties
        game->birds[i].x = SCREEN_WIDTH / 2;
        game->birds[i].y = SCREEN_HEIGHT / 2;
        game->birds[i].velocity = 0;
        game->birds[i].alive = 1;
        // Initialize the neural network weights for each bird
        // Use the best weights or add noise as needed
    }

    game->pipes[0].x = SCREEN_WIDTH;
    // Generate a random height for the first pipe
    game->pipes[0].height = myRand(game->seed) % (SCREEN_HEIGHT - PIPE_GAP - 100) + 100;
    game->numPipes = 1;

}

void resetGame(FlappyBirdGame* game) {
    game->state = IDLE;
    game->numPipes = 0;
}

void updateGame(FlappyBirdGame* game) {

    rvc_printf("UPDATE\n");
    rvc_print_int(game->state);
    rvc_printf("\n");
    if (game->state == PLAYING) {
        int liveBirds = 0;
        rvc_printf("IN IF1\n");
        for (int i = 0; i < game->numBirds; i++) {
            //rvc_print_int(i);
            //rvc_printf(" ");
            Pipe *nextPipe = getNextPipe(game);
            int inputs[INPUT_DIM];

            if (nextPipe) {
                inputs[0] = nextPipe->x - game->birds[i].x;
                inputs[1] = nextPipe->height + PIPE_GAP - game->birds[i].y;
                inputs[2] = PIPE_VELOCITY;
            }
            else {
                inputs[0] = SCREEN_WIDTH;
                inputs[1] = SCREEN_HEIGHT;
                inputs[2] = PIPE_VELOCITY;
            }
            // rvc_printf("BEFORE UPDATE BIRD");

            updateBird(&game->birds[i], inputs);
            // rvc_printf("AFTER UPDATE BIRD");

            if (checkCollision(&game->birds[i], game->pipes, game->numPipes)) {
                game->birds[i].alive = 0;
            }

            if (game->birds[i].alive) {
                liveBirds++;
            }
        }

        if (liveBirds == 1) {
            updateBestWeights(game);
        }

        if (liveBirds == 0) {
            game->state = GAME_OVER;
        }

        if (game->pipes[game->numPipes - 1].x < SCREEN_WIDTH - 400) {
            game->pipes[game->numPipes].x = SCREEN_WIDTH;
            game->pipes[game->numPipes].height = myRand(game->seed) % (SCREEN_HEIGHT - PIPE_GAP - 100) + 100;
            game->numPipes++;
        }
    }
}

void drawGame(FlappyBirdGame* game) {
    clear_screen();
    for(int i=0 ; i<game->numBirds; i++) {
        drawBird(&game->birds[i]);
    }
    for(int i=0 ; i<game->numPipes; i++) {
        drawPipe(&game->pipes[i]);
    }
}

Pipe* getNextPipe(FlappyBirdGame* game) {
    for (int i = 0; i < game->numPipes; i++) {
        if (game->pipes[i].x + PIPE_WIDTH > SCREEN_WIDTH / 2) {
            return &game->pipes[i];
        }
    }
    return NULL;
}

void updateBestWeights(FlappyBirdGame* game) {
    for (int i = 0; i < game->numBirds; i++) {
        if (game->birds[i].alive) {
            // Update the best weights using the bird's network weights
            // Store the best weights for future use
            game->bestWeights = game->birds[i].network;
            break;
        }
    }
}

unsigned int myRand(unsigned int* seed) {
    *seed = (*seed * 1103515245 + 12345) & 0x7FFFFFFF;
    return *seed;
}

void addNoiseToWeights(NeuralNetwork *network, unsigned int *seed) {
    // Define the noise level (scaled by 1000 to simulate floating-point precision)
    int noiseLevel = 300; // Equivalent to 0.3

    // Iterate over the weights array and add random noise to each weight
    for (int i = 0; i < INPUT_DIM; i++) {
        for (int j = 0; j < 4; j++) {
            int randomValue = myRand(seed);
            double noise = (randomValue % (2 * noiseLevel + 1) - noiseLevel) / 1000.0;
            network->weights[i][j] += noise;
        }
    }
}

// Main function
int main() {
    clear_screen();
    rvc_printf("STARTED\n");
    FlappyBirdGame game;
    game.numBirds = 50;
    game.epochs = 20;
    game.currentEpoch = 0;
    rvc_print_int(game.epochs);
    rvc_printf("\n");
    rvc_print_int(game.currentEpoch);
    rvc_printf("\n");
    *(game.seed) = 42;

    startGame(&game);
    rvc_printf("RETURNED\n");

    while (game.currentEpoch < game.epochs) {
        rvc_printf("WHILE\n");
        
        updateGame(&game);
        rvc_printf("AFTER UPDATE\n");
    
        drawGame(&game);

        if (game.state == IDLE) {
            startGame(&game);
        }
        else if (game.state == GAME_OVER) {
            resetGame(&game);
        }
    }

    return 0;
}
