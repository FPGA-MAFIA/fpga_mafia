#!/usr/bin/env python

########################################################## 
# TODO - consider to delete or move to another directory
# that script is used for lfsr debugging purpose.
# we generate random number according to the specified seed
###########################################################

import os

# Use the current working directory
directory = os.getcwd()

# Ensure the directory exists
if not os.path.exists(directory):
    os.makedirs(directory)

# Function to perform the LFSR operation with right shift
def lfsr_32_bit(seed):
    # Polynomial: x^32 + x^22 + x^2 + x^1 + 1
    # Tap positions for right shift: considering Python's 0-based indexing
    taps = [31, 21, 1, 0]
    lfsr = seed
    period = 0

    with open(os.path.join(directory, 'lfsr_output.txt'), 'w') as f:
        while True:
            # Calculate the feedback bit for right shift
            feedback_bit = (lfsr & 1) ^ ((lfsr >> 21) & 1) ^ ((lfsr >> 1) & 1) ^ ((lfsr >> 31) & 1)
            
            # Shift right and insert the feedback bit on the left
            lfsr = (lfsr >> 1) | (feedback_bit << 31)
            lfsr &= 0xFFFFFFFF  # Ensure lfsr stays 32-bit

            # Write the LFSR value in hexadecimal form
            f.write(f'{lfsr:08X}\n')  # Format as 8-digit hexadecimal
            
            period += 1
            if period >= 100:  # Limit the output for demonstration purposes
                break

# Initial seed (must be non-zero)
seed = 0xACE1
lfsr_32_bit(seed)

print(f"LFSR output stored in {os.path.join(directory, 'lfsr_output.txt')}")
