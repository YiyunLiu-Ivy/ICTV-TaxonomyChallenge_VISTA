import sys
import csv
from Bio import Entrez

Entrez.email = "youremail@example"

# Path of your list of staxid file
input_file = "/path/to/Staxid.csv"
# Output file to map taxids with its corresponding family/class name
output_file = "/path/to/Staxid_with_family.csv"

def get_taxonomic_name(staxid):
    try:
        handle = Entrez.efetch(db="taxonomy", id=staxid, retmode="xml")
        record = Entrez.read(handle)
        handle.close()

        family_name = None
        class_name = None
        taxon = record[0]["LineageEx"]

        for entry in taxon:
            if entry["Rank"] == "family":
                family_name = entry["ScientificName"]
            elif entry["Rank"] == "class" and entry["ScientificName"] == "Caudoviricetes":
                class_name = entry["ScientificName"]

        if class_name:
            return class_name
        elif family_name:
            return family_name
        else:
            return "ERROR: No valid rank found"

    except Exception as e:
        return f"An error occurred {e}"


with open(input_file, mode='r', newline='', encoding='UTF-8') as infile, \
    open(output_file, mode='w', newline='', encoding='UTF-8') as outfile:

    csvreader = csv.reader(infile)
    csvwriter = csv.writer(outfile)

    header = next(csvreader)
    header.append("Family/Class name")
    csvwriter.writerow(header)

    for row in csvreader:
        if row:
            staxid = row[0]
            taxonomic_name = get_taxonomic_name(staxid)
            row.append(taxonomic_name)
            csvwriter.writerow(row)
            outfile.flush()
            