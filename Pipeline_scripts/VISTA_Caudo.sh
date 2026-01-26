#!/bin/bash

SIF_IMAGE="./vista_final.sif"
input_folder="$Your_desired_Caudo_Folder/Caudoviricetes_split"
output_folder="$Your_desired_Caudo_Folder/Caudoviricetes_Output"

virus_Class="Caudoviricetes"

mkdir -p $output_folder

for fasta_file in $input_folder/*.fasta
do
    filename=$(basename -- "$fasta_file")
    part_number=$(echo "$filename" | grep -oE '[0-9]+')

    echo "Running VISTA on $fasta_file with virus class: $virus_Class"

    singularity exec "$SIF_IMAGE" bash /opt/VISTA/Scripts/VISTA.sh -i $fasta_file -f $virus_family -o $output_folder/part_${part_number} -t 8
done

echo "All .fasta files have been processed. Results saved in $output_folder"
