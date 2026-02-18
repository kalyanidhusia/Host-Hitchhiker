# human-virus-rnaseq-nextflow

Reproducible host–virus RNA-seq quantification using a combined reference (human + one or more viruses) and `nf-core/rnaseq` (STAR + Salmon).  
This repository focuses on making dual-transcriptome analysis reliable on HPC: reference hygiene, samplesheet generation, offline-safe Nextflow runs, and viral QC outputs.

## What this pipeline provides

**1) Reference builder**
- Merges **GRCh38 FASTA** with one or more **viral FASTA** files into a unified `human_virus.fasta`
- Produces a unified `human_virus.gtf` with RNA-seq-compatible structure
- Generates `gene_annotation.tsv` for HOST vs VIRUS gene labeling
- Produces `contig_origin.tsv` for contig provenance tracking
- Includes sanity checks that catch common GTF/FASTA issues before long runs

**2) nf-core wrapper scripts**
- Generates nf-core compatible samplesheets from `reads/*fastq.gz`
- Runs `nf-core/rnaseq` with pinned versions and consistent parameters
- Supports HPC execution patterns and offline-safe Nextflow settings

**3) Viral QC + exploratory figures**
- Per-sample viral burden and breadth tables
- Viral fraction plots, host PCA, and viral gene heatmap (from merged gene counts)

## Repository layout

```text
.
├── 01_make_human_virus_reference.sh
├── 02_prepare_nfcore_and_qc.sh
├── 03_submit_slurm.sh
├── 05_host_virus_qc_and_figures.py
├── ref/                         # reference outputs (recommended)
├── reads/                       # input FASTQs (not committed)
├── docs/
└── examples/
    ├── samplesheet.csv
    └── metadata.tsv

