#!/bin/bash

# ---------------------------------------------------------------
# RNA-seq exercise: quality control and trimming (paired-end)
#
# Dataset: SRR031714 (Drosophila melanogaster, 37 bp paired-end)
#
# Trimming choices, based on the raw FastQC report:
#   - ILLUMINACLIP omitted: Adapter Content was green in both files
#   - MINLEN:25 instead of 36: reads are only 37 bp long
#   - LEADING kept low: quality at the 5' end is already ~40
#
# Steps:
#   1. FastQC on raw reads
#   2. Trimmomatic PE
#   3. FastQC on trimmed reads
#
# Run with:  bash 03_qc_and_trim_PE.sh
# ---------------------------------------------------------------


# --- Paths -----------------------------------------------------

PROJECT=~/rnaseq_course

TRIMMOMATIC=$PROJECT/software/Trimmomatic-0.39/trimmomatic-0.39.jar

SAMPLE=SRR031714

RAW=$PROJECT/data/raw
TRIM=$PROJECT/data/trimmed

mkdir -p $TRIM
mkdir -p $PROJECT/output/fastqc_raw
mkdir -p $PROJECT/output/fastqc_trimmed
mkdir -p $PROJECT/logs


# --- Step 1: QC on raw reads -----------------------------------

echo "Step 1: FastQC on raw reads"

fastqc $RAW/${SAMPLE}_1.fastq.gz \
       $RAW/${SAMPLE}_2.fastq.gz \
       -o $PROJECT/output/fastqc_raw \
       -t 2


# --- Step 2: Trimming ------------------------------------------

echo "Step 2: Trimmomatic (paired-end)"

java -jar $TRIMMOMATIC PE \
    -threads 4 \
    -phred33 \
    $RAW/${SAMPLE}_1.fastq.gz \
    $RAW/${SAMPLE}_2.fastq.gz \
    $TRIM/${SAMPLE}_1_paired.fastq.gz \
    $TRIM/${SAMPLE}_1_unpaired.fastq.gz \
    $TRIM/${SAMPLE}_2_paired.fastq.gz \
    $TRIM/${SAMPLE}_2_unpaired.fastq.gz \
    LEADING:3 \
    TRAILING:15 \
    SLIDINGWINDOW:4:20 \
    MINLEN:25 \
    2> $PROJECT/logs/trimmomatic_${SAMPLE}.log


# --- Step 3: QC on trimmed reads -------------------------------

echo "Step 3: FastQC on trimmed reads"

fastqc $TRIM/${SAMPLE}_1_paired.fastq.gz \
       $TRIM/${SAMPLE}_2_paired.fastq.gz \
       -o $PROJECT/output/fastqc_trimmed \
       -t 2


echo "Done. Check logs/trimmomatic_${SAMPLE}.log for survival rates."