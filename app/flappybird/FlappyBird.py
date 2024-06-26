import pygame
import random
import sys
import numpy as np

# Game constants
SCREEN_WIDTH = 1200
SCREEN_HEIGHT = 600
BIRD_RADIUS = 20
PIPE_WIDTH = 35
PIPE_GAP = 150
PIPE_VELOCITY = 3
GRAVITY = 0.4
INPUT_DIM = 3

# Game states
IDLE = 0
PLAYING = 1
GAME_OVER = 2


# Bird class
class Bird:
    def __init__(self, weights=None):
        self.x = SCREEN_WIDTH // 2
        self.y = SCREEN_HEIGHT // 2
        self.velocity = 0
        self.alive = True
        self.network = NeuralNetwork(weights)

    def flap(self):
        self.velocity = -7

    def update(self, inputs):
        if self.alive:
            output = self.network.feed_forward(inputs)
            if output > 0.5:
                self.flap()

        self.velocity += GRAVITY
        self.y += self.velocity

    def draw(self, screen):
        pygame.draw.circle(screen, (255, 255, 0), (self.x, int(self.y)), BIRD_RADIUS)

    def check_collision(self, pipes):
        if self.y - BIRD_RADIUS < 0 or self.y + BIRD_RADIUS > SCREEN_HEIGHT:
            return True

        for pipe in pipes:
            if pipe.collides_with_bird(self):
                return True

        return False


# Pipe class
class Pipe:
    def __init__(self, x):
        self.x = x
        self.height = random.randint(100, SCREEN_HEIGHT - PIPE_GAP - 100)

    def move(self):
        self.x -= PIPE_VELOCITY

    def draw(self, screen):
        pygame.draw.rect(screen, (0, 255, 0), (self.x, 0, PIPE_WIDTH, self.height))
        pygame.draw.rect(screen, (0, 255, 0), (self.x, self.height + PIPE_GAP, PIPE_WIDTH,
                                               SCREEN_HEIGHT - self.height - PIPE_GAP))

    def collides_with_bird(self, bird):
        if bird.y - BIRD_RADIUS < self.height or bird.y + BIRD_RADIUS > self.height + PIPE_GAP:
            if bird.x + BIRD_RADIUS > self.x and bird.x - BIRD_RADIUS < self.x + PIPE_WIDTH:
                return True
        return False


# Neural Network class
class NeuralNetwork:
    def __init__(self, weights=None):
        self.weights = weights if weights is not None else [np.random.randn(INPUT_DIM, 4), np.random.randn(4, 1)]

    def feed_forward(self, inputs):
        x = np.array(inputs).reshape(INPUT_DIM, 1)
        for weight in self.weights:
            x = NeuralNetwork.sigmoid(np.dot(weight.T, x))
        return x.item()

    def sigmoid(x):
        # Clamp the input values to prevent overflow
        x = np.clip(x, -500, 500)
        return 1 / (1 + np.exp(-x))
# Helper function for the sigmoid activation
# def sigmoid(x):
#     return 1 / (1 + np.exp(-x))


# Game class
# Game class
class FlappyBirdGame:
    def __init__(self, num_birds):
        self.state = IDLE
        self.epochs = 30
        self.current_epoch = 0
        self.num_birds = num_birds
        self.birds = []
        self.pipes = []
        self.pipe_count = 0
        self.high_score = 0
        self.cycle_count = 0
        self.best_weights = None

        # Pygame variables for the bird count display
        self.font = pygame.font.Font(None, 24)
        self.bird_count_text = self.font.render("", True, (255, 255, 255))
        self.bird_count_rect = self.bird_count_text.get_rect(topright=(10, 10))
        self.iter_gen_text = self.font.render("", True, (255, 255, 255))
        self.iter_gen_rect = self.iter_gen_text.get_rect(topright=(10, 40))
        self.high_score_text = self.font.render("", True, (255, 255, 255))
        self.high_score_rect = self.high_score_text.get_rect(topright=(10, 70))
        self.current_score_text = self.font.render("", True, (255, 255, 255))
        self.current_score_rect = self.current_score_text.get_rect(topright=(10, 100))

    def start_game(self):
        self.state = PLAYING
        self.current_epoch += 1
        self.birds = [Bird(weights=self.add_noise_to_weights(self.best_weights)) for _ in range(self.num_birds)]
        self.pipes = [Pipe(SCREEN_WIDTH)]
        self.cycle_count = 0
        global PIPE_VELOCITY
        #PIPE_VELOCITY *= 1.1
        global PIPE_GAP
        #PIPE_GAP = int(PIPE_GAP*0.95)

    def reset_game(self):
        self.state = IDLE
        self.pipes = []

    def update(self):
        if self.state == PLAYING:
            live_birds = 0
            for bird in self.birds:
                next_pipe = self.get_next_pipe()
                if next_pipe:
                    inputs = [next_pipe.x - bird.x, next_pipe.height + PIPE_GAP - bird.y, PIPE_VELOCITY]
                else:
                    # If there are no pipes, set inputs to a large value
                    inputs = [SCREEN_WIDTH, SCREEN_HEIGHT, PIPE_VELOCITY]

                bird.update(inputs)

                if bird.check_collision(self.pipes):
                    bird.alive = False

                if bird.alive:
                    live_birds += 1

            self.cycle_count += 1

            if live_birds == 1:
                self.update_best_weights()
            
            if live_birds == 0:
                self.state = GAME_OVER
                #reset pipe count
                self.pipe_count = 0

            if self.pipes[-1].x < SCREEN_WIDTH - 400:
                self.pipes.append(Pipe(SCREEN_WIDTH))
                self.pipe_count += 1
                #check if high score
                if self.pipe_count > self.high_score:
                    self.high_score = self.pipe_count

            for pipe in self.pipes:
                pipe.move()

            # Update bird count text
            self.bird_count_text = self.font.render(f"Birds Alive: {live_birds}", True, (255, 255, 255))
            self.iter_gen_text   = self.font.render(f"Generation: {self.current_epoch}", True, (255, 255, 255))
            self.high_score_text = self.font.render(f"High Score: {self.high_score}", True, (255, 255, 255))
            self.current_score_text = self.font.render(f"Current Score: {self.pipe_count}", True, (255, 255, 255))

    def get_next_pipe(self):
        for pipe in self.pipes:
            if pipe.x + PIPE_WIDTH > SCREEN_WIDTH // 2:
                return pipe
        return None

    def draw(self, screen):
        screen.fill((0, 0, 0))

        for pipe in self.pipes:
            pipe.draw(screen)

        for bird in self.birds:
            if bird.alive:
                bird.draw(screen)

        if self.state == GAME_OVER:
            font = pygame.font.Font(None, 36)
            text = font.render("Game Over", True, (255, 255, 255))
            text_rect = text.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2))
            screen.blit(text, text_rect)

        # Draw bird count
        screen.blit(self.bird_count_text, self.bird_count_rect)
        screen.blit(self.iter_gen_text,   self.iter_gen_rect)
        screen.blit(self.high_score_text, self.high_score_rect)
        screen.blit(self.current_score_text, self.current_score_rect)

    def update_best_weights(self):
        for bird in self.birds:
            if bird.alive:
                self.best_weights = bird.network.weights
                break
    def add_noise_to_weights(self, weights):
        if weights is None:
            return None
        noise = [np.random.normal(0, 0.1, size=weight.shape) for weight in weights]
        return [weight + noise[i] for i, weight in enumerate(weights)]

# Game function
def play_game(num_birds):
    pygame.init()
    screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
    clock = pygame.time.Clock()

    game = FlappyBirdGame(num_birds)

    while game.current_epoch < game.epochs:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()

        game.update()
        game.draw(screen)

        pygame.display.update()
        clock.tick(5000)

        if game.state == IDLE:
            game.start_game()

        elif game.state == GAME_OVER:
            game.reset_game()

# Start the game
play_game(50)
