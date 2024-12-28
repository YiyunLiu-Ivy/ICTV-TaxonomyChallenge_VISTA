#!/bin/bash

# Input folder containing .fasta files
INPUT_DIR="/path/to/input_folder"
# Output folder to store BLAST results
OUTPUT_DIR="/path/to/output_folder"
# BLAST database (e.g., Virus RefSeq Database)
DB="/path/to/database"
# BLAST type（e.g., blastn, blastp, etc.）
BLAST_TYPE="blastn"
# Number of threads used
THREADS=8

# Check if the output directory exists, if not, create it
mkdir -p "$OUTPUT_DIR" 

# Iterate over all .fasta files in the input directory
for FILE in "$INPUT_DIR"/*.fasta; do
# Get the base name of the file
BASENAME=$(basename "$FILE") 
# Set the output file name (e.g., filename_blast.txt)
OUTPUT_FILE="$OUTPUT_DIR/${BASENAME%.fasta}_blast.txt" 
    # Run BLAST for each file and output to the specified file
    $BLAST_TYPE -query "$FILE" \
                -db "$DB" \
                -out "$OUTPUT_FILE" \
                -outfmt "6 qseqid sseqid stitle pident length qlen slen staxids" \
                -max_target_seqs 1 \
                -num_threads $THREADS
    # Print progress
    echo "Finished BLAST for $FILE -> $OUTPUT_FILE"
done
