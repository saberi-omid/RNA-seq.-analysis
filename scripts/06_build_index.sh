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

