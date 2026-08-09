#!/bin/bash

# ---------------------------------------------------------------
# RNA-seq exercise: download paired-end data from ENA
#
# Dataset: SRR031714
#   Drosophila melanogaster, paired-end, 5,327,425 read pairs
#   Source: European Nucleotide Archive
#
# Run with:  bash 02_download_data.sh
# ---------------------------------------------------------------


# --- Paths -----------------------------------------------------

PROJECT=~/rnaseq_course
RAW=$PROJECT/data/raw

SAMPLE=SRR031714

ENA=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR031/SRR031714

mkdir -p $RAW


# --- Step 1: Download both read files --------------------------

echo "Step 1: downloading $SAMPLE from ENA"

wget -P $RAW $ENA/${SAMPLE}_1.fastq.gz
wget -P $RAW $ENA/${SAMPLE}_2.fastq.gz


# --- Step 2: Verify file integrity -----------------------------

echo "Step 2: verifying md5 checksums"

cd $RAW

echo "f71bcf8cc122faa844062df25e3f3895  ${SAMPLE}_1.fastq.gz" >  ${SAMPLE}.md5
echo "4524b18d1f6e347d89f17c0664c5ca60  ${SAMPLE}_2.fastq.gz" >> ${SAMPLE}.md5

md5sum -c ${SAMPLE}.md5


echo "Done. Both files must report OK above before continuing."