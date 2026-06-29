#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# VISTA_batch_class.sh
# Batch classification for class-level individual FASTA files
# (e.g., individual Caudoviricetes genomes in a single folder)
#
# Usage:
#   bash VISTA_batch_class.sh \
#       -i <input_folder>   \
#       -s <sif_image>      \
#       -c <class_name>     \
#       [-o <output_folder>] [-t <threads>]
#
# Example:
#   bash VISTA_batch_class.sh \
#       -i Caudoviricetes/ \
#       -s ~/tools/vista_final.sif \
#       -c Caudoviricetes \
#       -o Caudoviricetes_Output/ \
#       -t 8
#
# Directory structure expected:
#   Caudoviricetes/
#   ├── NC_001416.1.fasta
#   ├── NC_002371.2.fasta
#   └── ...
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

# ── Defaults ──
OUTPUT_DIR="Output"
THREADS=8

# ── Usage ──
usage() {
    echo "Usage: $0 -i <input_folder> -s <sif_image> -c <class_name> [-o <output_dir>] [-t <threads>]"
    echo ""
    echo "  -i    Input folder containing individual .fasta files"
    echo "  -s    Path to the VISTA Singularity image (.sif)"
    echo "  -c    Virus class name (e.g., Caudoviricetes)"
    echo "  -o    Output directory (default: Output)"
    echo "  -t    Number of threads (default: 8)"
    echo "  -h    Show this help message"
    exit 1
}

# ── Parse arguments ──
while getopts "i:s:c:o:t:h" opt; do
    case $opt in
        i) INPUT_DIR="$OPTARG" ;;
        s) SIF_IMAGE="$OPTARG" ;;
        c) CLASS_NAME="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        t) THREADS="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# ── Validate ──
if [ -z "${INPUT_DIR:-}" ] || [ -z "${SIF_IMAGE:-}" ] || [ -z "${CLASS_NAME:-}" ]; then
    echo "[ERROR] -i, -s, and -c are required."
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
mkdir -p "$OUTPUT_DIR"

# ── Run ──
echo "════════════════════════════════════════"
echo " Class:   $CLASS_NAME"
echo " Input:   $INPUT_DIR"
echo " Output:  $OUTPUT_DIR"
echo " Threads: $THREADS"
echo "════════════════════════════════════════"
echo ""

total=0
success=0
fail=0

for fasta_file in "$INPUT_DIR"/*.fasta; do
    [ -f "$fasta_file" ] || continue
    filename=$(basename "$fasta_file" .fasta)
    outpath="$OUTPUT_DIR/$filename"
    mkdir -p "$outpath"
    total=$((total + 1))

    echo "  [$total] $filename ..."
    if singularity exec "$SIF_IMAGE" bash /opt/VISTA/Scripts/VISTA.sh \
        -i "$fasta_file" -f "$CLASS_NAME" -o "$outpath" -t "$THREADS" 2>&1; then
        success=$((success + 1))
    else
        echo "  [WARN] Failed: $filename"
        fail=$((fail + 1))
    fi
done

echo ""
echo "════════════════════════════════════════"
echo " Done.  Total: $total  Success: $success  Failed: $fail"
echo " Output: $OUTPUT_DIR"
echo "════════════════════════════════════════"
