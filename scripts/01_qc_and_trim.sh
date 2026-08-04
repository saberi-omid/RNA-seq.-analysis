#!/bin/bash

# ---------------------------------------------------------------
# RNA-seq: quality control and trimming (single-end reads)
#
# Steps:
#   1. FastQC on raw reads
#   2. Trimmomatic
#   3. FastQC on trimmed reads
#
# Run with:  bash 01_qc_and_trim.sh
# ---------------------------------------------------------------


# --- Paths -----------------------------------------------------

PROJECT=~/rnaseq_course

TRIMMOMATIC=$PROJECT/software/Trimmomatic-0.39/trimmomatic-0.39.jar
ADAPTERS=$PROJECT/software/Trimmomatic-0.39/adapters/TruSeq3-SE.fa

SAMPLE=Dandelion_Test_SE


# --- Step 1: QC on raw reads -----------------------------------

echo "Step 1: FastQC on raw reads"

fastqc $PROJECT/data/raw/$SAMPLE.fastq.gz \
    -o $PROJECT/output/fastqc_raw


# --- Step 2: Trimming ------------------------------------------

echo "Step 2: Trimmomatic"

java -jar $TRIMMOMATIC SE \
    -threads 4 \
    -phred33 \
    $PROJECT/data/raw/$SAMPLE.fastq.gz \
    $PROJECT/data/trimmed/${SAMPLE}_trimmed.fastq.gz \
    ILLUMINACLIP:$ADAPTERS:2:30:10 \
    LEADING:3 \
    TRAILING:20 \
    SLIDINGWINDOW:4:20 \
    MINLEN:36


# --- Step 3: QC on trimmed reads -------------------------------

echo "Step 3: FastQC on trimmed reads"

fastqc $PROJECT/data/trimmed/${SAMPLE}_trimmed.fastq.gz \
    -o $PROJECT/output/fastqc_trimmed


echo "Done. Compare the HTML reports in output/fastqc_raw and output/fastqc_trimmed"
