#!/bin/bash

# Source directory of categorized sequences
SOURCE_DIR="/path/to/Viridae"

# Destination directory for selected viral families
DEST_DIR="/path/to/38Viridae"

# Ensure output directory exists
mkdir -p "$DEST_DIR"

# Define the target families
FOLDERS=(
  "Adenoviridae"
  "Alloherpesviridae"
  "Alphaflexiviridae"
  "Amalgaviridae"
  "Arteriviridae"
  "Astroviridae"
  "Baculoviridae"
  "Bornaviridae"
  "Caulimoviridae"
  "Circoviridae"
  "Coronaviridae"
  "Caudoviricetes"
  "Endornaviridae"
  "Filoviridae"
  "Dicistroviridae"
  "Flaviviridae"
  "Hepadnaviridae"
  "Hepeviridae"
  "Geminiviridae"
  "Orthoherpesviridae"
  "Inoviridae"
  "Iridoviridae"
  "Iflaviridae"
  "Leviviridae"
  "Mimiviridae"
  "Papillomaviridae"
  "Microviridae"
  "Paramyxoviridae"
  "Phycodnaviridae"
  "Pneumoviridae"
  "Parvoviridae"
  "Polyomaviridae"
  "Poxviridae"
  "Rhabdoviridae"
  "Potyviridae"
  "Tectiviridae"
  "Totiviridae"
  "Tymoviridae"
  "Tombusviridae"
)

for FOLDER in "${FOLDERS[@]}"; do
  if [ -d "$SOURCE_DIR/$FOLDER" ]; then
    echo "Copying $FOLDER to $DEST_DIR"
    cp -r "$SOURCE_DIR/$FOLDER" "$DEST_DIR"
  else
    echo "Warning: $FOLDER not found in $SOURCE_DIR"
  fi
done

echo "All specified folders have been processed."