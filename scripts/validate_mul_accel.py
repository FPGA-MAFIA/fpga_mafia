import re

def parse_matrix_block(block):
    # Extract matrix size, input vector, weights, biases, and expected output
    matrix_size = re.search(r"Matrix size: (\d+) x (\d+)", block)
    rows, cols = int(matrix_size.group(1)), int(matrix_size.group(2))
    
    # Extract input vector
    input_vec = list(map(int, re.search(r"Input Vector is: (.+)", block).group(1).split(", ")))
    
    # Extract weight vectors and biases
    weights = []
    biases = []
    weight_lines = re.findall(r"W\d+ Data is: (.+), Bias: (\d+)", block)
    for line in weight_lines:
        weights.append(list(map(int, line[0].split(", "))))
        biases.append(int(line[1]))
    
    # Extract expected output vector
    output_vec = list(map(int, re.search(r"Output Vector is: (.+)", block).group(1).split(", ")))
    
    return input_vec, weights, biases, output_vec

def calculate_output(input_vec, weights, biases):
    # Calculate the output by multiplying and adding biases
    output = []
    for i, weight_row in enumerate(weights):
        row_sum = sum(x * y for x, y in zip(input_vec, weight_row)) + biases[i]
        row_sum = max(min(row_sum, 127), -128)
        output.append(row_sum)
    return output

def validate_output(input_vec, weights, biases, expected_output):
    # Calculate and compare to expected output
    calculated_output = calculate_output(input_vec, weights, biases)
    if calculated_output == expected_output:
        print("Output is correct!")
    else:
        print("Output is incorrect.")
    print("Calculated Output:", calculated_output)
    print("Expected Output:", expected_output)

def main(filename):
    # Read and split data into blocks
    with open(filename, 'r') as file:
        data = file.read()
    blocks = data.strip().split("*************************************************************")

    # Process each block
    for i, block in enumerate(blocks):
        if "Matrix size" in block:
            print(f"\nProcessing Matrix Block {i+1}")
            input_vec, weights, biases, expected_output = parse_matrix_block(block)
            validate_output(input_vec, weights, biases, expected_output)

# Replace 'matrix_data.txt' with the path to your text file
main('../target/accel_core/tests/trk_accel_mul_data.log')

