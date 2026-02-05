#!/bin/bash
#SBATCH --job-name=nf_gtf_viral
#SBATCH --output=logs/nf_gtffix_%j.log
#SBATCH --error=logs/nf_gtffix_%j.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=58G
#SBATCH --time=28:00:00
#SBATCH --partition=xeon

# Create logs directory if it doesn't exist
mkdir -p logs

# Load Apptainer
module load apptainer/1.3.6-s2en2qm

## Run the pipeline
#nextflow run nf-core/rnaseq \
#    -r 3.14.0 \
#    -profile apptainer \
#    --input ./newsamplsheet.csv \
#    --outdir ./results_kshv_host_shutoff \
#    --star_index /home/kdhusia/PROJECTS/manzo/combine_results/genome/index/star/ \
#    --fasta /home/kdhusia/PROJECTS/manzo/data/human_kshv_combined.fasta \
#    --gtf /home/kdhusia/PROJECTS/manzo/data/human_kshv_biotype_combined.gtf \
#    --strandedness reverse \
#    --skip_check_strandedness \
#    --skip_dupradar \
#    --skip_qualimap \
#    --aligner star_salmon \
#    --max_cpus 16 \
#    --max_memory '58.GB' \
#    -resume

#update gtf for viral entry
nextflow run nf-core/rnaseq \
    -r 3.14.0 \
    -profile apptainer \
    --input ./newsamplsheet.csv \
    --outdir ./results_kshv_host \
    --fasta /home/kdhusia/PROJECTS/manzo/data/human_kshv_combined.fasta \
    --gtf /home/kdhusia/PROJECTS/manzo/data/human_kshv_final_fixed.gtf \
    --strandedness reverse \
    --skip_check_strandedness \
    --skip_gtf_filter \
    --skip_dupradar \
    --skip_qualimap \
    --aligner star_salmon \
    --max_cpus 16 \
    --max_memory '58.GB' \
    -resume
