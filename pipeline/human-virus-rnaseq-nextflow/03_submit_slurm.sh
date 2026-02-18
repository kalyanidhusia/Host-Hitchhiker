#!/usr/bin/env bash
set -euo pipefail
die(){ echo "ERROR: $*" >&2; exit 1; }

PARAMS_FILE="${1:-02_nfcore_params.txt}"
[[ -f "$PARAMS_FILE" ]] || die "Missing params file: $PARAMS_FILE"

# shellcheck disable=SC1090
source "$PARAMS_FILE"

: "${SAMPLESHEET:?}"
: "${OUTDIR:?}"
: "${FASTA:?}"
: "${GTF:?}"
: "${NFCORE_VER:?}"
: "${PROFILE:?}"
: "${ALIGNER:?}"
: "${STRANDEDNESS:?}"
: "${MAX_CPUS:?}"
: "${MAX_MEMORY:?}"

mkdir -p logs

SBATCH_CPUS="$MAX_CPUS"
SBATCH_MEM="${SBATCH_MEM_OVERRIDE:-64G}"
SBATCH_TIME="${SBATCH_TIME_OVERRIDE:-24:00:00}"
SBATCH_PART="${SBATCH_PART_OVERRIDE:-any}"

JOB_SCRIPT="logs/nfcore_rnaseq_job.sh"

cat > "$JOB_SCRIPT" <<EOF
#!/usr/bin/env bash
set -euo pipefail
echo "Job started on: \$(hostname)  \$(date)"
echo "PWD: \$(pwd)"

nextflow run nf-core/rnaseq \\
  -r "$NFCORE_VER" \\
  -profile "$PROFILE" \\
  --input "$SAMPLESHEET" \\
  --outdir "$OUTDIR" \\
  --fasta "$FASTA" \\
  --gtf "$GTF" \\
  --strandedness "$STRANDEDNESS" \\
  --skip_check_strandedness \\
  --skip_gtf_filter \\
  --skip_dupradar \\
  --skip_qualimap \\
  --aligner "$ALIGNER" \\
  --max_cpus "$MAX_CPUS" \\
  --max_memory "$MAX_MEMORY" \\
  --skip_biotype_qc \\
  -resume

echo "Job finished: \$(date)"
EOF

chmod +x "$JOB_SCRIPT"

sbatch \
  -J nfcore_rnaseq_hostvirus \
  -p "$SBATCH_PART" \
  -c "$SBATCH_CPUS" \
  --mem "$SBATCH_MEM" \
  -t "$SBATCH_TIME" \
  -o logs/%x.%j.out \
  -e logs/%x.%j.err \
  "$JOB_SCRIPT"

