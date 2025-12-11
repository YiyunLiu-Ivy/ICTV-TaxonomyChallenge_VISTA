#!/bin/bash

# Input folder
BASE_DIR="Your_VISTA_output_folder_for_the_38_viridae"

# Iterate through each family result folder
for family in "$BASE_DIR"/*; do
    if [ -d "$family" ]; then
        family_name=$(basename "$family")
        output_file="${BASE_DIR}/${family_name}.txt"

        echo "Processing family: $family_name"

        # Empty old file, write in header
        echo -e "Query_ID\tQuery\tReference_ID\tReference\tRef_Genus\tRef_Species\tDistance\tAssignment" > "$output_file"

        # Iterate through each Results/distance_file_min.txt
        find "$family" -type f -path "*/Results/distance_file_min.txt" | while read txt; do
            # Get the second line
            data_line=$(sed -n '2p' "$txt")
            if [ ! -z "$data_line" ]; then
                echo -e "$data_line" >> "$output_file"
            fi
        done
    fi
done

    echo "Done! The concatenated output folder saved at: $BASE_DIR/*.txt"
