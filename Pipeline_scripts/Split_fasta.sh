# !/bin/bash

input_file="/path/to/Caudoviricetes.fasta"
output_dir="/path/to/Caudoviricetes_split"

sequence_per_file=100
mkdir -p $output_dir

file_counter=1
sequence_counter=0

output_file="$output_dir/part_${file_counter}.fasta"

while IFS= read -r line; do
    # Examine if this is the head of a fasta sequence (begins with >)
    if [[ $line == ">"* ]]; then
        # If the number exceeds the set sequence number, switch to next split
        if (( sequence_counter == sequence_per_file )); then
            file_counter=$((file_counter + 1))
            sequence_counter=0
            output_file="$output_dir/part_${file_counter}.fasta"
        fi
        sequence_counter=$((sequence_counter + 1))
    fi
    echo "$line" >> "$output_file"
done < "input_file"

echo "Split finished!"