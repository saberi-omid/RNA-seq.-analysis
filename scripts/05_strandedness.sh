#!/bin/bash

# ---------------------------------------------------------------
# RNA-seq exercise: verify library strandedness
#
# Dataset: SRR031714 (Drosophila melanogaster, paired-end)
#
# 04_mapping_PE.sh assumed an unstranded library and omitted
# --rna-strandness. This script tests that assumption using RSeQC.
#
# Steps:
#   1. GTF  -> genePred   (UCSC gtfToGenePred)
#   2. genePred -> BED    (UCSC genePredToBed)
#   3. infer_experiment.py compares read strand vs gene strand
#
# Requires: RSeQC installed in software/rseqc_env
#           gtfToGenePred and genePredToBed in software/
#
# Run with:  bash 05_strandedness.sh
# ---------------------------------------------------------------


# --- Paths -----------------------------------------------------

PROJECT=~/rnaseq_course

SAMPLE=SRR031714

ANNOT=$PROJECT/reference/annotation
MAP=$PROJECT/output/mapping
TOOLS=$PROJECT/software

GTF=$ANNOT/Drosophila_melanogaster.BDGP6.54.63.gtf


# --- Activate the RSeQC virtual environment --------------------

source $TOOLS/rseqc_env/bin/activate


# --- Step 1: GTF to genePred -----------------------------------

echo "Step 1: gtfToGenePred"

$TOOLS/gtfToGenePred $GTF $ANNOT/dmel.genePred


# --- Step 2: genePred to BED -----------------------------------

echo "Step 2: genePredToBed"

$TOOLS/genePredToBed $ANNOT/dmel.genePred $ANNOT/dmel.bed


# --- Step 3: Infer strandedness --------------------------------

echo "Step 3: infer_experiment.py"

infer_experiment.py \
    -r $ANNOT/dmel.bed \
    -i $MAP/${SAMPLE}_sorted.bam \
    > $MAP/${SAMPLE}_strandedness.txt


deactivate

echo "Done. Result in $MAP/${SAMPLE}_strandedness.txt"