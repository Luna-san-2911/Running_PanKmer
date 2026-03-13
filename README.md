# Running_PanKmer
Hola!
Hi!

This repository has some troubleshooting and notes from my experience running [PanKmer](https://academic.oup.com/bioinformatics/article/39/10/btad621/7319363).
Moreover I added a [master sbatch script](https://github.com/Luna-san-2911/Running_PanKmer/blob/main/pankmer_master.sbatch) that does most of PanKmer analysis at once. So from .fasta genomes you will get a relatedness heatmap, pangenome completeness graph, upset plot and kmer conservancy accross all chromosomes of your genomes.

# Installation
I didn't had success following the PanKmer manual. Next you will see what worked for me.
So, 1st of all create a conda environment

```
conda create -n pankmer
```

Then activate the environment and install all the dependencies

```
conda activate pankmer

conda install python=3.10 cython gff2bed more-itertools pybedtools python-newick pyfaidx rust seaborn upsetplot urllib3 tabix dash-bootstrap-components
```

You need the dependencies to run this last command

```
pip install pankmer
```

Now try 

```
pankmer --version
```
If you see the subcommands plotted, then we are ready!


