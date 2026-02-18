#!/usr/bin/env bash
set -euo pipefail

# Example:
# bash 01_build_reference.sh \
#   --human-fasta ref/GRCh38.primary_assembly.genome.fa \
#   --human-gtf   ref/gencode.v47.primary_assembly.annotation.gtf \
#   --virus KSHV:ref/KSHVseq.fasta:ref/KSHVseq.gtf \
#   --virus EBV:ref/NC_007605.1.fasta:ref/NC_007605.1.gtf \
#   --outdir ref_bundle

python tools/ref_builder.py "$@"

