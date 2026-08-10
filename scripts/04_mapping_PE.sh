#!/bin/bash

#---------------------------------------------------------------------
# RNA-seq exercise: mapping paired-end reads with HISAT2
#
# Dataset: SRR031714 (Drosophila melanogaster, 37 bp paied-end)
# Index: bdgp6_tran (Ensembl BDGP6 + annotated transcripts)
#
#--rna-strandness is deliberately omitted. The library is assumed
# unstranded: this is verified computationally in 05_strandness.sh
#
# Steps:
# 1. HISAT2 alignment  -> SAM
# 2. samtools view     -> BAM
# 3. samtools sort     -> sorted BAM
# 4. samtools index    -> .bai
#
# Run with: bash 04_mapping_PE.sh
# ---------------------------------------------------------------------



# --- Paths -----------------------------------------------------------

PROJECT=~/rnaseq_course
SAMPLE=SRR031714

TRIM=$PROJECT/data/trimmed
MAP=$PROJECT/output/mapping
INDEX=$PROJECT/reference/bdgp6_tran/genome_tran

mkdir -p $MAP

# --- Step 1: Alignment ------------------------------------------------

echo "Step 1: HISAT2 alignment"

hisat2 -p 4 \
    -x $INDEX \
    -1 $TRIM/${SAMPLE}_1_paired.fastq.gz \
    -2 $TRIM/${SAMPLE}_2_paired.fastq.gz \
    -S $MAP/${SAMPLE}.sam \
    --summary-file $MAP/${SAMPLE}_alignment_summary.txt

# --- Step 2: Convert SAM to BAM ----------------------------------------

echo "Step 2: samtools view (SAM -> BAM)"

samtools view -@ 4 -b $MAP/${SAMPLE}.sam > $MAP/${SAMPLE}.bam

# --- Step 3: Sort by genomic coordinate ---------------------------------

echo "Step3: samtools sort"

samtools sort -@ 4 $MAP/${SAMPLE}.bam -o $MAP/${SAMPLE}_sorted.bam

# --- Step 4: Index the sorted BAM ---------------------------------------

echo "Step 4: samtools index"

samtools index $MAP/${SAMPLE}_sorted.bam

echo "Done. Alignment rate is in $MAP/${SAMPLE}_alignment_summary.txt"



