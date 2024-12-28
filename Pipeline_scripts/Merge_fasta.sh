# !/bin/bash

# Input the folder of selected viral families
input_folder="/path/to/38Viridae"
# Output folder is for storing the merged big fasta file of each family
output_dir="/path/to/desired_directory"
mkdir -p "$output_dir"

# Iterate through each family folder
for family_dir in "$input_folder"/*; do
    # Erase "/" in the path, get the family name
    family_name=$(basename "$family_dir")

    # Output name
    output_file="$output_dir/${family_name}.fasta"

    # Initialize output file
    > "$output_file"

    # Combine all the .fasta sequence files into one
    for fasta_file in "$family_dir"/*.fasta; do
        cat "$fasta_file" >> "$output_file"
    done
    echo "Finished: $output_file"
done