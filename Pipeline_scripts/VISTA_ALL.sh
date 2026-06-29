#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# VISTA_batch.sh
# Batch classification of FASTA sequences using VISTA
#
# Usage:
#   bash VISTA_batch.sh -i <family_dir> -s <sif_image> [-o <output_dir>]
#
# Example:
#   bash VISTA_batch.sh -i Families/ -s ~/tools/vista_final.sif -o Results/
#
# Directory structure expected:
#   Families/
#   ├── Paramyxoviridae/
#   │   ├── JX051319.1.fasta
#   │   ├── FJ215863.1.fasta
#   │   └── ...
#   └── Circoviridae/
#       ├── MW686208.1.fasta
#       └── ...
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

# ── Defaults ──
OUTPUT_DIR="Output"

# ── Usage ──
usage() {
    echo "Usage: $0 -i <family_dir> -s <sif_image> [-o <output_dir>]"
    echo ""
    echo "  -i    Input directory containing family subdirectories with .fasta files"
    echo "  -s    Path to the VISTA Singularity image (.sif)"
    echo "  -o    Output directory (default: Output)"
    echo "  -h    Show this help message"
    exit 1
}

# ── Parse arguments ──
while getopts "i:s:o:h" opt; do
    case $opt in
        i) INPUT_DIR="$OPTARG" ;;
        s) SIF_IMAGE="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# ── Validate ──
if [ -z "${INPUT_DIR:-}" ] || [ -z "${SIF_IMAGE:-}" ]; then
    echo "[ERROR] -i and -s are required."
    usage
fi

if [ ! -d "$INPUT_DIR" ]; then
    echo "[ERROR] Input directory not found: $INPUT_DIR"
    exit 1
fi

if [ ! -f "$SIF_IMAGE" ]; then
    echo "[ERROR] SIF image not found: $SIF_IMAGE"
    exit 1
fi

# Resolve to absolute paths (avoids issues with relative paths inside singularity)
INPUT_DIR=$(realpath "$INPUT_DIR")
SIF_IMAGE=$(realpath "$SIF_IMAGE")
OUTPUT_DIR=$(realpath "$OUTPUT_DIR")

# ── Run ──
total=0
success=0
fail=0

for fam in "$INPUT_DIR"/*/; do
    [ -d "$fam" ] || continue
    family_name=$(basename "$fam")
    echo ""
    echo "════════════════════════════════════════"
    echo " Family: $family_name"
    echo "════════════════════════════════════════"

    for f in "$fam"/*.fasta; do
        [ -f "$f" ] || continue
        fname=$(basename "$f" .fasta)
        outpath="$OUTPUT_DIR/$family_name/$fname"
        mkdir -p "$outpath"
        total=$((total + 1))

        echo "  [$total] $fname ..."
        if singularity exec "$SIF_IMAGE" bash /opt/VISTA/Scripts/VISTA.sh \
            -i "$f" -f "$family_name" -o "$outpath" 2>&1; then
            success=$((success + 1))
        else
            echo "  [WARN] Failed: $fname"
            fail=$((fail + 1))
        fi
    done
done

echo ""
echo "════════════════════════════════════════"
echo " Done.  Total: $total  Success: $success  Failed: $fail"
echo " Output: $OUTPUT_DIR"
echo "════════════════════════════════════════"
