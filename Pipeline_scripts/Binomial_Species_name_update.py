import pandas as pd

classification_file = '/path/to/classification_template.csv'
vmr_file = '/path/to/VMR_MSL39.v4_20241106.csv'
output_file = '/path/to/classification_template_update.csv'

classification_df = pd.read_csv(classification_file)
vmr_df = pd.read_csv(vmr_file)

# build the dictionary of virus name to its species name
virus_to_species = {}
for _, row in vmr_df.iterrows():
    species = str(row["Species"]).strip()
    virus_names = str(row["Virus name(s)"]).split(";")  # maybe there are no more than 1 name
    for virus_name in virus_names:
        cleaned_name = virus_name.strip().lower()   # move the blank spaces in the front or back of each name
        virus_to_species[cleaned_name] = species

# columns virus name and species, for partial matching
virus_names_column = vmr_df["Virus name(s)"].fillna("").tolist()
species_column = vmr_df["Species"].fillna("").tolist()

# iterate through the classification_template csv, update species column
def update_species(row):
    old_species = row["Species (binomial)"]
    if pd.isna(old_species) or not str(old_species).strip(): # if the species cell is empty, then leave it empty
        return old_species

    virus_name = str(old_species).strip().lower()
    matched = False # a flag indicating whether the cell is matched

    # 1. fully matched
    if virus_name in virus_to_species:
        matched = True
        return virus_to_species[virus_name].capitalize()

    # 2. partial matched with virus_name
    for xlsx_virus in virus_names_column:
        if isinstance(xlsx_virus, str) and virus_name in xlsx_virus.lower():
            matched_species = vmr_df.loc[vmr_df['Virus name(s)'] == xlsx_virus, 'Species'].iloc[0]
            matched = True
            return matched_species.capitalize()

    # 3. already in binomial form
    for species in species_column:
        if isinstance(species, str) and virus_name == species.lower():
            matched = True
            return species.capitalize()

    # 4. no match, return "No"
    if not matched:
        return f"{old_species} + NO"

# apply the logic of replacing
classification_df["Species (binomial)"] = classification_df.apply(update_species, axis=1)

# save results
classification_df.to_csv(output_file, index=False)
print(f"Updated classification file saved to: {output_file}")