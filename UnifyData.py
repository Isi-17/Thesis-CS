# List of input files to be concatenated
files = ['File1.txt', 'File2.txt', 'File3.txt', 'File4.txt', 'File5.txt', 'File6.txt']

# Output file where the concatenated data will be saved
output_file = 'FileData.txt'

# Function to concatenate files
def concatenate_files(input_files, output_file):
    # Open the output file in write mode
    with open(output_file, 'w') as output:
        # Iterate through each input file
        for file in input_files:
            # Open the current input file in read mode
            with open(file, 'r') as f:
                # Read the content of the input file
                content = f.read()
                # Write the content to the output file
                output.write(content)

# Call the function to concatenate files
concatenate_files(files, output_file)

# Print a message indicating the successful concatenation
print(f'Files concatenated into {output_file}')
