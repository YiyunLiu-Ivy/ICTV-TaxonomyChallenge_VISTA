#!/bin/bash
SIF_IMAGE="./vista_final.sif"

for fam in $Your_family_path/*; do 
    family_name=$(basename "$fam"); 
    mkdir -p Output/$family_name; 
    for f in "$fam"/*.fasta; do 
        [ -f "$f" ] || continue
        fname=$(basename "$f" .fasta); 
        echo "Processing $family_name / $fname ..."
        mkdir -p Output/$family_name/$fname
        singularity exec "$SIF_IMAGE" bash /opt/VISTA/Scripts/VISTA.sh -i "$f" -f "$family_name" -o "Output/$family_name/$fname"
    done
done
