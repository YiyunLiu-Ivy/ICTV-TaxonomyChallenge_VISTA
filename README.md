# ICTV-TaxonomyChallenge_VISTA

## Project Overview
The repository includes the necessary pipeline scripts, dataset, and classification results of applying VISTA tool to the ICTV Taxonomy Challenge.  

To ensure reproducibility and performance testing on High-Performance Computing (HPC) environments, this pipeline utilizes Singularity (Apptainer) containers.

Results are available in Results/classification_template.

## Methodology
**VISTA (Virus Sequence-based Taxonomy Assignment)** is a computational tool that employs a novel pairwise sequence comparison system and an automatic demarcation threshold identification framework for virus taxonomy. Leveraging physio-chemical property sequences, k-mer profiles, and machine learning techniques, VISTA constructs a robust distance-based framework for taxonomic assignment. VISTA is available as both a command line tool at https://hub.docker.com/r/taozhangbig/vista and a user-friendly web portal at https://ngdc.cncb.ac.cn/vista.

For this challenge, we screened out 38 viral families and Caudoviricetes with viral sequence completeness above 80%. A total of 6,916 viral sequences were classified, including 224 sequences at the class rank, 1 sequence of order, 115 sequences at family rank, 1,969 sequences at genus rank, and 4,607 sequences at species rank. The pairwise distance was used as the score.

## Prerequisites
- Singularity (or Apptainer) installed on your HPC/Local machine
- BLAST+ Tools
- NCBI nt Database
- Python 3.11
- Git (to clone the repository)

## Setup Instructions: Get Scripts and Image
We have pre-built and optimized the VISTA Singularity image (vista_final.sif) and included it in this repository. You do not need to build it from Docker or download it separately.

1. Clone the Repository

Clone this repository to your local machine or HPC environment. This will download the pipeline scripts, the dataset, and the vista_final.sif image file.
```shell
git clone https://github.com/YiyunLiu-Ivy/ICTV-TaxonomyChallenge_VISTA.git
cd ICTV-TaxonomyChallenge_VISTA
```

2. Download the Singularity Image
The image file is hosted on GitHub Releases. Please download it into the repository directory using wget or curl.
```shell
# Download the image from GitHub Releases (v2026.01)
wget https://github.com/YiyunLiu-Ivy/ICTV-TaxonomyChallenge_VISTA/releases/download/v2026.01/vista_final.sif
```
*Note: The vista_final.sif image has been modified to store VISTA scripts and environments in /opt, ensuring compatibility with non-root user execution on HPC systems.*

3. Verify the Image (Optional)

You can verify the image is working by checking the help message. Ensure you are in the repository root directory where the .sif file is located:
```shell
singularity exec vista_final.sif bash /opt/VISTA/Scripts/VISTA.sh -h
```

## Pipeline Steps
### Step 1: Run BLAST
Run the provided Pipeline_scripts/BLAST.sh script on the ICTV-Taxonomy Challenge dataset to determine the families the query sequences belong to. This script outputs tab-separated files like the example listed below for further analysis.  
| QueryID | SubjectID | SubjectTitle | Identity | MatchLen | Qlen | Slen | Staxid |  
| --- | --- | --- | --- | --- | --- | --- | --- |  
| ICTVTaxoChallenge_100097 | gi\|1841996460\|ref\|NC_047744.1 | Bacillus phage Bp8p-T, complete genome | 100 | 148391 | 148391 | 151419 | 1445811 |

### Step 2: Filter Results
Convert BLAST results from .txt to .csv format using the Pipeline_scripts/BLAST_txt_to_csv.py script.

Filter query sequences where the **alignment length is at least 80%** of the subject sequence length and the subject sequence represents a complete genome. (This step can be performed using Microsoft Excel or equivalent tools).

### Step 3: Extract Taxonomy Information (Family level)
Extract taxonomy information using Pipeline_scripts/Get_family_name.py to associate each subject sequence taxid with its corresponding family or class. Merge this information with BLAST results using vlookup or similar methods.

### Step 4: Selection of Query Sequences
Run Pipeline_scripts/Classify_fasta.sh and Pipeline_scripts/38viridae.sh to organize query sequences into appropriate directories based on their family/Class taxonomy supported by the VISTA database. Sequences belonging to unsupported families or failing quality criteria are excluded.

### Step 5:Run VISTA (Using Singularity)
We provide batch processing scripts that accept command-line arguments for flexible execution.
 
#### For general families (38 families):
 
`VISTA_ALL.sh` iterates over family subdirectories and processes each `.fasta` file individually.
 
```shell
# Make sure your base directory is the ICTV-TaxonomyChallenge_VISTA folder

bash Pipeline_scripts/VISTA_ALL.sh \
    -i /path/to/38viridae \
    -s /path/to/vista_final.sif \
    -o Output/ \
    -t 8
```
 
| Argument | Description |
| --- | --- |
| `-i` | Input folder containing individual `.fasta` files |
| `-s` | Path to the VISTA Singularity image (`.sif`) |
| `-o` | Output directory (default: `Output`) |
| `-t` | Number of threads (default: `8`) |
 
> **Note:** Each query sequence should be in a separate `.fasta` file. Do **not** concatenate all sequences into a single file, as this will cause VISTA to compute pairwise distances for all sequences against every reference, leading to excessive runtime.

### Step 7: Consolidate VISTA Results
Consolidate all VISTA output files into a single CSV file. Run Extract_min_distance.sh, which iterates through family directories, extracts the top 1 match (from distance_file_min.txt), and appends them to Results/Combined_distance_vista.csv. This merged file provides a comprehensive view of the VISTA assignment results for all 38 families and Caudoviricetes. The table below is an explanation of VISTA output fields:
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

### Step 8: Interpret VISTA Results
Fill the ICTV-Challenge classification template based on the Assignment field from VISTA results:
1. **Species Level:**   
   If the Assignment field indicates "Same Species", populate the "Species (binomial)" column with the species name from the "Ref_Species" field.
2. **Genus Level:**   
   If the Assignment field indicates "Same Genus", populate the "Genus (-virus)" column with the genus name from the "Ref_Genus" field.
3. **Family Level:**   
   If the Assignment field indicates "Same Family", or "Different Genera", or th populate the "Family (-viridae)" column with the family name from the "Ref_Family" field.
4. **Class Level:**
   If the Assignment field indicates "Different Families", populate the "Class (-viricetes)" column with the class name from the "Class" field.
5. **Score**:
   Populate the "Class_score", "Family_score", "Genus_score", or "Species_score" columns based on the distance value in the "Distance" field. For example, lower distance values correspond to higher confidence scores. We use an inverted formula for scoring:
   ```
   Score = 1 - Distance
   ```

### Step 9: Standardize Species Column with Binomial Nomenclature
Run the Pipeline_scripts/Binomial_Species_name_update.py script to map the latest species nomenclature in VMR_MSL39(Datasets/VMR_MSL39.v4_20241106.csv) with the classification table. Further more, species that are not updated in VMR is looked up manually in the https://ictv.global/taxonomy/find_the_species tool. The final result which is in the form of ICTV-Challenge classification template is Results/Classification_Template_VISTA.csv.

## Troubleshooting
- **Permission Denied (Output)**: If running on HPC, ensure you are running the command from a directory where you have write permissions (e.g., your $HOME or /scratch directory). Do not try to write outputs to system directories like /opt inside the container.
- **Script Not Found**: If the singularity command fails, verify that you are in the root of the cloned repository where vista_final.sif is located, and that the internal path /opt/VISTA/Scripts/VISTA.sh exists.
- Verify input file formats or paths if errors occur.
- Use smaller data batches to avoid memory issues.

## Contributing
**Yiyun Liu**, **Lili Tian**: Performed this analysis   
**Yiming Bao**: Supervision

Contributions are welcome! Please create a pull request with your proposed changes.

## References
- **VISTA Paper:** https://doi.org/10.1093/gpbjnl/qzae082
- **ICTV Taxonomy Challenge:** https://ictv-vbeg.github.io/ICTV-TaxonomyChallenge/

## Contact Information
For assistance, contact vista@big.ac.cn
