import os
import csv

main_folder = '/path/to/VISTA_output_dir'
output_csv_path = '/path/to/VISTA_output.csv'

with open(output_csv_path, 'w', newline='') as csvfile:
    csv_writer = csv.writer(csvfile)

    # write the table header
    csv_writer.writerow(['Query_ID', 'Query', 'Reference_ID', 'Reference',
                         'Ref_Genus', 'Ref_Species', 'Distance', 'Assignment', 'Family'])

    # iterate through every family folder
    for family_name in os.listdir(main_folder):
        family_path = os.path.join(main_folder, family_name)

        if os.path.isdir(family_path):
            result_folder = os.path.join(family_path, 'Results')
            if os.path.exists(result_folder):
                distance_file_path = os.path.join(result_folder, 'distance_file_min.txt')
                if os.path.exists(distance_file_path):
                    with open(distance_file_path, 'r', encoding='utf-8') as infile:
                        first_data_line = False  # skip headers
                        # read by line
                        for line in infile:
                            if line.startswith('#') or not line.strip():
                                # skip annotations and empty lines
                                continue
                            elif not first_data_line:
                                first_data_line = True
                                continue
                            else:
                                fields = line.strip().split('\t')
                                # add family name as the last column
                                csv_writer.writerow(fields + [family_name])
                else:
                    print(f"Warning: {distance_file_path} not found.")
            else:
                print(f"Warning: Results folder not found in {family_path}.")

print(f"All data processed. Merged output saved to {output_csv_path}.")