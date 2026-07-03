#!/bin/bash

#SBATCH -A naiss2026-3-117
#SBATCH -p shared
#SBATCH --ntasks=8
#SBATCH --mem=20GB
#SBATCH --cpus-per-task=2
#SBATCH -t 06:00:00
#SBATCH -J Comb_gvcf_RILs
#SBATCH --mail-user kevin.sartori@slu.se
#SBATCH --mail-type=ALL
ulimit -c unlimited

chrm=$1
argsfile=$2
ref=$3
outdir=[DIR for outputs]/RILs

# how to run:
# first make list of gvcf to combine
#ls $outdir/RILs/*/bam/*.g.dpfilt.vcf > tocomb.txt
# transform it into list of arguments
#awk '{print "-V " $1 }' tocomb.txt > argsfile.txt
# Then send to queue
# for chrm in {1..8};
# do sbatch 15-Combine.sh scaffold_$chrm argsfile.txt /$refdir/Crubella_183.s.fa
# done

echo "loading modules"
echo
ml gatk/4.5.0.0
echo

echo 'GATK CombineGVCFs'

gatk --java-options -Xmx7g CombineGVCFs -L $chrm -R $ref --arguments_file $argsfile -O $outdir/RILs_samples_combined.$chrm.t.vcf

