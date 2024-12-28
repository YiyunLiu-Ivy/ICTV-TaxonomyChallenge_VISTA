#!/bin/bash

# Input CSV document containing QueryID and its correspnding Sfamily information
DOCUMENT="/path/to/IDfamily.csv"

# Source directory for FASTA files
SOURCE_DIR="/path/to/dataset_challenge"

# Output directory for categorized sequences
OUTPUT_DIR="/path/to/Viridae"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Remove Windows-style line endings and process the document
TEMP_FILE=$(mktemp)
tr -d '\r' < "$DOCUMENT" > "$TEMP_FILE"

{
    read; # Skip the header
    while IFS=',' read -r QueryID Sfamily; do
        # If Sfamily or QueryID cell is empty, skip
        if [ -z "$Sfamily" ] || [ -z "$QueryID" ]; then
            continue
        fi

        # Build a new directory with the name of Sfamily
        Sfamily_DIR="$OUTPUT_DIR/$Sfamily"
        mkdir -p "$Sfamily_DIR"

        # Look up in the source directory for the fasta file
        SOURCE_FILE="$SOURCE_DIR/$QueryID.fasta"

        if [ -f "$SOURCE_FILE" ]; then
            cp "$SOURCE_FILE" "$Sfamily_DIR/"
            echo "Copied $SOURCE_FILE to $Sfamily_DIR/"
        else
            echo "Warning: $SOURCE_FILE not found"
        fi
    done
} < "$TEMP_FILE"

rm -f "$TEMP_FILE"

echo "Processing completed successfully!"