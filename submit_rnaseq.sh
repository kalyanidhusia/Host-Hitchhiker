#!/bin/bash
#SBATCH --job-name=nf_gtf_viral
#SBATCH --output=logs/gtffix_%j.log
#SBATCH --error=logs/gtffix_%j.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=58G
#SBATCH --time=28:00:00
#SBATCH --partition=any

# Create logs directory if it doesn't exist
mkdir -p logs

# Load Apptainer
module load apptainer/1.3.6-s2en2qm

## Run the pipeline
#update gtf for viral entry
nextflow run nf-core/rnaseq \
  -r 3.14.0 \
  -profile apptainer \
  --input dual_virus_samplesheet.csv \
  --outdir results_host_multiVirus \
  --fasta ref/human_virus.fasta \
  --gtf ref/human_virus.gtf \
  --strandedness reverse \
  --skip_check_strandedness \
  --skip_gtf_filter \
  --skip_dupradar \
  --skip_qualimap \
  --aligner star_salmon \
  --max_cpus 16 \
  --max_memory '58.GB' \
  --skip_biotype_qc \
  -resume

