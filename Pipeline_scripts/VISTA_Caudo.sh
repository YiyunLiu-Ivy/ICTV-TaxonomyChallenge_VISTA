#!/bin/bash

input_folder="/root/VISTA/ICTV_challenge/Caudoviricetes_split"
output_folder="/root/VISTA/ICTV_challenge/Caudo_Output"

virus_family="Caudoviricetes"

mkdir -p $output_folder

for fasta_file in $input_folder/*.fasta
do
    filename=$(basename -- "$fasta_file")
    part_number=$(echo "$filename" | grep -oE '[0-9]+')

    echo "Running VISTA on $fasta_file with virus family: $virus_family"

    VISTA.sh -i $fasta_file -f $virus_family -o $output_folder/part_${part_number} -t 8
done

echo "All .fasta files have been processed. Results saved in $output_folder"
