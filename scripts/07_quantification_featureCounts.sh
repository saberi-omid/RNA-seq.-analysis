#!/bin/bash

# ---------------------------------------------------------------
# RNA-seq: gene-level quantification (paired-end)
#
# Input:   coordinate-sorted BAM + Ensembl GTF
# Output:  raw count matrix + simplified 2-column file
#
# Parameter choices are data-driven, not defaults:
#   -s 0                 unstranded (confirmed by RSeQC, script 05)
#   -p --countReadPairs  paired-end (confirmed by samtools flagstat)
#   -Q 30                MAPQ filter
#
# Run with:  bash 07_quantification_featureCounts.sh
# ---------------------------------------------------------------
# --- Paths -----------------------------------------------------
PROJECT=~/rnaseq_course

BAM=$PROJECT/output/mapping/SRR031714_sorted.bam
GTF=$PROJECT/reference/annotation/Drosophila_melanogaster.BDGP6.54.63.gtf
OUTDIR=$PROJECT/output/counts

SAMPLE=SRR031714


# --- Step 0: check inputs exist --------------------------------
if [ ! -f "$BAM" ]; then
    echo "ERROR: BAM not found at $BAM"
    exit 1
fi

if [ ! -f "$GTF" ]; then
    echo "ERROR: GTF not found at $GTF"
    exit 1
fi

mkdir -p $OUTDIR

# --- Step 1: featureCounts -------------------------------------

echo "Step 1: featureCounts (gene-level, unstranded, paired-end)"

featureCounts \
    -a $GTF \
    -o $OUTDIR/${SAMPLE}_counts.txt \
    -T 4 \
    -t exon \
    -g gene_id \
    -s 0 \
    -Q 30 \
    -p \
    --countReadPairs \
    $BAM \
    2> $OUTDIR/${SAMPLE}_counts.log

# --- Step 2: simplify for R ------------------------------------

echo "Step 2: extracting gene ID and count columns"

cut -f 1,7 $OUTDIR/${SAMPLE}_counts.txt > $OUTDIR/${SAMPLE}_simplified_counts.txt


echo "Done."
echo "Full matrix:  $OUTDIR/${SAMPLE}_counts.txt"
echo "Simplified:   $OUTDIR/${SAMPLE}_simplified_counts.txt"
echo "Run log:      $OUTDIR/${SAMPLE}_counts.log"

