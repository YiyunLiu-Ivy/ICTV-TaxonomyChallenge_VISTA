# ICTV-TaxonomyChallenge_VISTA

## Project Overview
The repository includes the necessary pipeline scripts, dataset, and classification results of applying VISTA tool to the ICTV Taxonomy Challenge.  

Results are available in Results/classification_template.

## Brief Description of the Methodology Used
Here, we introduce VISTA (Virus Sequence-based Taxonomy Assignment), a computational tool that employs a novel pairwise sequence comparison system and an automatic demarcation threshold identification framework for virus taxonomy. Leveraging physio-chemical property sequences, k-mer profiles, and machine learning techniques, VISTA constructs a robust distance-based framework for taxonomic assignment. VISTA is available as both a command line tool at https://hub.docker.com/r/taozhangbig/vista and a user-friendly web portal at https://ngdc.cncb.ac.cn/vista.

## Getting Started
1. Clone the repository
```shell
git clone https://github.com/YiyunLiu-Ivy/ICTV-TaxonomyChallenge_VISTA.git
```
2. Install dependencies as outlined in the Documentation\Pipeline_instructions.md 

## Usage
1. Prepare input sequences in FASTA format
2. Run the providede pipeline scripts to process the data
3. Analyze results located in the Results/ directory

## Contributing
**Yiyun Liu**, **Lili Tian**: Performed this analysis   
**Yiming Bao**: Supervision

Contributions are welcome! Please create a pull request with your proposed changes.

## References:
- VISTA Paper: https://doi.org/10.1093/gpbjnl/qzae082
- ICTV Taxonomy Challenge: https://ictv-vbeg.github.io/ICTV-TaxonomyChallenge/