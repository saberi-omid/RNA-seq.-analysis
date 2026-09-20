# 📓 Command Log — *Drosophila melanogaster* RNA-seq Pipeline

![organism](https://img.shields.io/badge/organism-D._melanogaster-blue)
![sample](https://img.shields.io/badge/sample-SRR031714-lightgrey)
![layout](https://img.shields.io/badge/library-paired--end%2037bp-green)
![status](https://img.shields.io/badge/pipeline-complete-brightgreen)

A step-by-step log of the single-sample RNA-seq pipeline, from raw reads to a
gene-level count matrix. Every parameter choice is data-driven — recorded here
alongside the number that justified it.

> [!NOTE]
> **Dataset:** SRR031714 — *Drosophila melanogaster*, 37 bp paired-end.
> **Reference:** Ensembl BDGP6 (HISAT2 index `bdgp6_tran`; annotation `BDGP6.54.63`).
> **Environment:** WSL2 Ubuntu, 4 cores, ~2.9 GB RAM.

---

## 🗂️ Scripts

| # | Script | Purpose |
|---|--------|---------|
| 01 | `01_qc_and_trim.sh` | QC + trim (single-end template) |
| 02 | `02_download_data.sh` | Download raw reads + md5 verification |
| 03 | `03_qc_and_trim_PE.sh` | FastQC → Trimmomatic PE → FastQC |
| 04 | `04_mapping_PE.sh` | HISAT2 → BAM → sort → index |
| 05 | `05_strandedness.sh` | RSeQC `infer_experiment.py` |
| 06 | `06_build_index.sh` | Build/prepare HISAT2 reference index |
| 07 | `07_quantification_featureCounts.sh` | featureCounts gene-level quant |
| 08 | `08_quantification_htseq_count.sh` | htseq-count (cross-check vs featureCounts) |

---

## 🔬 Step 03 — QC & Trimming (Trimmomatic PE)

```bash
java -jar trimmomatic-0.39.jar PE -threads 4 -phred33 \
    SRR031714_1.fastq.gz SRR031714_2.fastq.gz \
    ..._1_paired.fastq.gz ..._1_unpaired.fastq.gz \
    ..._2_paired.fastq.gz ..._2_unpaired.fastq.gz \
    LEADING:3 TRAILING:15 SLIDINGWINDOW:4:20 MINLEN:25
```

> [!IMPORTANT]
> Parameter rationale (from raw FastQC):
> - **`ILLUMINACLIP` omitted** — Adapter Content was green in both mates
> - **`MINLEN:25`** (not 36) — reads are only **37 bp** long
> - **`LEADING:3`** kept low — 5′ quality already ~Q40

**Result:**

| Metric | Value |
|--------|-------|
| Input read pairs | 5,327,425 |
| ✅ Both surviving | **5,127,040 (96.24%)** |
| Forward only surviving | 83,801 (1.57%) |
| Reverse only surviving | 73,572 (1.38%) |
| Dropped | 43,012 (0.81%) |

---

## 🧭 Step 04 — Mapping (HISAT2)

```bash
hisat2 -p 4 -x bdgp6_tran/genome_tran \
    -1 ..._1_paired.fastq.gz -2 ..._2_paired.fastq.gz \
    -S SRR031714.sam --summary-file SRR031714_alignment_summary.txt
# then: samtools view -b | sort | index
```

> [!NOTE]
> `--rna-strandness` deliberately omitted — library assumed unstranded, then
> confirmed computationally in step 05.

**Result:**

| Metric | Value |
|--------|-------|
| Reads (pairs) | 5,127,040 |
| Concordant, exactly 1× | 4,014,406 (78.30%) |
| Concordant, >1× | 545,339 (10.64%) |
| Concordant, 0× | 567,295 (11.06%) |
| **Overall alignment rate** | **93.30%** |

---

## 🧯 Step 05 — Strandedness (RSeQC)

`infer_experiment.py` on the sorted BAM against a gene-model BED.

**Result → library is UNSTRANDED:**

| Fraction | Value |
|----------|-------|
| `1++,1--,2+-,2-+` (sense) | 0.4837 |
| `1+-,1-+,2++,2--` (antisense) | 0.4529 |
| Failed to determine | 0.0634 |

> [!IMPORTANT]
> ~48% vs ~45% → essentially 50/50 → **unstranded**. This sets `-s 0`
> (featureCounts) and `-s no` (htseq-count) downstream.

---

## 🧮 Step 07 — Quantification (featureCounts)

```bash
featureCounts -a BDGP6.54.63.gtf -o SRR031714_counts.txt \
    -T 4 -t exon -g gene_id -s 0 -Q 30 -p --countReadPairs SRR031714_sorted.bam
cut -f 1,7 SRR031714_counts.txt > SRR031714_simplified_counts.txt
```

> [!IMPORTANT]
> Data-driven flags:
> - **`-s 0`** — unstranded (from step 05)
> - **`-p --countReadPairs`** — paired-end (from `samtools flagstat`)
> - **`-Q 30`** — MAPQ filter

Output: full count matrix + simplified 2-column (`gene_id`, count) file for R.

---

## 🧮 Step 08 — Quantification cross-check (htseq-count)

```bash
htseq-count -f bam -r pos -s no -a 30 -t exon -i gene_id -n 4 \
    SRR031714_sorted.bam BDGP6.54.63.gtf > SRR031714_htseq_counts.txt
```

Parameters mirror the featureCounts run so the two tables are directly
comparable (`-s no` = unstranded, `-a 30` = MAPQ filter, `-t exon`, `-i gene_id`).

**Special counters (reads not assigned to a single gene):**

| Counter | Reads |
|---------|-------|
| `__no_feature` | 114,609 |
| `__ambiguous` | 161,546 |
| `__too_low_aQual` | 357,350 |
| `__not_aligned` | 159,479 |
| `__alignment_not_unique` | 567,764 |

---

## ⚖️ featureCounts vs htseq-count

Both tools were run on the **same BAM** and the **same GTF** with matching
parameters (unstranded, MAPQ ≥ 30, exon / gene_id), so the two count tables
can be compared directly.

| Metric | featureCounts | htseq-count |
|--------|--------------:|------------:|
| Total genes in table | 24,254 | 24,254 |
| Genes with non-zero counts | 11,283 | 10,894 |
| Reads assigned to genes | 4,120,105 | 3,766,300 |

**featureCounts summary (assignment breakdown):**

| Status | Reads |
|--------|------:|
| Assigned | 4,120,105 |
| Unassigned — MultiMapping | 4,915,648 |
| Unassigned — NoFeatures | 131,735 |
| Unassigned — Ambiguity | 130,755 |
| Unassigned — Unmapped | 159,479 |
| Unassigned — MappingQuality | 13,641 |

> [!IMPORTANT]
> **Why featureCounts assigns ~354k more reads.** The two tools agree closely,
> but differ mainly in how they treat **multi-mapping** and **ambiguous** reads.
> With these settings both discard multi-mappers, yet their overlap-resolution
> and pair-counting rules differ slightly, so featureCounts places a few more
> reads and calls a few more genes "expressed" (11,283 vs 10,894). This is
> expected tool-to-tool variation, not an error — the biological signal is the
> same, which is exactly why running both is a useful reproducibility check.

---

## ✅ Pipeline status

- [x] 01–02 · download + md5 verification
- [x] 03 · QC & trimming (96.24% survival)
- [x] 04 · HISAT2 mapping (93.30% alignment)
- [x] 05 · strandedness (unstranded, RSeQC)
- [x] 06 · reference index
- [x] 07 · featureCounts quantification
- [x] 08 · htseq-count cross-check (compared vs featureCounts — close agreement)
- [ ] Downstream DGE (DESeq2) — practice done on synthetic data; real run pending
