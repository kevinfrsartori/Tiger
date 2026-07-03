#!/bin/bash

#SBATCH -A naiss2026-3-117
#SBATCH -p shared
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=150G
#SBATCH -t 18:00:00
#SBATCH -J RTiger
#SBATCH --mail-user kevin.sartori@slu.se
#SBATCH --mail-type=ALL

#--------------------------------------
# 2026-March
# Here I use the mapping of the RILs to Cr 183
# Adapted from RTiger pipeline https://github.com/rfael0cm/RTIGER
#--------------------------------------

echo "load conda environment for RTIGER"
ml PDC/24.11 miniconda3/25.3.1-1-cpeGNU-24.11
#conda env create -f env.yml
source activate RTIGER

# packages mannually installed : the following was run in R
#BiocManager::install(c("GenomicRanges", "GenomeInfoDb", "TailRank", "IRanges", "Gviz"))
#library(devtools)
#install_github("rfael0cm/RTIGER")
#library(RTIGER)
#setupJulia()

outdir=[DIR for outputs]/RILs

# Important note:
#----------------
# Instead of tuning parameters (time and resource consuming), I run individuals in batches of equivalent coverage
# I am not sure but during exploration of the method I felt like it has some importance
# And I base parameter rigidity "R" on min cov, such as R increase when cev decreases
# R is the minimum number of marker per window/haplotype
# We want larger window when low coverage, at a cost of poor estimation of breaking point position
# But we want short window when coverage is high enough to make precise breaking point estimation
# example with R=50/mincov; mincov=1, R=50; mincov=4; R=12.5

# How to run
#-----------
#sort -u -k 2 namecov.txt > namecov.sorted.txt
#tail namecov.sorted.txt
#get the range of coverage and run on a sequence of .5
# for c in 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5; do echo $c; sbatch 40-RTIGER.sh $c; done

mincov=$1
maxcov=$(echo "$1 + 0.5" | bc)
R=$(echo "scale=4; 50/$mincov" | bc -l)

# Prepare design file for RTIGER
echo "Prepare 'expDesign' object for RTIGER"

sort -u -k 2 namecov.txt > namecov.sorted.txt
awk -v mincov="$mincov" '{if ($2 > mincov) print}' namecov.sorted.txt | awk -v maxcov="$maxcov" '{if ($2 < maxcov) print $1}' > shortlist.cov.$mincov.$maxcov.txt

echo -e 'files\tname' > expDesign.cov.$mincov.$maxcov.txt
ls -l $outdir/*/bam/*_corrected.txt | grep -w -f shortlist.cov.$mincov.$maxcov.txt | awk 'BEGIN {FS=" "} {print $9}' > paths.cov.$mincov.$maxcov.txt
awk 'BEGIN {FS="/"} {print $11}' paths.cov.$mincov.$maxcov.txt > names.cov.$mincov.$maxcov.txt
paste paths.cov.$mincov.$maxcov.txt names.cov.$mincov.$maxcov.txt >> expDesign.cov.$mincov.$maxcov.txt
rm paths.cov.$mincov.$maxcov.txt names.cov.$mincov.$maxcov.txt shortlist.cov.$mincov.$maxcov.txt

N=$(echo $(wc -l < expDesign.cov.$mincov.$maxcov.txt)-1 | bc)
  
if [ $N -gt 0 ]
then
echo "Run RTIGER for $N indivs"
echo "R=$R ; mincov= $mincov ; maxcov = $maxcov"
mkdir $outdir/RTIGER_output.R.$R.cov.$mincov.$maxcov
R --slave --vanilla --args expDesign.cov.$mincov.$maxcov.txt chrm_lengths.txt $outdir/RTIGER_output.R.$R.cov.$mincov.$maxcov $R < RTIGER.R
else
echo "$N : expDesign file is empty"
fi
