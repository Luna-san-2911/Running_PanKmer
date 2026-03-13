#!/bin/bash -l
#SBATCH -J pankmer
#SBATCH --output=pankmer-%j.output
#SBATCH --error=pankmer-%j.error
#SBATCH -t 120:00:00
#SBATCH --partition=bmh
#SBATCH --mail-type=ALL
#SBATCH --mail-user=plunarodriguez@ucdavis.edu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G

set -euo pipefail

echo "Running on host: $(hostname)"
echo "Starting at: $(date)"

#Remember to be in your conda environment pankmer with all the dependencies installed

pankmer index -g /group/gmonroegrp2/chaehee/Pablo/pangenie/03_infered_haplotypes/output/*.fasta \
 -o /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_pankmer_index.tar

pankmer adj-matrix -i /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_pankmer_index.tar \
 -o /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_adj_matrix.csv

pankmer clustermap -i /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_adj_matrix.csv \
  --height 15 \
  --width 15 \
  -o /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_adj_matrix.svg

pankmer collect -i /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_pankmer_index.tar \
  --conf \
  -o /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_collect.svg

pankmer upset -i /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_pankmer_index.tar \
  -g BE5_1_pangenie_hap1 R1_B2_C4_1_pangenie_hap2 R2_B2_C8_1_pangenie_hap1 BE5_1_pangenie_hap1.fai R1_B2_C5_1_pangenie_hap1 R>
  -o /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_upset.svg


#Anchor genome uses a reference genome to have conserved kmers
#I used a clone genome for this
#It plots per each chromosome
#It is possible to compare different pangenomes (i.e. pangenome of one specie and of another specie)
#But then you require multiple .tar files

for i in $(seq -w 1 15); do
    pankmer anchor-genome \
      -i /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_pankmer_index.tar \
      -a /group/gmonroegrp2/chaehee/Pablo/pangenie/03_infered_haplotypes/output/R2_B2_C10_1_pangenie_hap1.fasta \
      -c Chr${i} \
      --table /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_Chr${i}_anchor.tsv \
      -o /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_Chr${i}_anchor.svg
done

echo "pankmer finished at: $(date)"
