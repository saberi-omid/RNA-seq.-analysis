#!/bin/bash

#--------------------------------------------------------------------
# Building a HISAT2 reference index from scratch
# Organism: Schizosaccharomyces pombe (assembly ASM294v2)
#
# Part A: standard genome index (DNA-aware only)
# Part B: transcriptome-aware index (splice sites + exons)
#
# Run with: bash 06_build_index.sh
#--------------------------------------------------------------------

set -euo pipefail

#---Paths------------------------------------------------------------

PROJECTS=~/rnaseq_course
WORKDIR=$PROJECTS/index_building/pombe

FASTA_URL=https://ftp.ensemblgenomes.ebi.ac.uk/pub/fungi/current/fasta/schizosaccharomyces_pombe/dna/Schizosaccharomyces_pombe.ASM294v2.dna.toplevel.fa.gz
GTF_URL=https://ftp.ensemblgenomes.ebi.ac.uk/pub/fungi/current/gtf/schizosaccharomyces_pombe/Schizosaccharomyces_pombe.ASM294v2.63.gtf.gz
GENOME=schizo.fa
ANNOTATION=schizo.gtf

THREADS=4

#--- STEP 1: Download the reference files ----------------------------
echo "Step 1: downloading FASTA and GTF"

mkdir -p $WORKDIR
cd $WORKDIR

wget -O ${GENOME}.gz $FASTA_URL
wget -O ${ANNOTATION}.gz $GTF_URL

gunzip -f ${GENOME}.gz
gunzip -f ${ANNOTATION}.gz

ls -lh

# --- Step 2: Standard genome index (DNA-aware only) -------------------
echo "Step 2: building standard genome index"

hisat2-build -p $THREADS $GENOME schizo_index
ls -lh schizo_index*.ht2

# --- Step 3: Archive the index for sharing ----------------------------
echo "Step 3: archiving standard index"
tar -czvf schizo_index.tar.gz schizo_index*.ht2
ls -lh schizo_index.tar.gz

# --- Step 4: Extract splice sites and exons from GTF

echo "Step 4: extracting splice sites and exons from GTF"

hisat2_extract_splice_sites.py $ANNOTATION > schizo_ss.txt
hisat2_extract_exons.py $ANNOTATION > schizo_exon.txt

echo "Splice sites extracted:"
wc -l schizo_ss.txt

echo "Exons extracted:"
wc -l schizo_ss.txt

echo "First 3 lines of splice sites:"
head -3 schizo_ss.txt

echo "First 3 lines of exons:"
head -3 schizo_exon.txt

# Step 5: Transciptome-aware index (with splice sites + exons) -------

echo "Step 5: building transcriptome-aware genome index"
hisat2-build -p $THREADS --ss schizo_ss.txt --exon schizo_exon.txt $GENOME schizo_tran

ls -lh schizo_tran.ht2

echo "Step 5: Complete. Transciptome-aware index built."

