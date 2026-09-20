# RNA-seq Analysis Pipeline

![organism](https://img.shields.io/badge/organism-D._melanogaster-blue)
![sample](https://img.shields.io/badge/sample-SRR031714-lightgrey)
![tools](https://img.shields.io/badge/tools-HISAT2%20%7C%20featureCounts%20%7C%20DESeq2-green)
![status](https://img.shields.io/badge/pipeline-complete-brightgreen)

A full RNA-seq pipeline for one *Drosophila melanogaster* sample, from raw reads
to a gene-level count matrix, plus the differential expression (DESeq2) workflow
in R. I built this while working through an RNA-seq course, and every parameter
choice is based on the actual data — not copied defaults.

## What this repo shows

- A working command-line pipeline: QC, trimming, alignment, strandedness check,
  and quantification with two different tools.
- Parameter decisions backed by numbers (read length, adapter content,
  strandedness, MAPQ), all written down in `command_log.md`.
- The R side: a DESeq2 differential expression workflow, from count table to
  volcano plot and heatmaps.

## Sample & reference

- **Sample:** SRR031714 — *Drosophila melanogaster*, 37 bp paired-end
- **Reference:** Ensembl BDGP6 (HISAT2 index `bdgp6_tran`, annotation `BDGP6.54.63`)

## Pipeline steps

| # | Script | What it does |
|---|--------|--------------|
| 01 | `01_qc_and_trim.sh` | QC + trim (single-end template) |
| 02 | `02_download_data.sh` | Download raw reads, check md5 |
| 03 | `03_qc_and_trim_PE.sh` | FastQC → Trimmomatic (PE) → FastQC |
| 04 | `04_mapping_PE.sh` | HISAT2 → BAM → sort → index |
| 05 | `05_strandedness.sh` | Check strandedness (RSeQC) |
| 06 | `06_build_index.sh` | Build the HISAT2 reference index |
| 07 | `07_quantification_featureCounts.sh` | Count reads per gene (featureCounts) |
| 08 | `08_quantification_htseq_count.sh` | Count again with htseq-count, to compare |

## Key results

| Step | Result |
|------|--------|
| Trimming | 96.24% of read pairs survived |
| Alignment | 93.30% overall (78.30% concordant, unique) |
| Strandedness | Unstranded (~48% vs ~45%) |
| featureCounts | 4,120,105 reads assigned · 11,283 genes expressed |
| htseq-count | 3,766,300 reads assigned · 10,894 genes expressed |

The two counting tools agree closely; they mostly differ in how they handle
multi-mapping reads. Full numbers and reasoning are in
[`command_log.md`](command_log.md).

## Folder layout

```
RNA-seq.-analysis/
├── scripts/     # numbered pipeline scripts (01–08)
├── R/           # DESeq2 / downstream analysis
├── results/     # small text outputs (alignment summary, strandedness)
├── metadata/    # sample info
├── figures/     # plots
├── docs/        # notes
├── data/        # raw/processed reads  (git-ignored — too large)
└── command_log.md
```

Large files (reads, BAMs, indexes) are not tracked in git — see `.gitignore`.
Only scripts and small text results are versioned.

## How to run

Scripts run in order. Set the paths at the top of each one to match your setup,
then:

```bash
bash scripts/03_qc_and_trim_PE.sh
bash scripts/04_mapping_PE.sh
bash scripts/05_strandedness.sh
bash scripts/07_quantification_featureCounts.sh
```

You need: FastQC, Trimmomatic, HISAT2, samtools, RSeQC, featureCounts (subread),
and htseq-count installed and on your PATH.

## Tools

FastQC · Trimmomatic 0.39 · HISAT2 · samtools · RSeQC · featureCounts (subread) ·
htseq-count · R + DESeq2

## Notes

- Built and run on WSL2 (Ubuntu), 4 cores, ~2.9 GB RAM.
- The DESeq2 practice in `R/` uses a small synthetic count table, since this
  single-sample dataset can't be used for real differential expression (that
  needs replicates in two or more groups).
