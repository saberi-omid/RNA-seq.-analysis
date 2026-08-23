#!/bin/bash
#
# ---------------------------------------------------------------
# RNA-seq: Quantification with htseq_count (paired-end reads)
#
# Steps:
# 1. Activate python virtuall environment
# 2. Run htseq_count
# 3. Report summary lines
#
# Parameters mirror the earlier featureCounts run so that the two
# count tables can be compared directly.
# ---------------------------------------------------------------

# --- Paths -----------------------------------------------------
PROJECT=~/rnaseq_course

VENV=$PROJECT/htseq_env
BAM=$PROJECT/output/mapping/SRR031714_sorted.bam
GTF=$PROJECT/reference/annotation/Drosophila_melanogaster.BDGP6.54.63.gtf
OUTDIR=$PROJECT/ht_count

SAMPLE=SRR031714

# --- Step 1: Activate environment ------------------------------
echo "Step 1: activating virtual environment"

source $VENV/bin/activate

# --- Step 2: Quantification ------------------------------------

echo "Step 2: htseq-count"

mkdir -p $OUTDIR

htseq-count \
    -f bam \
    -r pos \
    -s no \
    -a 30 \
    -t exon \
    -i gene_id \
    -n 4 \
    $BAM \
    $GTF \
    > $OUTDIR/${SAMPLE}_htseq_counts.txt

# --- Step 3: Summary -------------------------------------------

echo "Step 3: summary rows"

tail -5 $OUTDIR/${SAMPLE}_htseq_counts.txt

echo "Done. Count table written to $OUTDIR/${SAMPLE}_htseq_counts.txt"

