import os

# Project root detection
ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Block sizes
SOURCE_SIZE = 8
DESTINATION_SIZE = 4
STEP = 8

# Transformation options
DIRECTIONS = [1, -1]
ANGLES = [0, 90, 180, 270]

# Neural network
FEATURE_DIM = 64
HIDDEN_DIM = 128
BATCH_SIZE = 64
LEARNING_RATE = 0.001
NUM_EPOCHS = 50

# Training
TRAIN_SPLIT = 0.8
RANDOM_SEED = 42

# Paths (Absolute to project root)
MODEL_PATH = os.path.join(ROOT_DIR, "models", "block_matcher.pth")
DATASET_PATH = os.path.join(ROOT_DIR, "dataset")

# Decompression
NUM_ITERATIONS = 8
