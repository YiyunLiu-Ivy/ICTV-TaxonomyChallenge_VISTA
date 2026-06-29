#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# VISTA_ALL.sh
# Batch classification of FASTA sequences using VISTA
# Supports both family-level and class-level (e.g., Caudoviricetes)
#
# Usage:
#   bash VISTA_ALL.sh -i <input_dir> -s <sif_image> [-o <output_dir>] [-t <threads>]
#
# Example:
#   bash VISTA_ALL.sh -i Datasets/ -s vista_final.sif -o Output/ -t 8
#
# Directory structure expected:
#   Datasets/
#   ├── Paramyxoviridae/
#   │   ├── seq1.fasta
#   │   └── ...
#   ├── Circoviridae/
#   │   ├── seq1.fasta
#   │   └── ...
#   └── Caudoviricetes/
#       ├── seq1.fasta
#       └── ...
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

# ── Defaults ──
OUTPUT_DIR="Output"
THREADS=1

# ── Usage ──
usage() {
    echo "Usage: $0 -i <input_dir> -s <sif_image> [-o <output_dir>] [-t <threads>]"
    echo ""
    echo "  -i    Input directory containing family/class subdirectories with .fasta files"
    echo "  -s    Path to the VISTA Singularity image (.sif)"
    echo "  -o    Output directory (default: Output)"
    echo "  -t    Number of threads (default: 1)"
    echo "  -h    Show this help message"
    exit 1
}

# ── Parse arguments ──
while getopts "i:s:o:t:h" opt; do
    case $opt in
        i) INPUT_DIR="$OPTARG" ;;
        s) SIF_IMAGE="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        t) THREADS="$OPTARG" ;;
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

# Resolve to absolute paths
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
    echo " $family_name"
    echo "════════════════════════════════════════"

    for f in "$fam"/*.fasta; do
        [ -f "$f" ] || continue
        fname=$(basename "$f" .fasta)
        outpath="$OUTPUT_DIR/$family_name/$fname"
        mkdir -p "$outpath"
        total=$((total + 1))

        echo "  [$total] $fname ..."
        if singularity exec "$SIF_IMAGE" bash /opt/VISTA/Scripts/VISTA.sh \
            -i "$f" -f "$family_name" -o "$outpath" -t "$THREADS" 2>&1; then
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
