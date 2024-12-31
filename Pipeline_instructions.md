# Introduction
This document outlines the steps to apply VISTA pipeline to the ICTV Taxonomy Challenge.

# Prerequisites
- Docker
- BLAST+ Tools
- NCBI nt Database
# Setup Instructions
1. Pull and set up the VISTA Docker image:
```shell
# Pull the docker image
docker pull taozhangbig/vista:latest
# Initialize a VISTA container
docker run -itd --name vista [image_id] /sbin/init
# Enter the VISTA container
docker exec -it [container id] bash
```
2. Download the NCBI nt Database

# Pipeline Steps
## Step 1: Run BLAST
Run the provided Pipeline_scripts/BLAST.sh script to run the ICTV-Taxonomy Challenge dataset to determine the families where the query sequences belong to.  
This script outputs tab-separated files like the example listed below for further analysis.  
| QueryID | SubjectID | SubjectTitle | Identity | MatchLen | Qlen | Slen | Staxid |  
| --- | --- | --- | --- | --- | --- | --- | --- |  
| ICTVTaxoChallenge_100097 | gi\|1841996460\|ref\|NC_047744.1 | Bacillus phage Bp8p-T, complete genome | 100 | 148391 | 148391 | 151419 | 1445811 |

## Step 2: Filter Results
1. Convert BLAST results from .txt to .csv format using the Pipeline_scripts/BLAST_txt_to_csv.py script.
2. Filter query sequences where the alignment length is at least 80% of the subject sequence length and the subject sequence represents to be a complete genome. This filtration step is completed by the help of Microsoft Excel.

## Step 3: Extract Taxonomy Information (Family level)
Extract taxonomy information using Pipeline_scripts/Get_family_name.py to associate each subject sequence taxid with its corresponding family or class. Merge this information with BLAST results using Excel or equivalent tools (e.g., vlookup function).

## Step 4: Selection of Query Sequences with Family Taxonomy within VISTA Database
This step runs the script Pipeline_scripts/Classify_fasta.sh and Pipeline_scripts/38viridae.sh, to select query sequences in the original dataset based on their family/Class taxonomy as supported by the VISTA database. It includes identifying organizing them into appropriate directories, and consolidating them for downstream analysis. Sequences belonging to families not supported by the database or failing to meet quality criteria are excluded. This ensures that only relevant sequences are prepared for the subsequent VISTA processing steps.

## Step 5: Prepare Input for VISTA
Merge sequences by family into single FASTA files using Pipeline_scripts/Merge_fasta.sh. For large datasets (e.g., Caudoviricetes), split into smaller batches with Pipeline_scripts/Split_fasta.sh to prevent system overload.

## Step 6: Run VISTA
Run VISTA for the prepared sequences using the provided scripts.
- For gereral families:
```shell
bash VISTA_ALL.sh
```
- For Caudoviricetes:
```shell
bash VISTA_Caudo.sh
```

## Step 7: Consolidate VISTA Results
This step involves consolidating all VISTA output files into a single CSV file for further analysis. Our script Pipeline_scripts/VISTA_txt_to_csv.py iterates through each family directory, extracts the results from distance_file_min.txt files, which contains the top 1 match of each query sequence, and appends them into a unified CSV file, which can be obtained in the Results/Combined_distance_vista.csv. This merged file provides a comprehensive view of the VISTA assignment results for all 38 families and Caudoviricetes. The table below is an explanation of VISTA output fields:
|Field Name|Description|
|---|---|
|Query_ID|Unique identifier for the user-provided query sequence.|
|Query|Description or name of the query sequence.|
|Reference_ID|Unique identifier for the matched reference sequence.|
|Reference|Description or name of the matched reference sequence.|
|Ref_Genus|The genus of the reference sequence.|
|Ref_Species|The species of the reference sequence.|
|Distance|Distance value between the query and reference sequences; smaller values indicate higher similarity.|
|Assignment|The assignment result of the query sequence by VISTA.|
|Ref_Family|The inferred family of the query sequence based on the reference sequence.|
|Class|If the BLAST result indicates the highest match sequence is Caudoviricetes virus, the field is filled in with Caudoviricetes, otherwise it is left empty.|

## Step 8: Interpret VISTA Results into ICTV-Challenge Classification Template
This step fills the ICTV-Challenge classification template based on the Assignment filed from the VISTA results. The logic for filling in the classification levels is as follows:   
1. Species Level:   
   If the Assignment field indicates "Same Species", populate the "Species (binomial)" column with the species name from the "Ref_Species" field.
2. Genus Level:   
   If the Assignment field indicates "Same Genus", populate the "Genus (-virus)" column with the genus name from the "Ref_Genus" field.
3. Family Level:   
   If the Assignment field indicates "Same Family", or "Different Genera", or th populate the "Family (-viridae)" column with the family name from the "Ref_Family" field.
4. Class Level:
   If the Assignment field indicates "Different Families", populate the "Class (-viricetes)" column with the class name from the "Class" field.
5. Score Determination Using Distance Inversion:
   Populate the "Class_score", "Family_score", "Genus_score", or "Species_score" columns based on the distance value in the "Distance" field. For example, lower distance values correspond to higher confidence scores. We use an inverted formula for scoring:
   ```
   Score = 1 - Distance
   ```
## Step 9: Standardize Species Column with Binomial Nomenclature
To ensure compliance with ICTV standards, the species column in the classification template is standardized using the binomial nomenclature. Run the Pipeline_scripts/Binomial_Species_name_update.py script to map the latest species nomenclature in VMR_MSL39(Datasets/VMR_MSL39.v4_20241106.csv) with the classification table. Further more, species that are not updated in VMR is looked up manually in the https://ictv.global/taxonomy/find_the_species tool. The final result which is in the form of ICTV-Challenge classification template is Results/Classification_Template_VISTA.csv.

# Troubleshooting
- Verify input file formats or paths if errors occur.
- Use smaller data batches to avoid memory issues.

# Contact Information
For assistance, contact vista@big.ac.cn