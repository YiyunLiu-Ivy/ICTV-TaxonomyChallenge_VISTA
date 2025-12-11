#!/bin/bash
for fam in $Your_family_path/*; do 
    family_name=$(basename "$fam"); 
    mkdir -p Run_2/$family_name; 
    for f in "$fam"/*.fasta; do 
        [ -f "$f" ] || continue
        fname=$(basename "$f" .fasta); 
        echo "Processing $family_name / $fname ..."
        mkdir -p Run_2/$family_name/$fname
        bash /root/VISTA/Scripts/VISTA.sh -i "$f" -f "$family_name" -o "$Your_desired_output_path/$family_name/$fname"
    done
done
