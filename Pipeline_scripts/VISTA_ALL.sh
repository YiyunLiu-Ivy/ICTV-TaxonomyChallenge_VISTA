#!/bin/bash

input_folder="/root/VISTA/ICTV_challenge/B_Families"
output_folder="/root/VISTA/ICTV_challenge/B_Output"

mkdir -p $output_folder

for fasta_file in $(ls $input_folder/*.fasta | sort -r)
do
    filename=$(basename -- "$fasta_file")
    
    virus_family="${filename%.*}"
    if [ "$virus_family" == "Orthoherpesviridae" ]; then
        virus_family="Herpesviridae"
    fi

    echo "Running VISTA on $fasta_file with virus family: $virus_family"

    VISTA.sh -i $fasta_file -f $virus_family -o $output_folder/$virus_family -t 8
done

echo "All .fasta files have been processed. Results saved in $output_folder"