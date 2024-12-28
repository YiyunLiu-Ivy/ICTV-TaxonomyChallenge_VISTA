import os
import csv

# Input directory containing BLAST result files
main_folder = '/path/to/BLAST_results'
output_csv_path = '/path/to/merged_output.csv'

with open(output_csv_path, 'w', newline='') as csvfile:
    csv_writer = csv.writer(csvfile)

    files = [f for f in os.listdir(main_folder) if f.endswith('.txt')]
    # iterate through every blast output
    for file_name in files:
        file_path = os.path.join(main_folder, file_name)

        with open(file_path, 'r') as infile:
            # read by line
            for line in infile:
                if line.startswith('#'):
                    continue
                else:
                    fields = line.strip().split('\t')
                    csv_writer.writerow(fields)
                    break # read only the highest match