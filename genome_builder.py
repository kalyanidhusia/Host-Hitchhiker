import os

def combine_references(name, human_fa, human_gtf, viral_files):
    """
    viral_files: List of tuples [(fasta_path, gtf_path), ...]
    """
    out_fa = f"{name}_combined.fasta"
    out_gtf = f"{name}_combined.gtf"
    
    print(f"--- Creating {name} Reference ---")
    
    # 1. Combine FASTAs
    with open(out_fa, 'w') as f_out:
        # Start with Human
        with open(human_fa, 'r') as h:
            f_out.write(h.read())
        # Append Viral
        for v_fa, v_gtf in viral_files:
            with open(v_fa, 'r') as v:
                f_out.write("\n" + v.read())
    
    # 2. Combine GTFs
    with open(out_gtf, 'w') as g_out:
        # Start with Human
        with open(human_gtf, 'r') as h:
            g_out.write(h.read())
        # Append Viral
        for v_fa, v_gtf in viral_files:
            with open(v_gtf, 'r') as v:
                # Basic validation: ensure we don't copy headers from middle files
                for line in v:
                    if not line.startswith("#"):
                        g_out.write(line)
    
    print(f"Created: {out_fa} and {out_gtf}\n")

# Define your file paths based on your 'ls' output
HUMAN_FA = "GRCh38.primary_assembly.genome.fa" # Replace with GRCh38 Primary if downloaded
HUMAN_GTF = "gencode.v47.primary_assembly.annotation.gtf"
KSHV_FA = "KSHVseq.fasta"
KSHV_GTF = "KSHVseq.fixed.gtf"
KT_FA = "KT899744.1.fasta"
KT_GTF = "KT899744.1.renamed.gtf"

# Task 1: Human + KSHV
combine_references("human_KSHV", HUMAN_FA, HUMAN_GTF, 
                   [(KSHV_FA, KSHV_GTF)])

# Task 2: Human + KT899744
combine_references("human_KT89", HUMAN_FA, HUMAN_GTF, 
                   [(KT_FA, KT_GTF)])

# Task 3: Human + KSHV + KT89
combine_references("human_dual_virus", HUMAN_FA, HUMAN_GTF, 
                   [(KSHV_FA, KSHV_GTF), (KT_FA, KT_GTF)])
