#!/usr/bin/env bash
set -euo pipefail

die(){ echo "ERROR: $*" >&2; exit 1; }

prompt() {
  local __var="$1" __txt="$2" __def="${3:-}" v=""
  if [[ -n "$__def" ]]; then
    read -r -p "$__txt [$__def]: " v
    v="${v:-$__def}"
  else
    read -r -p "$__txt: " v
  fi
  [[ -n "$v" ]] || die "Empty input for $__txt"
  printf -v "$__var" "%s" "$v"
}

###########################################
# READS → AUTO SAMPLE SHEET GENERATION
###########################################

echo ""
read -p "Full path to reads folder (contains *_1.fastq.gz *_2.fastq.gz): " READS_DIR

if [[ ! -d "$READS_DIR" ]]; then
    echo "ERROR: Reads directory does not exist"
    exit 1
fi

# Convert to absolute path
#READS_DIR=$(realpath "$READS_DIR")

READS_DIR=$(cd "$READS_DIR" && pwd -P)
# Optional: force /home path if it exists
if [[ "$READS_DIR" == /mnt/uams-gs/home/* ]]; then
  READS_DIR="/home/${READS_DIR#/mnt/uams-gs/home/}"
fi

echo "==> Using reads from: $READS_DIR"

SAMPLESHEET="dual_virus_samplesheet.csv"

echo "sample,fastq_1,fastq_2,strandedness" > $SAMPLESHEET

# Loop over R1 files
for R1 in $READS_DIR/*_1.fastq.gz; do
    R2=${R1/_1.fastq.gz/_2.fastq.gz}

    if [[ ! -f "$R2" ]]; then
        echo "WARNING: Missing pair for $R1"
        continue
    fi

    SAMPLE=$(basename $R1 | sed 's/_1.fastq.gz//')

    echo "$SAMPLE,$R1,$R2,reverse" >> $SAMPLESHEET
done

echo ""
echo "==> Generated samplesheet:"
cat $SAMPLESHEET
echo ""

# Sanity check
NUM_SAMPLES=$(($(wc -l < $SAMPLESHEET)-1))

if [[ $NUM_SAMPLES -eq 0 ]]; then
    echo "ERROR: No paired FASTQ files found"
    exit 1
fi

echo "==> Found $NUM_SAMPLES paired samples"



echo "=============================="
echo "02_prepare: params + sanity"
echo "=============================="

prompt SAMPLESHEET "1) Sample sheet CSV" "./dual_virus_samplesheet.csv"
prompt BUNDLE      "2) Reference bundle dir" "./ref_bundle"
prompt OUTDIR      "3) nf-core output dir" "./results_host_multiVirus"

prompt NFCORE_VER  "4) nf-core/rnaseq version" "3.14.0"
prompt PROFILE     "5) nextflow profile for SLURM run" "slurm,apptainer"
prompt ALIGNER     "6) aligner" "star_salmon"
prompt STRAND      "7) strandedness" "reverse"
prompt MAX_CPUS    "8) max_cpus" "16"
prompt MAX_MEM     "9) max_memory" "58.GB"

[[ -f "$SAMPLESHEET" ]] || die "Missing samplesheet: $SAMPLESHEET"
[[ -d "$BUNDLE" ]] || die "Missing bundle dir: $BUNDLE"
[[ -f "$BUNDLE/reference.pass" ]] || die "reference.pass not found. Run 01_build_reference.sh first."
[[ -f "$BUNDLE/human_virus.fasta" ]] || die "Missing: $BUNDLE/human_virus.fasta"
[[ -f "$BUNDLE/human_virus.gtf" ]] || die "Missing: $BUNDLE/human_virus.gtf"

PARAMS_FILE="02_nfcore_params.txt"
cat > "$PARAMS_FILE" <<EOF
SAMPLESHEET=$SAMPLESHEET
OUTDIR=$OUTDIR
FASTA=$BUNDLE/human_virus.fasta
GTF=$BUNDLE/human_virus.gtf
ANN=$BUNDLE/gene_annotation.tsv
CONTIGMAP=$BUNDLE/contig_origin.tsv
NFCORE_VER=$NFCORE_VER
PROFILE=$PROFILE
ALIGNER=$ALIGNER
STRANDEDNESS=$STRAND
MAX_CPUS=$MAX_CPUS
MAX_MEMORY=$MAX_MEM
EOF

echo "Wrote: $PARAMS_FILE"
echo "Next: bash 03_submit_slurm.sh $PARAMS_FILE"

