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

#1. -g is used to specify the path to your fasta files, no need to do a loop here, only use the *
#It creates a .tar files that stores the kmer prescence abscence data for all your genomes

pankmer index -g /group/gmonroegrp2/chaehee/Pablo/pangenie/03_infered_haplotypes/output/*.fasta \
 -o /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_pankmer_index.tar


#2. This creates the adjancency matrix, later need to calculate average nucleatide diversity and create the relatedeness plot
# -i is used to specify the .tar file from the previous step
# -o is the output path, it is a csv file with the adjacency values

pankmer adj-matrix -i /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_pankmer_index.tar \
 -o /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_adj_matrix.csv

#3. This plots your realatedeness plot, -i is the path to the .csv file produce in step 2
# -o is the output path, I used .svg but you could use .pdf too
# --height and --width could be changed, it is in inches. I used 15 because of my number of samples, otherwise they were overlapped

pankmer clustermap -i /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_adj_matrix.csv \
  --height 15 \
  --width 15 \
  -o /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_adj_matrix.svg


#4. Tis plots the pangenome completeness plot, -i is the path to the .tar file produced in step 1
# --conf is to have the confidence interval 95% plotted, u could remove it 
# -o is output path, again you could use .pdf and adjust height and width

pankmer collect -i /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_pankmer_index.tar \
  --conf \
  -o /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_collect.svg

#5. Tis plots the upset plot, -i is the path to the .tar file produced in step 1
# -g is used to specify the sample names of your genomes 
# -o is output path, again you could use .pdf and adjust height and width

pankmer upset -i /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_pankmer_index.tar \
  -g BE5_1_pangenie_hap1 R1_B2_C4_1_pangenie_hap2 R2_B2_C8_1_pangenie_hap1 \
  -o /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_upset.svg


#6. Anchor genome uses a reference genome to have conserved kmers
#I used a clone genome for this
#It plots per each chromosome
#It is possible to compare different pangenomes (i.e. pangenome of one specie and of another specie)
#But then you require multiple .tar files
#This loop runs per all your chromosome, adjust it if you have different Chromosome names and number
# -i is path to the tar file from step 1
# -a is the path to the reference genome you will use for conservancy comparison
# -c is the chromosome to select, in my case it changes as is a loop
# --table is the output path that stores the conserved kmers as a table
# -o is the output path, again it could be .pdf

for i in $(seq -w 1 15); do
    pankmer anchor-genome \
      -i /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_pankmer_index.tar \
      -a /group/gmonroegrp2/chaehee/Pablo/pangenie/03_infered_haplotypes/output/R2_B2_C10_1_pangenie_hap1.fasta \
      -c Chr${i} \
      --table /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_Chr${i}_anchor.tsv \
      -o /group/gmonroegrp2/chaehee/Pablo/pangenie/06_pankmer/UCB1_Chr${i}_anchor.svg
done

echo "pankmer finished at: $(date)"
